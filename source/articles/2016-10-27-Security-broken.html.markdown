---
title: The Mirai Botnet is Proof that the Security Industry is Fundamentally Broken
date: 2016-10-27
tags: Security
author: mveytsman
published: false
layout: post
---

Last Friday, my workday was rudely interrupted because I couldn't access Github.
To add insult to injury I couldn't even complain about it on Twitter. I tried to
drown my sorrows by listening to moody Leonard Cohen songs on Spotify, but
alas...

You've probably heard of this. The DNS provider Dyn was facing a massive Denial
of Service attack from the Mirai botnet which attacks Internet of Things devices
like cameras. I've written about the
[Morris worm](https://blog.appcanary.com/2016/tale-of-two-worms.html), and I
wanted to dig into the [source](https://github.com/jgamblin/Mirai-Source-Code)
of the Mirai botnet (helpfully published by the author) to see how the big worm
of 2016 compares to the big worm of 1988.

Can you guess how Mirai spreads? Some new zeroday in the devices? Maybe an old
vulnerability that the devices haven't patched (because lord knows who has time
to apply software updates to their toaster)? Maybe it was HeartBleed?

Mirai only does one thing to break into new devices. It tries a bunch of default
username/password combinations over telnet, like "admin/admin" and "root/realtek". For a
laugh, "mother/fucker" is in there too.

Default credentials. Over telnet. And you get <strike>millions</strike> hundreds
of thousands of
[devices](http://dyn.com/blog/dyn-analysis-summary-of-friday-october-21-attack/).
The Morris worm from 1988 tried a dictionary password attack too, but only if
it's buffer overflow and sendmail backdoor exploits failed. Oh, and it's
dictionary was bigger than Mirai's.

## $75 Billion 

$75 Billion a year. That's how much we spend on information security. And for
what? Suppose I waved a magic wand and cut the worldwide security budget in
half. Would things really be that much worse? 

The security industry wants to blame the dumb IoT manufacturers, and stupid
users for this. I go to security talks all the time that make fun of the idiots
who build these insecure systems given by people who make their money selling
boxes that use advanced "machine learning" to show you a map of where malware is coming from.

This is all the security industry's fault. We've been selling expensive
fingerprint scanners to people who need a good password manager. It's like the
old
[apocryphal](http://mentalfloss.com/article/13103/russians-didnt-just-use-pencils-space)
story about how NASA spent millions of dollars on developing a zero-gravity
space pen, while the Soviets just used pencils. It's how the TSA spent $160
million on body scanners that don't work. I asked a group of pentesters to name
any products that stopped them, and I got back a list of a few that were
annoying to bypass. Heck, sometimes you can even exploit the
[security product](https://blog.appcanary.com/2016/vikhal-symantec.html) itself

There are hard problems in security. We don't know how to write code without
security bugs. We need to get better at that, and I suspect that the best
solutions are going to be more social than technological. But the attacks that
vex right now aren't all from zerodays. Most of the attacks Microsoft
[saw](https://www.microsoft.com/security/sir/default.aspx) in 2015 were from
vulnerabilities from 2012. This is the low hanging fruit. From well-known
vectors. And the security industry isn't helping. Because we're addicted to Big
Contracts for Big Solutions for Big Problems, when we can't even solve the
little ones.

The low hanging fruit is patching, configuration, strong passwords/2fa. The hard
part is writing secure code and not getting socially engineered. Solve the first
three, and focus your security teams's energy on the Sisyphean tasks of the last two

---

#### Paying the Bills

This wasn't really intended as a sales pitch. Appcanary isn't going to protect your from shipping
millions of internet-accessible cameras with the same password. We won't even
protect your from having your DNS provider DoSed.

The major botnet of 2016 is *simpler* than the botnet of 1988. There's something
wrong in how we do security, and at Appcanary, we think it's a complete lack of
focus on low-hanging fruit.

The highest value, easiest thing you can do to improve your security is patch
known vulnerabilities in packages and libraries you use. Most of the attacks Our product,
[Appcanary](https://appcanary.com/?utm_source=blog&utm_medium=web&utm_campaign=broken),
monitors your apps and servers, and notifies you whenever a new vulnerability is
discovered in a package you rely on.

[Sign up](https://appcanary.com/sign_up?utm_source=blog&utm_medium=web&utm_campaign=broken) today!
