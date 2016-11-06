---
title: Everything you've ever wanted to know about secure headers 
author: mveytsman
layout: post
published: false
---

This guide isn't as exhaustive as the MDN I link to. Is "A Primer on Secure Headers" better.


- Content Security Policy (CSP) 
Originally proposed in 2004 by RSnake. First standard 2012, current version is from 2015.
Helps detect/prevent XSS, mixed-content, and other classes of attack.  [CSP 2 Specification](http://www.w3.org/TR/CSP2/)


- X-XSS-Protection - [Cross site scripting heuristic filter for IE/Chrome](https://msdn.microsoft.com/en-us/library/dd565647\(v=vs.85\).aspx)

- X-Download-Options - [Prevent file downloads opening](https://msdn.microsoft.com/library/jj542450(v=vs.85).aspx)
- X-Permitted-Cross-Domain-Policies - [Restrict Adobe Flash Player's access to data](https://www.adobe.com/devnet/adobe-media-server/articles/cross-domain-xml-for-streaming.html)
- Referrer-Policy - [Referrer Policy draft](https://w3c.github.io/webappsec-referrer-policy/)
- Public Key Pinning - Pin certificate fingerprints in the browser to prevent man-in-the-middle attacks due to compromised Certificate Authorities. [Public Key Pinning Specification](https://tools.ietf.org/html/rfc7469)

- Cookies 
 - Secure
 - HttpOnly
 - SameSite




### X-XSS-Protection

```
Strict-Transport-Security: max-age=<expire-time>
Strict-Transport-Security: max-age=<expire-time>; includeSubDomains
Strict-Transport-Security: max-age=<expire-time>; preload
```

#### Why?

There are two problems when you want to communicate with someone securely. One
is encryption &mdash; making sure the messages you're sending are only visible
to you and them, and no one else. The other one is authentication &mdash; making
sure you're actually communicating with the person you think you are.

HTTPS is good at the first one, and has major problems with the second (more on
this later, Public Key Pinning). HSTS solves the meta-problem: how do you know
if the person you're talking to actually supports encryption?

The attack is called [sslstrip](https://moxie.org/software/sslstrip/). If you're
on a hostile network an attacker can just disable encryption between you and the
websites you're browsing. Even if the site you're accessing is only available
over HTTPS, an attacker that owns the wifi router you're using can just
man-in-the-middle the HTTP traffic and make it look like the site works over
unencrypted HTTP. No need for SSL certs, just disable the encryption.

Enter the HSTS. The `Strict-Transport-Security` header solves this by letting
your browser know to always use encryption with your site. As long as the
browser saw the HSTS header and it's not expired, it will not access the site
unencrypted, and will error out if it's not available over HTTPS.

#### Should I use it? 

Yes. Your app is only available over HTTPS, right? Trying to browse over regular
old HTTP will redirect to the secure site, right? Use
[letsencrypt](https://letsencrypt.org/) if you can't afford a certificate.

The one downside is that HSTS allows for a
[clever technique](http://www.radicalresearch.co.uk/lab/hstssupercookies) to
create supercookies to fingerprint your users. But, you're a website operator,
so the prospect of invading your users privacy doesn't bother you, does it?
Anyways, I'm sure you will use HSTS for good and not for supercookies.

#### How?

The two options are

- `includeSubDomains` - HSTS applies to subdomains
- `preload` - Google maintains a [service](https://hstspreload.appspot.com/)
  that hardcodes[^filters] your site as being HTTPS only into browsers. This way, a user
  doesn't even have to visit your site at all to opt in for HSTS. Getting off that list is hard by the way, so turn it on if you know you can support HTTPS forever on all subdomains.
  

<table>
  <thead>
    <th>Platform</th>
    <th>What do I do?</th>
  </thead>
  <tbody>
    <tr>
      <td>Rails 4</td>
      <td><code>config.force_ssl = true</code>
      <br/>Does not include subdomains by default. To set it:
      <br/><code>config.ssl_options = { hsts: { subdomains: true } }</td>
    </tr>
    <tr>
      <td>Rails 5</td>
      <td><code>config.force_ssl = true</code></td>
    </tr>
    <tr>
      <td>Django</td>
      <td><code>SECURE_HSTS_SECONDS = 31536000</code>
        <code>SECURE_HSTS_INCLUDE_SUBDOMAINS = True</code>
      </td>
      </td>
    </tr>
    <tr>
    <tr>
      <td>Express.js</td>
      <td>Use <a href="https://www.npmjs.com/package/helmet">helmet</a></td>
    </tr>
    <tr>
      <td>Golang</td>
      <td>Use <a href="https://github.com/unrolled/secure">unrolled/secure</td>
    </tr>
    <tr>
      <td>Nginx</td>
      <td>
        <code>add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; ";</code>
      </td>
    </tr>
    <tr>
      <td>Apache</td>
      <td><code>Header always set Strict-Transport-Security "max-age=31536000; includeSubdomains;"</code></td>
    </tr>
  </tbody>
</table>



#### I want to know more

- [RFC 6797](https://tools.ietf.org/html/rfc6797)
- [Strict-Transport-Security - MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)

---



### HTTP Strict Transport Security (HSTS)

```
Strict-Transport-Security: max-age=<expire-time>
Strict-Transport-Security: max-age=<expire-time>; includeSubDomains
Strict-Transport-Security: max-age=<expire-time>; preload
```

#### Why?

There are two problems when you want to communicate with someone securely. One
is encryption &mdash; making sure the messages you're sending are only visible
to you and them, and no one else. The other one is authentication &mdash; making
sure you're actually communicating with the person you think you are.

HTTPS is good at the first one, and has major problems with the second (more on
this later, Public Key Pinning). HSTS solves the meta-problem: how do you know
if the person you're talking to actually supports encryption?

The attack is called [sslstrip](https://moxie.org/software/sslstrip/). If you're
on a hostile network an attacker can just disable encryption between you and the
websites you're browsing. Even if the site you're accessing is only available
over HTTPS, an attacker that owns the wifi router you're using can just
man-in-the-middle the HTTP traffic and make it look like the site works over
unencrypted HTTP. No need for SSL certs, just disable the encryption.

Enter the HSTS. The `Strict-Transport-Security` header solves this by letting
your browser know to always use encryption with your site. As long as the
browser saw the HSTS header and it's not expired, it will not access the site
unencrypted, and will error out if it's not available over HTTPS.

#### Should I use it? 

Yes. Your app is only available over HTTPS, right? Trying to browse over regular
old HTTP will redirect to the secure site, right? Use
[letsencrypt](https://letsencrypt.org/) if you can't afford a certificate.

The one downside is that HSTS allows for a
[clever technique](http://www.radicalresearch.co.uk/lab/hstssupercookies) to
create supercookies to fingerprint your users. But, you're a website operator,
so the prospect of invading your users privacy doesn't bother you, does it?
Anyways, I'm sure you will use HSTS for good and not for supercookies.

#### How?

The two options are

- `includeSubDomains` - HSTS applies to subdomains
- `preload` - Google maintains a [service](https://hstspreload.appspot.com/)
  that hardcodes[^filters] your site as being HTTPS only into browsers. This way, a user
  doesn't even have to visit your site at all to opt in for HSTS. Getting off that list is hard by the way, so turn it on if you know you can support HTTPS forever on all subdomains.
  

<table>
  <thead>
    <th>Platform</th>
    <th>What do I do?</th>
  </thead>
  <tbody>
    <tr>
      <td>Rails 4</td>
      <td><code>config.force_ssl = true</code>
      <br/>Does not include subdomains by default. To set it:
      <br/><code>config.ssl_options = { hsts: { subdomains: true } }</td>
    </tr>
    <tr>
      <td>Rails 5</td>
      <td><code>config.force_ssl = true</code></td>
    </tr>
    <tr>
      <td>Django</td>
      <td><code>SECURE_HSTS_SECONDS = 31536000</code>
        <code>SECURE_HSTS_INCLUDE_SUBDOMAINS = True</code>
      </td>
      </td>
    </tr>
    <tr>
    <tr>
      <td>Express.js</td>
      <td>Use <a href="https://www.npmjs.com/package/helmet">helmet</a></td>
    </tr>
    <tr>
      <td>Golang</td>
      <td>Use <a href="https://github.com/unrolled/secure">unrolled/secure</td>
    </tr>
    <tr>
      <td>Nginx</td>
      <td>
        <code>add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; ";</code>
      </td>
    </tr>
    <tr>
      <td>Apache</td>
      <td><code>Header always set Strict-Transport-Security "max-age=31536000; includeSubdomains;"</code></td>
    </tr>
  </tbody>
</table>



#### I want to know more

- [RFC 6797](https://tools.ietf.org/html/rfc6797)
- [Strict-Transport-Security - MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)

---

### X-Frame-Options

```
X-Frame-Options: DENY
X-Frame-Options: SAMEORIGIN
X-Frame-Options: ALLOW-FROM https://example.com/
```

#### Why?

Before we started giving dumb names to vulnerabilities, we used to give dumb
names to hacking techniques. "Clickjacking" is one of those dumb names. The idea
is that you can have an iframe in focus and receiving user input while it's
invisible. So as an attacker, I trick you into playing a browser-based game, but
actually your clicks are being registered by a hidden iframe of twitter and
you're non-consensually retweating all of my tweets.

It sounds dumb, but it's an effective attack.

#### Should I use it?

Yes. Your app is beautiful. Do you really want some
[genius](https://techcrunch.com/2015/04/08/annotate-this/) putting it into an
iframe so they can vandalize it?

#### How?

`X-Frame-Options` has three modes, which are pretty self explanatory.

- `DENY` - No one can put this page in an iframe
- `SAMEORIGIN` - The page can only be displayed in an iframe by someone on the same origin.
- `ALLOW-FROM` - Specify a specific url that can put the page in an iframe

One thing to remember is that you can stack iframes as deep as you want, and in
that case, the behavior of `SAMEORIGIN` and `ALLOW-FROM` isn't
[specified](https://tools.ietf.org/html/rfc7034#section-2.3.2.2). That is, if we
have a triple-decker iframe sandwich and the innermost iframe has `SAMEORIGIN`,
do we care about the origin of the iframe around it, or the topmost one on the
page? ¯\\_(ツ)_/¯.

<table>
  <thead>
    <th>Platform</th>
    <th>What do I do?</th>
  </thead>
  <tbody>
    <tr>
      <td>Rails 4</td>
      <td>
        <p><code>SAMEORIGIN</code> by default.</p>
        <p>To set <code>DENY</code>:
<code>
config.action_dispatch.default_headers['X-Frame-Options'] = "DENY"
</code></p></td>
    </tr>
    <tr>
      <td>Rails 5</td>
      <td>
        <p><code>SAMEORIGIN</code> by default.</p>
        <p>Brave?
<code>
config.action_dispatch.default_headers['X-Frame-Options'] = "DENY"
</code></p></td>
    </tr>
    <tr>
      <td>Django</td>
      <td><code>MIDDLEWARE = [
    ...
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    ...
]
</code>

        This defaults to <code>SAMEORIGIN</code>. To set <code>DENY</code>:
        <br/>
        <code>X_FRAME_OPTIONS = 'DENY'</code>
      </td>
    </tr>
    <tr>
    <tr>
      <td>Express.js</td>
      <td>Use <a href="https://www.npmjs.com/package/helmet">helmet</a></td>
    </tr>
    <tr>
      <td>Golang</td>
      <td>Use <a href="https://github.com/unrolled/secure">unrolled/secure</td>
    </tr>
    <tr>
      <td>Nginx</td>
      <td>
        <code>add_header X-Frame-Options "SAMEORIGIN";</code>
      </td>
    </tr>
    <tr>
      <td>Apache</td>
      <td><code>Header always set x-frame-options "SAMEORIGIN"</code></td>
    </tr>
  </tbody>
</table>

#### I want to know more
- [RFC 7034](https://tools.ietf.org/html/rfc7034)
- [X-Frame-Options - MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options).

---

### X-Content-Type-Options

```
X-Content-Type-Options: nosniff;
```

#### Why?

The problem this header solves is called "MIME sniffing", which is actually a
browser "feature." In theory, your server sets a `Content-Type` header for every
response to tell the browser if it's getting some HTML, a cat gif, or a Flash
cartoon from 2008. The problem with writing a browser is that you have to be
**really** liberal in what you accept since historically the web has always been
broken and has never followed the spec for anything. So since no one ever sets
the content type header right, the browsers got really helpful and inferred it
from the content. If it looks like a gif, display a gif, even if the content
type is text/html. Likewise, if it looks like some HTML, we should render it
even if the server said it's a gif.

This is great, except when you're running a photo-sharing site, and users can
upload photos that look like HTML with javascript included, and suddenly you
have a stored XSS attack on your hand.

The `X-Content-Type-Options` headers is to tell the browser to shut up and
set the damn content type to what I tell you, thank you.

#### Should I use it?
Yes, just make sure to set your content types correctly.

#### How?

<table>
  <thead>
    <th>Platform</th>
    <th>What do I do?</th>
  </thead>
  <tbody>
    <tr>
      <td>Rails 4</td>
      <td>On by default</td>
    </tr>
    <tr>
      <td>Rails 5</td>
      <td>On by default</td>
    </tr>
    <tr>
      <td>Django</td>
      <td><code>SECURE_CONTENT_TYPE_NOSNIFF = True</code></td>
      </td>
    </tr>
    <tr>
    <tr>
      <td>Express.js</td>
      <td>Use <a href="https://www.npmjs.com/package/helmet">helmet</a></td>
    </tr>
    <tr>
      <td>Golang</td>
      <td>Use <a href="https://github.com/unrolled/secure">unrolled/secure</td>
    </tr>
    <tr>
      <td>Nginx</td>
      <td>
        <code>add_header X-Content-Type-Options nosniff;</code>
      </td>
    </tr>
    <tr>
      <td>Apache</td>
      <td><code>Header always set X-Content-Type-Options nosniff</code></td>
    </tr>
  </tbody>
</table>

---

[^filters]: So if you're especially paranoid, you might be thinking "what if I
had some secret subdomain that I don't want leaking for some reason." You have
DNS zone transfers disabled, so someone would have to know what they're looking
for to find it, but now that it's in the preload list...
