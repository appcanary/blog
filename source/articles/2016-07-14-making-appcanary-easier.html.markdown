---
title: Making Appcanary easier to use
date: 2016-07-14
author: mveytsman
layout: post
published: true
tags: Announcements, Product
---

I'm excited to announce that we've added two features that make Appcanary a heck of a lot easier to use!

## Add monitors by uploading a file

Our Monitor API is great if you want to track a set of Linux packages or your Gemfile. We give you a dashboard showing which packages are vulnerable, and email you whenever new vulnerabilities that affect you come out. However, there's always a bunch of setup to get a new API going.

With that in mind, we made the interface a lot more user friendly! You can now upload a file to watch directly through the website. Just go to [add monitors](https://appcanary.com/monitors/new) to be able to upload a file directly. Monitors support Ruby's `Gemfile.lock`, `/var/lib/dpkg/status` for Ubuntu and Debian, and the output of `rpm -qa` for Centos and Amazon Linux!

## Automatically upgrade vulnerable packages

A few of our customers told us that knowing about vulnerabilities is nice, but you know what would be *great*? If we could somehow _patch_ them automatically. We thought about it and said, sure, why not!

If you have the Appcanary [agent]((https://appcanary.com/servers/new)) installed on an Ubuntu server, and you're running the latest version, you can run 

~~~
appcanary upgrade
~~~

in order to install updates for any packages we know to be vulnerable.

You can also run

~~~
appcanary upgrade -dry-run
~~~

in order to see what the agent will do, without it actually touching your system. 

Now you can manage vulnerabilities, learn about new ones that affect you, and apply patches, all through Appcanary!

#### If you haven't tried us yet

Stay on top of the security vulnerabilities that affect you, today.

[Appcanary](https://appcanary.com/?utm_source=blog&utm_medium=web&utm_campaign=making_easier), monitors your apps and servers, and notifies you whenever a new vulnerability is discovered in a package you rely on. And now it will help you patch vulnerable packages as well.

[Sign up](https://appcanary.com/sign_up?utm_source=blog&utm_medium=web&utm_campaign=making_easier) today!
