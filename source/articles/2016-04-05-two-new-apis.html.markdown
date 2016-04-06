---
title: Two new APIs from Appcanary
date: 2016-04-05
tags: Announcements, Product
author: mveytsman
published: true
layout: post
---

After the success of our [Check API](http://blog.appcanary.com/2016/new-api-centos-support.html), we found that our users told us:

>"I really like your API! But what if I could... register the packages my app uses and get a notification when I'm affected by vulnerabilities? While you're at it, it'd be nice if I could progamatically query the servers I have agents running on!"

So we went ahead and built both.

## The Monitor API

The Monitor API lets you register a Gemfile or an Ubuntu/CentOS package list. Whenever they're affected by a new vulnerability, you get an email. It's just like running our agent, but with the flexibility to mold it to your deployment process - i.e. for those of you who use Docker or a PaaS like Heroku.

You can register a new monitor by simply issuing a POST:

```bash
curl -H "Authorization: Token YOURTOKENHERE" \
     -X POST -F file=@./Gemfile.lock \
     https://appcanary.com/api/v2/monitors/my-great-app?platform=ruby
```

and you'll get a response like:

```json
{
  "data": {
    "type": "monitor",
    "attributes": {
      "name": "my-server",
      "uuid": "56eac124-35c2-49bd-ab02-45de56c03ef4",
      "vulnerable": true
    }
  }
}
```

That's all it takes. From here on, you'll be emailed about any vulnerabilities that affect your app as soon as we find out about them!

You can also list, inspect, or delete monitors via the API. More information [here](https://appcanary.com/docs#create-monitor).


## The Server API

The Server API allows you to inspect the servers running the Appcanary agent, and list any vulnerabilities that affect them!

I can see the servers I have agents running on with:

```bash
curl -H "Authorization: Token YOURTOKENHERE" \
      https://appcanary.com/api/v2/servers
```

and you'll get a response like:

```json
{
  "data": [
    {
      "type": "server",
      "attributes": {
        "name": "server1",
        "uuid": "55a5baeb-2ad4-4787-8784-a062d254900e",
        "hostname": "server1",
        "last-heartbeat-at": "2016-03-27T03:33:02.185Z",
        "vulnerable": true,
        "apps": [
          {
            "type": "app",
            "attributes": {
              "name": "",
              "path": "/var/lib/dpkg/status",
              "uuid": "55a5baec-3e5c-4cca-832c-06aaa36418f6",
              "vulnerable": true
            }
          },
          {
            "type": "app",
            "attributes": {
              "name": "",
              "path": "/var/www/myapp/current/Gemfile.lock",
              "uuid": "55a5baec-027d-4618-b8de-12638281f34c",
              "vulnerable": true
            }
          }
        ]
      }
    },
    {
      "type": "server",
      "attributes": {
        "name": "server2",
        "uuid": "560b0e75-1317-481c-98bb-15e6ae5978b6",
        "hostname": "database",
        "last-heartbeat-at": "2016-03-08T00:21:31.105Z",
        "vulnerable": true,
        "apps": [
          {
            "type": "app",
            "attributes": {
              "name": "",
              "path": "/var/lib/dpkg/status",
              "uuid": "560b0e77-0a26-41fd-bc35-38b5aac33709",
              "vulnerable": true
            }
          }
        ]
      }
    }
  ]
}
```

You can also inspect or delete any server with an agent on it via the API.

Our API fully supports **Ruby**, **Ubuntu**, and **CentOS 7**! You can learn more about how to use it by visiting [the docs page](https://appcanary.com/docs).

You'll have to [sign up](https://appcanary.com/sign_up) to use our APIs. We're currently not charging for them as we keep them in beta, but you can expect pricing similar to our pricing for agents.
