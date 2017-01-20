---
title: "Improve Your Security: Port Scan Yourself"
date: 2017-01-16
author: mveytsman
layout: post
published: false
thumbnail: images/canary_ledger.png
tags: Security, Programming
---

Ransomware crews are no longer satisfied [shutting down hospitals](https://www.wired.com/2016/03/ransomware-why-hospitals-are-the-perfect-targets/) and are now also going after hip tech startups. Last week, a professional crew got involved in [ransoming MongoDB instances](https://www.bleepingcomputer.com/news/security/mongodb-apocalypse-professional-ransomware-group-gets-involved-infections-reach-28k-servers/), and some 28,000 servers were compromised and held for Bitcoin.

The "attack" is so simple it barely deserves the name. The crew scans the internet looking for open and unsecured instances of MongoDB. When they find one, they log in and steal the data. The victims must pay Bitcoin to get their data back. To save on storage costs, sometimes the crew just deletes the data without bothering to save it &mdash; and the mark ends up paying for nothing. Even honor among thieves can't survive the harsh realities of 21st century globalized late cyber-capitalism.

When reading about these attacks, there is a strong temptation blame the victim. Hospitals were at fault because of their antiquated IT departments: huge, sclerotic fiefdoms incapable of moving past Windows 98. We all know that MongoDB [sucks](http://cryto.net/~joepie91/blog/2015/07/19/why-you-should-never-ever-ever-use-mongodb/), and that [Real Programmers](http://www.catb.org/jargon/html/story-of-mel.html) would never be caught dead using it. Why, they probably _deserved_ to get hacked!

Don't do it. As I've said before, victim-blaming in security is a [trap that must be avoided](https://blog.appcanary.com/2016/mirai-botnet-security-broken.html). Attacks are varied and always changing; best practices can be indistinguishable from cargo cults, and default configurations seem almost designed to foil you.

In this case, MongoDB apparently ships without any authentication, listening to the whole wide world. No wonder so many instances got hacked!

## HOWTO not get hacked

Basically, you should have as little as possible accessible to the outside world. Set up a firewall. This tweet sums up the idea best:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">If Postgres, MySQL, memcached, redis, etc responds to commands from outside the VPN/firewall/etc, assume you will lose your deployment.</p>&mdash; Patrick McKenzie (@patio11) <a href="https://twitter.com/patio11/status/818728480661590018">January 10, 2017</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

I'm not going to tell you how to set up a firewall. What I'm going to tell you is how to answer the question you have when reading that tweet: "is my firewall actually working right?"

### Enter Nmap

![trinity using Nmap](images/trinity_nmap.jpg "NMAP as used in The Matrix")

[Nmap](https://nmap.org/) is an incredibly powerful tool that's [synonymous](https://nmap.org/movies/) with port scanning. A port scanner is a program that checks to see what network ports are open on a computer.

Here's what scanning [appcanary.com](https://appcanary.com) with default settings from my work computer looks like:

```
$ nmap appcanary.com

Starting Nmap 7.12 ( https://nmap.org ) at 2017-01-16 12:57 EST
Nmap scan report for appcanary.com (45.55.197.253)
Host is up (0.030s latency).
Not shown: 993 closed ports
PORT    STATE    SERVICE
22/tcp  open     ssh
25/tcp  filtered smtp
80/tcp  open     http
135/tcp filtered msrpc
139/tcp filtered netbios-ssn
443/tcp open     https
445/tcp filtered microsoft-ds
```

You'll see that 22, 80, and 443 are open. This is because we listen on SSH, HTTP and HTTPS. There are also a bunch of filtered ports. This is because some router or firewall between me and appcanary is blocking that port so it's not clear whether it's open or closed. 

Running the same scan from a random[^oldnmap] Digital Ocean box gives me the true result without the intermediate network filtering.

```
Starting Nmap 5.21 ( http://nmap.org ) at 2017-01-16 13:04 EST
Nmap scan report for appcanary.com (45.55.197.253)
Host is up (0.0012s latency).
Not shown: 997 closed ports
PORT    STATE SERVICE
22/tcp  open  ssh
80/tcp  open  http
443/tcp open  https
```

Nmap has a variety of [scanning options](https://nmap.org/book/man-port-scanning-techniques.html), but the most important thing to understand for TCP scans is the difference between SYN scanning and connect scanning.

If you've ever tried to write a port scanner (which is a great exercise in network programming and concurrency), you've probably tried to write a connect scanner. A connect scanner tries to connect to a port, and closes the connection after success. Nmap's most popular mode is SYN scanning. In SYN scanning, you send a SYN packet initiating the [TCP handshake](https://en.wikipedia.org/wiki/Transmission_Control_Protocol#Connection_establishment). If you get an SYN-ACK back, the port is open, and you send a RST instead of an ACK as you would if you were actually connecting. This is "stealthier", which doesn't matter as much for our purposes, and is more efficient. Unfortunately it requires nmap to be run as root because it needs raw access to the network interface.

You can specify a SYN scan with `nmap -sS`, and a connect scan with `nmap -sT`. By default nmap will prefer to do a SYN scan if it is able to.

By default, nmap will scan the top 1000 most common ports. You can specify a specific ports or a range with `-p`, i.e. `nmap -p22` will scan only port 22, and `nmap -p400-500` will scan ports 400 through 500. `nmap -p-` will scan the complete port range (1-65535).


### Developer, port scan thyself

Regularly port scan yourself; it's the only way to be certain your processes are not listening to untoward calls from ungentlemanly visitors. Run Nmap against your servers, and make sure that only the ports you expect are open. 

To make it easier, here's a script to do it for you. This will run Nmap, compare the output with predefined ports, and ping you on Slack if there's a mismatch. Run it on a cron job, so you can check on the regular.


<script src="https://gist.github.com/mveytsman/7a3366e69401fae6e9a4f9eaf0d3f9b1.js"></script>

## How does Appcanary fit in?

Our mission is to help you do security basics right, so you can be free to worry about the hard stuff. We're building the [world's best patch management product](https://appcanary.com) because we had a deep need for one ourselves, and it automated such a vital part of a security team's job.

When I started writing this article, I didn't realize how well it fit into what we're doing with patch management. To do security right, you need to implement systems and continuously verify they are working correctly. [Appcanary](https://appcanary.com) helps you verify your patch management program, the script above helps you verify your firewall. Both without any bullshit.

We're considering incorporating automated port scanning into our product. We want to hear from you if you're also convinced it's necessary. Let me know: [max@appcanary.com](mailto:max@appcanary.com).

[^oldnmap]: If you're observant, you may have noticed that this version of nmap is much older than the one on my work computer. If you're really observant, you may have noticed that it has a [vulnerability](https://appcanary.com/vulns/35319).
