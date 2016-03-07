---
title: Announcing CentOS support and an API 
date: 2016-03-07
tags: Announcements, Product
author: mveytsman
published: true
layout: post
---
We've got two big announcements this month.

## CentOS 7 Support

Appcanary now fully supports **CentoOS 7**. If you install our agent on a CentOS 7
server, we will email you notifications whenever any rpm package you have
installed on your system has a known vulnerability.

## We're betaing an API

We've gotten a lot of feedback from our users that they want to use Appcanary as an API, so we put one out! 

We're running a free beta of it for now, so we won't charge you for it if you're just using the API.

All you have to do is 

```
curl -H "Authorization: Token YOURTOKENHERE" \
     -X POST -F file=@./Gemfile.lock \
     https://appcanary.com/api/v2/check/ruby
```

and you'll get a response like:

```
{
  "vulnerable": true,
  "data": [
    {
      "type": "artifact-version",
      "attributes": {
        "name": "rack",
        "kind": "rubygem",
        "number": "1.6.0",
        "vulnerabilities": [
          {
            "title": "Potential Denial of Service Vulnerability in Rack",
            "description": "Carefully crafted requests can cause a `SystemStackError` and potentially \ncause a denial of service attack. \n\nAll users running an affected release should upgrade.",
            "criticality": "high",
            "cve": [
              "CVE-2015-3225"
            ],
            "osvdb": [],
            "patched-versions": [
              "~< 1.5.4",
              "~< 1.4.6",
              ">= 1.6.2"
            ],
            "unaffected-versions": [],
            "uuid": "55807540-053f-40f0-9266-a3d1ca6a5838",
            "upgrade-to": [
              ">= 1.6.2"
            ]
          }
        ]
      }
    }
  ]
}
```

Our API fully supports **Ruby**, **Ubuntu**, and **CentOS 7**! You can learn more about how to use it [https://appcanary.com/docs](https://appcanary.com/docs)

If you're not a current user and want to try out Appcanary's API and/or use us to monitor your CentOS 7 servers, you can [sign up](https://appcanary.com/signup)!

You can always let us know what you think at [hello@appcanary.com](mailto:hello@appcanary.com)!
