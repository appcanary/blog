---
title: "Vulnerabilities I Have Known and Loved #1: Symantec's Bad Week"
date: 2016-07-07
author: mveytsman
layout: post
published: true
tags: vikhal, security
---

**tl;dr:** If you use software with "Symantec" or "Norton" somewhere in its name, **stop what you're doing and [upgrade](https://www.symantec.com/support-center/upgrades)**.

Back in my security consulting days, a mentor taught me One Weird Trick to
increase conversions on your phishing campaign.  It goes like this: set up an email server, get as many employee addresses you can find, and spoof a mass message that reads:

> Hello this is your boss. 

> I'm going to fire someone next week and you get to vote on who! To get your arch-nemisis fired, please log into this website that looks exactly like our company portal, but has one character in the domain name mispelled. 

> Thanks, Your Boss.
 
Then you sit back and count how many people fell for it.

The executive who hired you is happy because they get to demonstrate the value of increasing their
security budget. The consultancy you work for is happy, because they get to upsell a bunch of "security awareness
training". 

Soon, you'll be spending three days telling your victims about the
importance of that little green lock in their browser's address bar (but only
when it's in the right place!) and that they should never ever click on links,
never open attachments, and if at all possible, stop using computers altogether. Everybody wins.

Obviously, everyone at this stage wants to increase the conversion rate[^1] of these phishing emails. This is where The One Weird Trick comes in: after you send out your first campaign, you craft another one. Before you know it, everyone on your list receives a helpful tip from the IT Helpdesk:

> Hi, 

> We've heard reports of a phishing campaign being waged against us. Don't open those emails! It's critically important that you reset your password to protect against those evil hackers who tried to phish us. 

> Click here to do it!

It turns out that round two gets *way* more clicks than round one. Most people will figure out that email #1 is a little fishy. Email #2 manages to reaffirm that, and so they dutifully click, like lambs to slaughter.

This is the phishing equivalent of the Double Tap. No, not the one from [Zombieland](https://www.youtube.com/watch?v=w4sWxsrEFFs). The Double Tap I'm talking about is a controversial [military technique](http://www.businessinsider.com/drone-double-tap-first-responders-2012-9) where after attacking a target, you follow up by sending another missile at the first responders. You do some damage, and then attack the response to that damage.

The Symantec vulnerabilities reminded me of phishing and the Double Tap for two reasons. First of all, all of these vulns are exploitable just by sending an email. No need to get your target to click a link or even open the email you send &mdash; Symantec will happily try to parse every email you receive. Secondly, one of the vulns does a Double Tap-like attack where it pretends to be a certain kind of malware first, in order to trigger some non-default checks from Symantec, which is where the vulnerable code path lies. More on this later.

### Symantec is Having a Bad Week

Last week [Tavis Ormandy](https://twitter.com/taviso) dropped 8 vulns against every single Symantec/Norton antivirus product. Judging by [the press](http://fortune.com/2016/07/02/symantec-security-irony/), things are [not looking good](http://www.pcworld.com/article/3089463/security/wormable-flaws-in-symantec-products-expose-millions-of-computers-to-hacking.html) for them.

Once again, if you're using a Symantec product I can't stress this enough: **stop what you're doing and [upgrade](https://www.symantec.com/support-center/upgrades)**.

You can find a writeup up on the [Google Project Zero
blog](http://googleprojectzero.blogspot.ca/2016/06/how-to-compromise-enterprise-endpoint.html), and the issues for all 8 vulnerabilities can [be found here](https://bugs.chromium.org/p/project-zero/issues/list?can=1&q=label%3AVendor-Symantec). They're all remotely exploitable,[^2] and they all should give an attacker remote code execution as root/SYSTEM (and in ring 0 for one of them to boot!)

Since the product is an antivirus, so it's going to scan every file that touches your
disk and every email you get for viruses. Which means that you can exploit these
vulnerabilities simply by sending someone an email or getting them to click a
link (did I mention you should
[upgrade](https://www.symantec.com/support-center/upgrades)?)

The one that made me think of the Double Tap is a stack overflow in Symantec's PowerPoint parser. This parser is used to extract metadata and macros from PowerPoint decks (and presumably scan them for known malware). The parser exposes an I/O abstraction layer for these, and buffers date for performance. Tavis found that he could get that cache into a misaligned state, which resulted in a stack buffer overflow. The full writeup and exploit is [here](https://bugs.chromium.org/p/project-zero/issues/detail?id=823&can=1&q=label%3AVendor-Symantec).

What's interesting about it is that the vulnerable codepath is in something called “Bloodhound Heuristics”. These aren't run by default, so you'd think the vulnerability wouldn't be exploitable on a default configuration. It is. The default setting is "Automatic," which decides which checks to run dynamically. All Tavis had to do was try a bunch of known PowerPoint malware, see which one triggered the automatic mode to turn on "Bloodhound Heuristics," and put his payload into them. 

The exploit pretends to be a certain kind of known malware in order to trigger some special aggressive checks, which are the exploit's true target. The Double Tap!

### Vulnerability Management

While the above vulnerability is pretty cool, the Symantec bugs that are most interesting to us at Appcanary are [CVE-2016-2207](https://bugs.chromium.org/p/project-zero/issues/detail?id=810) and [CVE-2016-2211](https://bugs.chromium.org/p/project-zero/issues/detail?id=816). 

Symantec was shipping it's product with out of date versions of [libmspack](http://www.cabextract.org.uk/libmspack/) and [unrarsrc](http://www.rarlab.com/rar_add.htm). Out of date versions that have dozens of known vulnerabilities with public exploits! All Tavis had to do was download public exploits for these known vulnerabilities, and he had an attack against Symantec.

Symantec was using open source libraries with known security vulnerabilities in them, and they sell a product called Enterprise Vulnerability Management! This is a hard problem for everyone, and at Appcanary, we're trying to make it a little easier.


### Want more of these?

We're going to make this a regular feature on the blog. We'll be writing explainers for classic security vulnerabilities with a focus on historical significance or interesting techniques. Next up will be the [Morris Worm](https://en.wikipedia.org/wiki/Morris_worm).

If you want to sign up to get notifications about new ones, you can subscribe to our newsletter [here](http://eepurl.com/b82xK9), or follow us on [twitter](https://twitter.com/appcanary).

Have any suggestions for vulnerabilities you'd like me to write about? You can let me know at [max@appcanary.com](mailto:max@appcanary.com).

### Paying the Bills

One quarter of the critical vulnerabilities found in Symantec's products last week were there because they relied on out-of-date libraries with known security holes.

Our product, [Appcanary](https://appcanary.com/?utm_source=blog&utm_medium=web&utm_campaign=compress), monitors your apps and servers, and notifies you whenever a new vulnerability is discovered in a package you rely on. 

[Sign up](https://appcanary.com/sign_up?utm_source=blog&utm_medium=web&utm_campaign=symantec) today!

[^1]: You know, it's interesting that before I became the CEO of a startup, the only time I thought about "conversion rates" of emails in my career was when I was involved in phishing campaigns.
[^2]: I'm going to well-actually myself here so you don't have to. Tavis gives a clear path to exploit for 6 of the 8. Of the two that are left, [one](https://bugs.chromium.org/p/project-zero/issues/detail?id=821) is a lack of bounds checking on an array index, and the [other](https://bugs.chromium.org/p/project-zero/issues/detail?id=819) is an integer overflow bug. I'm going to go out on a limb and say I think both can lead to code execution. I can't fault the researcher for not going further though, after you find the first 6 remote code executions, you stop feeling the need to keep proving the point...
