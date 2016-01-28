---
title: Slippery exceptions in clojure
date: 2016-01-25
tags: Clojure, Programming, Bugs
author: phillmv
layout: post
---

Recently I spent a couple of hours banging my head against code that looks like this:

```clojure
(defn parse-file
  [contents]
  (filter identity
          (code-that throws-an-exception)))

(defn consume-manifest
  [contents kind]
  (try+
    (app/parse-file kind contents)    
    
    (catch java.lang.Exception e
      (throw+ {:type ::bad-parse :message "Invalid file."}))))
      
(defn check
  [file kind]
  (try+
    (let [artifacts (consume-manifest (slurp file) kind]
      (if (not-empty artifacts)
        … etc
```

And much to my surprise, I kept getting the kind of exception `parse-file` generates deep within the `check` function, right up against `(not-empty artifacts)`.

I've grown somewhat used to Clojure exceptions being unhelpful, but this was taking the cake. Coming from Ruby and pretty much every other language, this brushed up rudely against my expectations. 

We'd had some trouble in the past getting [slingshot](https://github.com/scgilardi/slingshot) to behave properly, so I zero'ed in on there. Don't all exceptions in Java descend from Exception? You can tell that exceptions in Clojure are unloved, given how cumbersome handling them natively is.

Stepping through `check` in the [Cursive](cursive-ide.com) debugger, I could see that the exception generated didn't have the `type` "annotation" being set in `consume-manifest`, which meant that the exception was slipping straight through it. But calling `consume-manifest` directly in my repl was causing it to work as intended.

What the hell was going on?

[Max](https://twitter.com/mveytsman) took one look at it and set me straight. "Oh. [filter](https://clojuredocs.org/clojure.core/filter) is lazy, so the exception isn't being throw until the lazy sequence is accessed."

Excuse me? I had an angry expression on my face. He looked sheepish.

"How else would a lazy data structure work?"

Well. I would expect a `catch java.lang.Exception` to _catch every exception_. This is some outrageous shit right here.

"Right, well, hear me out. What if you had the following Ruby?"


```ruby
def lazy_parse(filename)
  File.open(filename).each_line.each_with_index.lazy.map do |line, i|
    raise "You can't catch me, I'm the exception man" if i == 5
    line
  end
end

def consume_file
  begin
    lazy_parse("Gemfile.lock")
  rescue
    puts "Woops, an exception. Good thing we caught it."
  end
end

file = consume_file
puts file.first(10)
```
    
    

(Did you know that Ruby has had [lazy enumerables](http://railsware.com/blog/2012/03/13/ruby-2-0-enumerablelazy/) for almost four years now? Worth reading [Shaughnessy as well](http://patshaughnessy.net/2013/4/3/ruby-2-0-works-hard-so-you-can-be-lazy))

That shut me up good. And in case you were wondering, the stack trace is also garbage in Ruby; there simply isn't any context for it to preserve. Frankly, I've just never had to think about lazy data structures in Rubbyland; they've not been super popular. 

It's hard to reason about this. I want to write wrapper functions that make my code safe to consume downstream. This isn't feasible for any functions iterating over [`(/ 1.0 0.0)`](http://rosettacode.org/wiki/Infinity#Clojure), but fortunately for us we need to fit this file into memory anyways. In Ruby we'd have to force iterate over the whole sequence, but Clojure makes this easy with [`doall`](https://clojuredocs.org/clojure.core/doall):

```clojure
(defn parse-file
  [contents]
  (doall (filter identity
                 (code-that throws-an-exception))))
```


And now, things behave as intended.
