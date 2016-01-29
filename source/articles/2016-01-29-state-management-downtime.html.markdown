---
title: "Developer Diary: How being lazy about state management caused downtime"
date: 2016-01-29
tags:  Clojure, Programming, Developer Diary
author: mveytsman
published: false
layout: post
---
We had some downtime on November 10th when the backend application mysteriously crashed and had to be restarted. This is the story of how it happened.

After looking at my process monitoring service, I found a very suspicious graph:

![](https://cloud.githubusercontent.com/assets/34720/11103322/b2d8456c-888f-11e5-8870-914d76a69e16.png)

Somehow, I managed to spin up more then 30,000 threads right before the application crashed. This was very likely the cause of the failure, but how did it happen?

An easy way to get an idea of where a thread leak is coming from is to look at the thread names. In java you can do this with `jstack -l $PID`

To get a list of all thread names of a Java application sorted by most common name, you can do:

```
jstack -l $PID | grep daemon |  awk '{ print $1 }' | sort | uniq -c |   sort -nr
```

I got something like this

```
  30000 "Analytics"
      2 "Datomic
      2 "C2
      1 "worker-4"
      1 "worker-3"
      1 "worker-2"
      1 "worker-1"
      1 "Timer-0"
      1 "Thread-5"
      1 "Thread-4
      1 "Thread-3
      1 "Thread-2
      1 "Thread-1
      1 "Thread-0
```

Hmm....

## Background

Appcanary is a Clojure application and we use Stuart Sierra's [component] framework to manage Appcanary's state and application lifecycle. The analytics client is a bit of state that's managed outside of component, but to explain why, I should first explain a little about how component works.

Briefly, any application that talks to the outside world, no matter how beautiful and functional it is will need to manage some state that represents the outside world. We need to manage our database connections, our clients for external APIs, our background workers, etc.

One way to deal with this in Clojureland is to create a global singleton object for representing each stateful piece, possibly wrapped in an `atom`. This leaves something lacking though, as you still need a way to initialize all these singletons on startup, and having mutable singletons everywhere goes against what I would consider good Clojure style.

Component solves this problem by implementing dependency injection in a Clojurelike way. You define a graph that represents the stateful pieces and how they depend on eachother, and define how each piece starts and stops. Component then handles starting them all in the right order on system start, and passing references to dependencies when needed.

For example, Appcanary's dependency graph looks (something) like this:

```clojure
(defn canary-system
  []
  ;;Initialize logging
  (component/system-map
   :datomic (new-datomic (env :datomic-uri))
   :scheduler (new-scheduler)
   :mailer (component/using  (new-mailer (env :mandrill-key))
                             [:datomic :scheduler])
   :web-server (component/using (new-web-server (env :http-ip) (Integer. (env :http-port)) canary-api)
                             [:datomic])))
```

The `mailer` depends on `datomic` and the `scheduler`, the web server depends on `datomic`, and both `datomic` and the `scheduler` don't depend on anything.

`new-datomic` is a constructor for a record that knows how to start and stop itself, likewise for all the other components. On system start, all the components are started, and the dependencies are filled in.

## Sometimes component feels like overkill

Component is great, but it didn't fit the analytics engine usecase. We use segment.io to handle analytics, and needed to maintain a client to talk to it. An analytics event can potentially be called from anywhere, but it feels cumbersome to pass the analytics client to every component, and into every analytics call. If every component depends on something, it feels like maybe it should be a global singleton. Futhermore, I don't want my components to know much about the analytics client at all, I just want them to know how to trigger events.

What I wanted to have is an analytics namespace which contains all the events I may want to trigger, and wraps the client inside all of them, so I can do something like `(analytics/user-added-server user)` inside of the code that handles server creation.

One thing to note is that while there is a clojure segment.io [client](https://github.com/ardoq/analytics-clj), it's based of a 1.x release of the underlying [java library](https://github.com/segmentio/analytics-java), while we needed to use features only available in the 2.0 version. Because of that, I wrote an analytics namespace that called the java library directly.

The first pass of creating the client looked something like this:

```clojure
(defonce client
  (.build (Analytics/builder (env :segment-api-key))))

(defn track
  "Wrapper for analytics/track"
  [id event properties {:keys [timestamp] :as options}]
  (when (production?)
    (.enqueue client
              ;; Java interop to build the analytics message here)))
```

There's only one problem with the above code. The segment api key is loaded from an environment variable. We deploy appcanary in a pretty standard way -- we compile an uberjar and rsync it to the server. API keys live in environment variables, and the production API key is only going to live on the production server. So, at compile time, we have no way of knowing what the segment api key is. The analytics client needs to be built at runtime not compile time in order to have access to the api key.

## This is where I get lazy

The obvious thing to do to build the analytics client at runtime is to wrap it as a function

```clojure
(defn client
  []
  (.build (Analytics/builder (env :segment-api-key))))

(defn track
  "Wrapper for analytics/track"
  [id event properties {:keys [timestamp] :as options}]
  (when (production?)
    (.enqueue (client)
              ;; Java interop to build the analytics message here)))
```

I saw three downsides here:

1) We'll lose some efficiency from not reusing the TCP connection to segment.io
2) It's possible that and have to waste a bit of time authenticating the analytics client on each call
3) We'll spawn an extra client object per call, but it will be garbage collected immediately as it goes out of scope immediately after the `track` call.

The above three things aren't intrinsically bad, and it seemed like optimizing the performance of your analytics engine early on was a wasteful thing to do in a fast-paced startup environment.

What I didn't consider is that the java library uses [ExecutorService](http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ExecutorService.html) to manage a threadpool, and `shutdown` must be called explicitly on ExecutorService, otherwise the threads are put on hold instead of being marked for GC (see also http://stackoverflow.com/questions/16122987/reason-for-calling-shutdown-on-executorservice).

## Outcome

Every analytics call we made spawned another threadpool, which caused the thread count to grow proportional with user activity.

This is what it looked like right up to the momement when the app went down due to too many threads. We hit 40,000 before it completely died:




## TL;DR:
I spawned a new client object on every analytics call, not realizing that the underlying library uses a thread pool that's not shutdown on garbage collection. This is how we ended up killing the server by hitting 30,000 threads
