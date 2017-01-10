---
title: Ubuntu Hardening Guide
author: mveytsman
layout: post
published: false
---

Who is this guide for?

Know why you're doing the things you're doing.

We don't know everything. Find a mistake or have suggestions? Please [get in touch](mailto:hello@appcanary.com?subject="Ubuntu Hardening Guide")!






## Don't get hacked

### Lock down access

#### Disable Password Authentication for SSH

**What:** You should be accessing your servers via SSH keys instead of passwords. You're probably doing this already because it's more convenient, this will disable password-based access entirely. Your password is now only used for sudo (if you have it enabled).

**Why:** If you have an SSH server listening on the internet, you're going to be hit with brute fore attacks. You probably have a good password (see Use a Password Manager), but 

**How:** In `/etc/ssh/sshd_config` make sure that this line is present:

~~~
PasswordAuthentication no
~~~

**Downsides:** I can't think of any.

**Doublecheck:** Try 


## Configuration

## Patching

# 2) Limit the impact of a breach 



# 3) Be able to detect breaches



# 3) Limit 

1. Keep your systems patched
2. Keep your systems properly configured.
3. Make sure you have strong passwords and two factor authentication.


