---
title: Everything you've ever wanted to know about secure headers 
author: mveytsman
layout: post
published: false
---


- Content Security Policy (CSP) 
Originally proposed in 2004 by RSnake. First standard 2012, current version is from 2015.
Helps detect/prevent XSS, mixed-content, and other classes of attack.  [CSP 2 Specification](http://www.w3.org/TR/CSP2/)

- HTTP Strict Transport Security (HSTS) - Ensures the browser never visits the http version of a website. Protects from SSLStrip/Firesheep attacks.  [HSTS Specification](https://tools.ietf.org/html/rfc6797)
First proposed in 2010, adopted in 2012.


- X-Frame-Options (XFO) - Prevents your content from being framed and potentially clickjacked. [X-Frame-Options Specification](https://tools.ietf.org/html/rfc7034)
First used in 2009, standardized in 2013.

- X-XSS-Protection - [Cross site scripting heuristic filter for IE/Chrome](https://msdn.microsoft.com/en-us/library/dd565647\(v=vs.85\).aspx)

- X-Content-Type-Options - [Prevent content type sniffing](https://msdn.microsoft.com/library/gg622941\(v=vs.85\).aspx)
- X-Download-Options - [Prevent file downloads opening](https://msdn.microsoft.com/library/jj542450(v=vs.85).aspx)
- X-Permitted-Cross-Domain-Policies - [Restrict Adobe Flash Player's access to data](https://www.adobe.com/devnet/adobe-media-server/articles/cross-domain-xml-for-streaming.html)
- Referrer-Policy - [Referrer Policy draft](https://w3c.github.io/webappsec-referrer-policy/)
- Public Key Pinning - Pin certificate fingerprints in the browser to prevent man-in-the-middle attacks due to compromised Certificate Authorities. [Public Key Pinning Specification](https://tools.ietf.org/html/rfc7469)

- Cookies 
 - Secure
 - HttpOnly
 - SameSite


### X-Content-Type-Options

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


#### Downsides

You have to actually set content types correctly.

#### Header syntax

```
X-Content-Type-Options: nosniff;
```

#### Setting it correctly

##### Rails 4
On by default
##### Rails 5
On by default
##### Django
Turn it on in the Security middleware

```
SECURE_CONTENT_TYPE_NOSNIFF = True
```
##### Express.js
Use [helmet](https://www.npmjs.com/package/helmet)
##### Golang
Use [unrolled/secure](https://github.com/unrolled/secure)
##### Nginx

##### Apache



<table>
<thead>
<tr>
<th>Rails 4</th>
<th>Rails 5</th>
<th>Django</th>
<th>Express.js</th>
<th>Golang</th>
<th>Nginx</th>
<th>Apache</th>
</tr>
</thead>
<tbody>
<tr>
<td>
Default on
</td>
<td>
Default on
</td>
<td>
</td>
</tr>
</tbody>
</table>

