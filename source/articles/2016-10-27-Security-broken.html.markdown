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
of Service attack from the
[Mirai](https://krebsonsecurity.com/2016/10/hacked-cameras-dvrs-powered-todays-massive-internet-outage/)
botnet which attacks Internet of Things devices like cameras. I've written about
the [Morris worm](https://blog.appcanary.com/2016/tale-of-two-worms.html) of
1988, and I wanted to dig into the
[source](https://github.com/jgamblin/Mirai-Source-Code) of the Mirai botnet
(helpfully published by the author) to see how the big worm of 2016 compares to
the big worm of 1988.

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

I was a security conference the other week, and there was a yet another crop of
cyberapocalypse talks. The Internet of Things is a disaster. Industrial control
systems are going to get us all killed. Users are clicking phishing links like
sheep. We're all doomed. And somehow, it's always the fault of shitty
programmers or dumb users. Let's all laugh at their fails.

Bullshit. Let's all pretend like the DNC and the State Department don't spend
big money on security and instead laugh at John Podesta's shitty
[password](http://www.politico.com/story/2016/10/john-podesta-cybersecurity-hacked-emails-230122).

There's a classic story[^apocryphal] about how NASA spent millions of dollars to
develop a space-pen that would work in zero gravity. The Soviets just packed a
pencil and called it a day. In order to justify the sticker price of $75 billion
dollars a year, we have to keep selling space-pens and ignore the real issues.
We sell biometric authentication systems to people who need a good password
manager. We sell live threat attribution intelligence with colorful maps to
people who need to practice configuration management. We sell advanced in-cpu
sandbox malware detection to people who need to institute a patching program.
There's a reason why security practitioners get such a kick out of
[ThreatButt](https://threatbutt.com/).

Don't get me wrong, there are a lot of important, conceptually hard problems in
security. They might even be intractable. But, right now, the majority of
attacks can be prevented with straightforward solutions. They're challenging to
implement, but they work. The problem is that you can't charge $75 billion a
year for straightforward things. So here we are selling bullshit and barely
making any progress in 28 years. Lot's of money in it though.

The straightforward things you can do is patching, secure configuration, and
making sure you have strong passwords/two factor authentication. The hard problems
are writing secure code and not getting socially engineered. Solve the first
three, and then you can focus on the Sisyphean tasks that are left.

---

#### Paying the Bills

Surprise, I'm selling you a security product too! But I will say this, Appcanary
isn't going to protect your from shipping millions of internet-accessible
cameras with the same password. We won't even protect your from having your DNS
provider DoSed.

The major botnet of 2016 is *simpler* than the botnet of 1988. There's something
wrong in how we do security, and at Appcanary, we think it's a complete lack of
focus on low-hanging fruit. 

The highest value, easiest thing you can do to improve your security is patch
known vulnerabilities. Most breaches come from years-old vulnerabilities. 

Our product,
[Appcanary](https://appcanary.com/?utm_source=blog&utm_medium=web&utm_campaign=broken),
monitors your apps and servers, and notifies you whenever a new vulnerability is
discovered in a package you rely on.

[Sign up](https://appcanary.com/sign_up?utm_source=blog&utm_medium=web&utm_campaign=broken) today!

[^apocryphal]: This story is probably
[apocryphal](http://mentalfloss.com/article/13103/russians-didnt-just-use-pencils-space),
but I just take that as evidence that it contains a deeper truth.
