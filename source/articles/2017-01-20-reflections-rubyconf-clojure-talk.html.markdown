---
title: Reflections on my Rubyconf Clojure talk
date: 2017-01-20
author: phillmv 
layout: post
published: true
tags: Ruby, Clojure, Programming, Talk, video

---

Back in [October 2016](https://blog.appcanary.com/2016/missing-clojure.html), we switched our production app from Clojure to Ruby. 

In November, I summarized our experience as a talk at Rubyconf:

<iframe width="640" height="360" src="https://www.youtube.com/embed/doZ0XAc9Wtc?rel=0" frameborder="0" allowfullscreen></iframe>

This was my first talk; talks are tricky! Here are some quick lessons I learned:

## 1. You're telling a story

When I began writing this talk, all I really had was a series of observations. Clojure is alright, but I found it frustrating. Rewriting your app is usually a bad idea, but we did it anyways! 

I knew I had something interesting to say, but I spent a lot of time feeling unsure of how I was going to tie it all together.

It turns out that the easiest way to hold someone's attention is to build a narrative arc. You introduce some characters, they encounter a challenge, there's a pay off at the end. Once I realized I could tell frame it within the story of our company, the rest of the talk became a lot easier.

## 2. You get maybe three ideas

Talks are low density mediums. If you want people to _learn_ something, you get about three discrete chances to imprint something in people's skulls.

You need to focus on those three ideas, and repeat yourself over and over again. Be brief and clear when writing; pack in a lot of redundancy when speaking.

## 3. You should prepare for _all_ of your audiences

During the writing process, I thought a lot about the people attending Rubyconf. 

I assumed they would be medium-experienced developers with little to no experience with Clojure; I assumed they would be fairly comfortable with Ruby. Doing a deep dive on the intricacies of lein, Clojure tooling writ large, the JVM ecosystem, etc, felt somewhat off-topic. We made the decision to leave that ecosystem because we had to fix some architectural assumptions, and we just had far more experience dealing with Ruby; I wanted people to leave with a good impression of the interesting ideas I'd picked up from my time working with Clojure.

We drove down to Ohio, my time slot came up, I vomited all the words I had within me, and afterwards people lined up to chat and ask interesting questions. Went just fine!

What I forgot to account for were the people most likely to be interested in the topic: current Clojurists watching the video online.

_That_ audience, for obvious reasons!, was less inclined to cut me some slack. I mean, here's some random asshole shitting on something you love. Some people watched this talk with an... uncharitable stance in their hearts and proceeded to be unhappy. To them, I think my critiques came across as shallow.

If I could redo this talk, I would provide a little more context, and try to anticipate and defuse that audience's emotional reactions. We all can stand to be better at being kind.

## 4. It's a lot of work!

I spent maybe a week worrying about these slides. I rehearsed it at least six times.

Talks _seem_ like they should be easy - and they get easier - but even the experienced talk writers I spoke to say it takes them at least three days to churn out a talk.
