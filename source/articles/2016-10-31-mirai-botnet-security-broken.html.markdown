---
title: The Mirai Botnet is Proof the Security Industry is Broken
date: 2016-10-31
author: mveytsman
published: true
tags: security, mirai, botnet
layout: post
---

Last Friday, my workday was rudely interrupted because I couldn't access Github.
To add insult to injury I couldn't even complain about it on Twitter. I tried to
drown my sorrows by listening to moody Leonard Cohen songs on Spotify, but
alas...

You've probably heard of this. Huge tracts of the Internet were down because the DNS provider Dyn 
faced a massive Denial of Service attack from the
[Mirai botnet](https://krebsonsecurity.com/2016/10/hacked-cameras-dvrs-powered-todays-massive-internet-outage/), 
which takes advantage of Internet of Things devices like cameras and DVRs.

<p><blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">&quot;Oh &amp; also, evil sorcerers crippled our divination network Friday by getting millions of coffee makers &amp; lightswitches to shout real loud&quot; <a href="https://t.co/OPhdOJLwc1">https://t.co/OPhdOJLwc1</a></p>&mdash; Max Gladstone (@maxgladstone) <a href="https://twitter.com/maxgladstone/status/790890882543288320">October 25, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script></p>

### So, what's new about Mirai? 

I've written about
1988's [Morris worm](https://blog.appcanary.com/2016/tale-of-two-worms.html), 
and I wanted to dig into the
[source](https://github.com/jgamblin/Mirai-Source-Code) of the Mirai botnet
(helpfully published by the author) to see how far we've come along in the past
28 years.

Can you guess how Mirai spreads? 

Was there new zeroday in the devices? Hey, maybe there was an old, unpatched
vulnerability hanging &mdash; who has time to apply software updates to their toaster? 
Maybe it was HeartBleed 👻?

Nope.

Mirai does one, and only one thing in order to break into new devices: it cycles through a bunch of default
username/password combinations over telnet, like "admin/admin" and "root/realtek". For a
laugh, "mother/fucker" is in there too.

Default credentials. Over telnet. That's how you get hundreds of thousands of
[devices](http://dyn.com/blog/dyn-analysis-summary-of-friday-october-21-attack/).
The Morris worm from 1988 tried a dictionary password attack too, but only after
its buffer overflow and sendmail backdoor exploits failed. 

Oh, and Morris' password dictionary was larger, too.

### How do we keep getting this wrong?

Around the world, we spend $75 billion a year on information security.
And for what, when we keep getting such basic things wrong? Suppose I waved a
magic wand and cut the worldwide security budget in half. Would things really be
that much worse? The security industry is addicted to selling expensive
complicated products instead of doing the basics well. 

I was at a security conference the other week, and there was yet another crop of
cyberapocalypse talks. The Internet of Things is a garbage fire. Industrial control
systems are going to get us all killed. Users are clicking phishing links like
sheep. We're all doomed. And somehow, it's always the fault of shitty
programmers or dumb users. Let's all laugh at their fails.

### It's all bullshit. 

We sell biometric authentication systems to people who need a good password
manager. We sell live threat attribution intelligence with colorful maps to
people who need to practice configuration management. We sell advanced
in-cpu sandbox endpoint protection to people who need to institute a patching program.
There's a reason why security practitioners get such a kick out of
[ThreatButt](https://threatbutt.com/).

There are lots of real, important, conceptually difficult problems in
security. We don't really know how to write secure code, and it's all too
easy to get socially engineered. But, right now, the vast majority of threats can be thwarted by <b>the basics</b>:

1. Keep your systems patched
2. Keep your systems properly configured.
3. Make sure you have strong passwords and two factor authentication.

Do the basics first. The basics matter. Then you can focus on the Sisyphean
tasks that remain. Instead, here we are selling fancy bullshit and barely making
any progress in 28 years. Lots of money in it, though.

---

#### Paying the Bills

Surprise, I also sell a security product! But I will say this: Appcanary
isn't going to protect you from shipping millions of internet-accessible
cameras with the same password. We won't even protect you from having your DNS
provider DoSed.

The major botnet of 2016 is *simpler* than the botnet of 1988. There's something
wrong in how we do security, and at Appcanary, we think it's a complete lack of
focus on the basics. 

The highest value, easiest thing you can do to improve your security is patch
known vulnerabilities. Most breaches come from years-old vulnerabilities. 

Our product,
[Appcanary](https://appcanary.com/?utm_source=blog&utm_medium=web&utm_campaign=broken),
monitors your apps and servers, and notifies you whenever a new vulnerability is
discovered in a package you rely on.

[Sign up](https://appcanary.com/sign_up?utm_source=blog&utm_medium=web&utm_campaign=broken) today!
