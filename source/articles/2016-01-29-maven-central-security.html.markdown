---
title: Maven Central Security
date: 2016-01-29
tags: Java, Maven, Clojure, Programming, Security, Talks
author: mveytsman
published: true
layout: post
---
The security of your package manager is very important to us at appcanary, and it’s important to make sure the packages you’re downloading are secure in transit.

Back in the summer of 2014, I discovered that [Maven Central](http://search.maven.org/)  wasn’t using TLS or any signature verification when serving up java packages.

I gave a talk at [!!con 2015](http://bangbangcon.com/index.html) about what I did to help convince them to start using encryption.

<iframe width="560" height="315" src="https://www.youtube.com/embed/6NdLZl16OkA" frameborder="0" allowfullscreen></iframe>
