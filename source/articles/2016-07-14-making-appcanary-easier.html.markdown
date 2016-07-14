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

Our Monitor API is great if you want to track a set of Linux packages or your Gemfile. We give you a dashboard showing which packages are vulnerable, and email you whenever new vulnerabilities that affect you come out. Unfortunately, it can be a bit hard to create a new monitor using the bare API, you have to POST a file to an endpoint using curl. Until today.

We made the Monitor API a lot more user friendly! You can now upload a file to watch directly through the website. Just go to [add monitors](https://appcanary.com/monitors/new) to be able to upload a file directly. Monitors support Ruby's `Gemfile.lock`, `/var/lib/dpkg/status` for Ubuntu and Debian, and the output of `rpm -qa` for Centos and Amazon Linux!

## Automatically upgrade vulnerable packages

We get a lot of users asking us what to do when they find out a list of vulnerable packages from Appcanary, and we made acting a lot easier for users of our [agent](https://appcanary.com/servers/new). 

If you have the Appcanary agent installed on an Ubuntu server, and upgraded to the latest version, you can run 

```
appcanary upgrade
```

in order to upgrade any packages we know to be vulnerable!

You can also running

```
appcanary upgrade -dry-run
```

in order to see what the agent will do, without it actually upgrading anything. 

Now you can manage vulnerabilities, learn about new ones that affect you, and apply patches, all through Appcanary!

#### If you haven't tried it

Does the above sound interesting?

[Appcanary](https://appcanary.com/?utm_source=blog&utm_medium=web&utm_campaign=making_easier), monitors your apps and servers, and notifies you whenever a new vulnerability is discovered in a package you rely on. And now it will help you patch vulnerable packages as well.

[Sign up](https://appcanary.com/sign_up?utm_source=blog&utm_medium=web&utm_campaign=making_easier) today!
