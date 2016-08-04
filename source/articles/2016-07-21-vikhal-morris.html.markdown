---
title: "VIKHAL #2: The Morris Worm"
date: 2016-07-21
author: mveytsman
layout: post
published: true
tags: vikhal, security
---

![Morris Worm](images/morris_worm.jpg)

On November 2nd 1988 Robert Tappan Morris, a graduate student at Cornell,
executed some code he'd been working on and went to dinner. The aftermath was a
self-replicating computer worm that infected 10% of the Internet[^internet] at the time
&mdash; a whopping 6,000 computers!

Morris claimed that he wrote his program to map the size of the internet. And
indeed, each infection would send a byte to a machine in Berkeley
(further hiding the trail to Morris from Cornell as the author). Unfortunately,
there was a bug that caused it to propagate too aggressively and infect the same
computer multiple times, which resulted in a denial of service attack across the
whole Internet. Furthermore, the code to report infection had a bug in it. It tried to
send a UDP packet over a TCP socket, making it useless for reporting the internet's size.

An alternative explanation is that Morris was trying to bring to wider attention
some long-standing bugs in the internet. As Morris' friend and future co-founder
Paul Graham [put it](http://www.nytimes.com/1988/11/07/us/computer-invasion-back-door-ajar.html):

> Mr. Graham, who has known the younger Mr. Morris for several years, compared
> his exploit to that of Mathias Rust, the young German who flew light plane
> through Soviet air defenses in May 1987 and landed in Moscow.

> "It's as if [Mathias Rust](https://en.wikipedia.org/wiki/Mathias_Rust) had not just flown into Red Square, but built
> himself a stealth bomber by hand and then flown into Red Square," he said.

pg's mastery of the metaphor was unparalleled even then.

# What did the Morris Worm actually do?

The Morris Worm[^worm] exploited three separate vulnerabilities. It guessed
passwords for rsh/rexec, it exploited a debug-mode backdoor in sendmail and "one
very neat trick." You can see the (decompiled and commented) code [here](https://github.com/arialdomartini/morris-worm).


## Rsh and Rexec

`rsh` and `rexec` are remote shell protocols from the BSD era that are almost
unused today, having been supplanted by `ssh`. `rsh` can allow passwordless
authentication if coming from a "trusted" host. The file `/etc/hosts.equiv` and
per-user `.rhosts` files contain a list of addresses of trusted hosts. When an
`rsh` request comes from a user of a trusted machine, the user is automatically
granted access. The worm used this to propagate, searching for trusted hosts in
the above two files and in `.forward` which was used to forward your mail around
the Internet.

Even in 1988, people knew that leaving `rsh` open on an untrusted network like
the the Internet was a Bad Idea, and the worm also propogated via `rexec`.
`rexec` uses password authentication, but Morris made the intelligent assumption
that one person's accounts on different machines will share a password.
Back then, `/etc/passwd` would often[^shadow] store the encrypted user password. The
worm shipped with an optimized implementation of
[`crypt`](https://en.wikipedia.org/wiki/Crypt_(Unix)) and a dictionary used for
cracking local passwords. If it managed to crack a password it would try to log
in to likely hosts with it.

### What we've learned

Almost everywhere today, `/etc/passwd` is world readable, but doesn't contain
password hashes. `/etc/shadow` stores the hashes, but can only be read by
privileged users.  Besides implementing `/etc/shadow` widely since then, the `rsh`
attack demonstrates exploiting trust boundaries, and lateral movement, a common
feature of many attacks. Defense in depth is the principle that seeks to limit
compromise of the whole system after an attacker crossed an initial trust
boundary. This is one of the places where bringing security *really* sacrifices
usability, as authenticating yourself constantly is such a pain. Getting a small
foothold in a network and working your way in by exploiting trust almost always
works.

Halvar Flake made an interesting [argument](https://t.co/32DYninegR) that this
feature makes hacking especially addictive if we think of hacking as a kind of drug. With
something like cocaine, the more you do it, the lower the response curve and the
more you need. People spend their lives chasing the dragon. When exploiting
trust boundaries on the other hand you find that as you hack more systems, the
network of systems you're in because of trust is bigger. Each hit makes the next
hit more potent.


## Sendmail

The Morris Worm exploited an
[apparently deliberate](http://www.nytimes.com/1988/11/07/us/computer-invasion-back-door-ajar.html)
backdoor in Sendmail. Sendmail had a "debug" mode, that allowed you to route an
email to any process, including shell! Ironically, it was left as a backdoor to
get around annoying sysadmins that were too paranoid to give the author too much access.

> Eric Allman, a computer programmer who designed the mail program that Morris
> exploited, said yesterday that he created the back door to allow him to fine
> tune the program on a machine that an overzealous administrator would not give
> him access to. He said he forgot to remove the entry point before the program
> was widely distributed in 1985.

Sendmail used to have another similar backdoor called "wizard mode", where sending the strings "WIZ" and "SHELL" gave you a root shell. By the time that Morris was writing his worm wizard mode was disabled almost everywhere.

If you're wondering how sendmail could have backdoors like this, it seems that it was somewhat well known. This quote from a [mail](http://securitydigest.org/tcp-ip/archive/1988/11) by [Paul Vixie](https://en.wikipedia.org/wiki/Paul_Vixie) summarizes the situation.

```
From: vixie@decwrl.dec.com (Paul Vixie)
Newsgroups: comp.protocols.tcp-ip,comp.unix.wizards
Subject: Re: a holiday gift from Robert "wormer" Morris
Message-ID: <24@jove.dec.com>
Date: 6 Nov 88 19:36:10 GMT
References: <1698@cadre.dsl.PITTSBURGH.EDU> <2060@spdcc.COM>
Distribution: na
Organization: DEC Western Research Lab
Lines: 15


# the hole [in sendmail] was so obvious that i surmise that Morris
# was not the only one to discover it.  perhaps other less
# reproductively minded arpanetters have been having a field
# 'day' ever since this bsd release happened. 

I've known about it for a long time.  I thought it was common knowledge
and that the Internet was just a darned polite place.  (I think it _was_
common knowledge among the people who like to diddle the sendmail source.)

The bug in fingerd was a big surprise, though.  Overwriting a stack frame
on a remote machine with executable code is One Very Neat Trick.
-- 
Paul Vixie
Work:    vixie@decwrl.dec.com    decwrl!vixie    +1 415 853 6600
Play:    paul@vixie.sf.ca.us     vixie!paul      +1 415 864 7013

```

The internet was a polite place indeed! 

### What we've learned

Sendmail continued to be full of bugs for
[decades](https://www.cvedetails.com/vulnerability-list/vendor_id-31/Sendmail.html).
It turns out that writing a Mail Transport Agent is incredibly complicated and
full of peril.
[Daniel J. Bernstein](https://en.wikipedia.org/wiki/Daniel_J._Bernstein) went on
to write qmail as an secure alternative to sendmail. He has a great essay on
[why qmail is secure](https://cr.yp.to/qmail/guarantee.html) where he lists the
classes of vulnerabilities that MTAs can have and his approach to avoiding them.
Probably the biggest take-away is "Don't parse."

## One Very Neat Trick

The very neat trick that Vixie was talking about is a now-standard
[stack buffer overflow](https://en.wikipedia.org/wiki/Buffer_overflow)! It's
fascinating to read contemporary accounts that marvel at the cleverness of a class of
bugs that are now ubiquitous &mdash; although, for me at least, they haven't
lost their magic[^magic].

Here's the main routine from fingerd of that [era](http://minnie.tuhs.org/cgi-bin/utree.pl?file=4.3BSD/usr/src/etc/fingerd.c):

```c

main(argc, argv)
	char *argv[];
{
	register char *sp;
	char line[512];
	struct sockaddr_in sin;
	int i, p[2], pid, status;
	FILE *fp;
	char *av[4];

	i = sizeof (sin);
	if (getpeername(0, &sin, &i) < 0)
		fatal(argv[0], "getpeername");
	line[0] = '\0';
	gets(line);
	sp = line;
    // ... snip ...
    // build sp into arguments for finger and call /usr/ucb/finger via execv
    // putchar the result back to stdout
	return(0);
}

```


If you have experience with reading C code[^code], you may have spotted the
vulnerability. `gets(line)` reads STDIN and puts the contents into a 512 byte
buffer. This means that sending more than 512 bytes will overwrite the stack
with an attacker-controlled value.

The worm sent 536 bytes of data, which overwrote the
[stack frame](https://en.wikipedia.org/wiki/Call_stack#Stack_and_frame_pointers)
of the `main` function. This allowed Morris to overwrite the pointer to where
`main` is returning to. He set that pointer to be *within* the 536 byte buffer
he sent over the network. The beginning of the buffer contained
[shellcode](https://en.wikipedia.org/wiki/Shellcode) that called `/bin/sh`.

### What we've learned

The Morris worm is regarded as the earliest documented buffer overflow exploit, and it's been a cat and
mouse game ever since. We've tried banning `gets` and other dangerous functions,
but buffers can be overflown in more subtle ways. We've tried making it
impossible to execute code on the stack, but you can do
["return-oriented programming"](https://en.wikipedia.org/wiki/Return-oriented_programming)
to construct malicious code from "gadgets" made out of the existing code taken
out of context. It goes on and on.

One answer is using memory-safe languages for systems code, but that's just
scratching the surface. The question becomes, "how do I write secure code?" and
the answer is some combination of "Don't parse" and "Be djb."

# Aftermath

Robert Tappan Morris was convicted and sentenced to three years probation, 400
hours of community service and a $10,050 fine (about $20,000 in today's dollars)
plus the cost of his supervision. He then went on to found a little startup
called Viaweb with Paul Graham and Trevor Blackwell. After being acquired by
Yahoo, the three of them went on to start Y Combinator with Jessica Livingston.
Today, Morris is a tenured professor at the Computer Science and Artificial
Intelligence Laboratory at MIT. He's one of the leaders of the Parallel and
Distributed Systems Groups.

Paul Graham is now semi-retired from day-to-day operations of YC, but [Phill](https://twitter.com/phillmv) and
I had the chance to have an office hours with him while we were there. He loved
the idea of Appcanary but hated the name. He said "It's really too bad that it's
taken, because Oracle would be a great name for you! You know everything about
every vulnerability..."

As for the Internet, we all lost our innocence over the past 28 years, and it's
not just our assumptions about politeness when it comes to sendmail bugs. One
aspect of this story that continually fascinates me is that Robert Tappan
Morris' father is
[Robert Morris](https://en.wikipedia.org/wiki/Robert_Morris_(cryptographer)),
who at the time of the writing of the Morris Worm was **Chief Scientist at the
NSA's National Computer Security Center**. Imagine if today you found out about
a computer worm that used a never-before-published advanced exploitation
technique. And then you learned that the author was the son of the NSA's chief
computer security expert. What conclusion would you draw?


#### Paying the Bills

We're trying our best, but we'll only be able to blog about a minuscule percentage of the world's vulnerabilities. And starting with 1988 means we have a lot of catching up to do? How will you ever find about the ones that actually affect you?

Our product, [Appcanary](https://appcanary.com/?utm_source=blog&utm_medium=web&utm_campaign=symantec), monitors your apps and servers, and notifies you whenever a new vulnerability is discovered in a package you rely on. 

[Sign up](https://appcanary.com/sign_up?utm_source=blog&utm_medium=web&utm_campaign=symantec) today!

[^internet]: The 60,000 computer-strong Internet was of course one many networks at the time. The Internet was the one that was global and used TCP/IP &mdash; the Internet protocols. There in lies the pedant's case against the [AP](https://twitter.com/APStylebook/status/716279065888563200) about capitalization of the word "Internet".

[^worm]: My favourite paper on the analysis of the worm is [With Microscope and Tweezers](http://denninginstitute.com/modules/acmpkp/security/texts/INTWORM.PDF) from MIT's Eichin and Rochlis. They spend a page passionately arguing that it's a virus by using a complicated appeal to the difference between lytic and lysogenic viruses with references to three separate biology textbooks!

[^shadow]: I assumed that `/etc/shadow` came about as a consequence of the Morris Worm, but it [seems](https://en.wikipedia.org/wiki/Passwd#History) that it was originally implemented in SunOS earlier in the 80's, and then took 2 years after the Morris Worm to make it into BSD.

[^magic]: Exploits really are magic, and goes without saying that exploit users have chosen the [Left-Hand Path](https://en.wikipedia.org/wiki/Left-hand_path_and_right-hand_path) to wizardhood. If the [cover of SICP](https://mitpress.mit.edu/sicp/full-text/book/book.html) is to be believed, the Right-Hand Path is available through careful study of functional programming and Lisps. Perhaps this is the true reason why Morris and Graham were such effective collaborators.

[^code]: On the other hand, this C code is over 30 years old. When I ran it through the gcc on my machine, I was very happy to see that it complained bitterly but still compiled it. One exercise for the reader is where the network operation actually happens. `main` takes input and output from STDIN/STDOUT, but there's an uninitialized `struct sockaddr_in sin` that we call `getpeername` on. How is a network socket piped to standard input/output and who is initializing the `sin` struct? I actually haven't been able to figure this part out. If you know, please tell [me](mailto:max@appcanary.com)! The full code listing is [here](http://minnie.tuhs.org/cgi-bin/utree.pl?file=4.3BSD/usr/src/etc/fingerd.c).


