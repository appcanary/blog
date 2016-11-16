---
title: Best security news of 2016? Ubuntu 16.10 ships with unattended upgrades enabled
date: 2016-11-15
tags:  Clojure, Programming, Ruby
author: mveytsman
published: true
layout: post
---
Last week, we got a strange support request. One of our users had received the following notification:


> Hey! Good job.
>
> We've detected that you patched some vulnerabilities.
>
> Here's what changed:
> 
> [CVE-2016-8704](https://appcanary.com/vulns/46220)
> 
> is no longer present in:
>
> [name of server redacted]

This came as a surprise, since they knew for a fact that no one had touched the package in
question, and they were certain they had not enabled unattended upgrades. 

Somehow, the vulnerability magically got patched and they wanted to
know: what's going on?

The vuln is a pretty serious remote code execution vulnerability in `memcached`,
and as far as we could tell, our user was indeed using the most recent version available for their
distribution &mdash; `1.4.25-2ubuntu2.1`. This version was released on November 3rd, and we could see from our logs that
`memcached` got upgraded that same day.

How did it happen without them knowing about it? The only thing unique about
their configuration was that they're running the recently released Ubuntu 16.10 (Yakkety
Yak)[^yakkety]. 

We dug around, and set up some test Yakkety boxes, and
lo and behold: unattended upgrades is automatically enabled by default!

For those of you who are unaware, `unattended-upgrades` is a debian/ubuntu package that, well, does what it says on the
tin: it automatically upgrades your packages. The most common configuration, andthe one enabled in 16.10, is to upgrade any packages that have a published security patch. Unattended upgrades does this by checking and installing any
updates from the `${distro_codename}-security` repository.

Ubuntu/debian has had this for years, but it simply was never turned on by
default. After a year of many
[security](https://blog.appcanary.com/2016/vikhal-symantec.html)
[fails](https://blog.appcanary.com/2016/mirai-botnet-security-broken.html), this
news warmed the cockles of my heart and gave me hope for our future! And what's
even amazing is that they turned it on without any fanfare. 

It's the quiet,
simple changes that provide the biggest wins.

Of course, there are reasons why administrators don't always want software to be upgraded without
their input. And if it does get updated, there are good reasons for knowing exactly what vulnerabilities are being patched when.
[Appcanary](https://appcanary.com/) exists in order to allow you to be notified
about security updates without automatically installing them, and to have
insight into what's going being installed if you are patching automatically.

But if you don't have the capacity to actively manage the packages on your
linux systems (and even if you do!), we implore you: set up `unattended-upgrades`!

Ubuntu enabling this by default is a great sign for the future.

## Not running Ubuntu 16.10?

Here's how to turn on unattended upgrades

- Ansible: [jnv.unattended-upgrades](https://galaxy.ansible.com/jnv/unattended-upgrades/)
- Puppet: [puppet/unattended_upgrades](https://forge.puppet.com/puppet/unattended_upgrades)
- Chef: [apt](https://supermarket.chef.io/cookbooks/apt)
- If you're using the server interactively: 

    `sudo apt-get install unattended-upgrades && sudo dpkg-reconfigure unattended-upgrades`

- Set up manually: `sudo apt-get install unattended-upgrades` and
 - In `/etc/apt/apt.conf.d/20auto-upgrades`:
     
            APT::Periodic::Update-Package-Lists "1";
            APT::Periodic::Unattended-Upgrade "1";

 - In `/etc/apt/apt.conf.d/50unattended-upgrades`

            // Automatically upgrade packages from these (origin, archive) pairs
            Unattended-Upgrade::Allowed-Origins {    
            // ${distro_id} and ${distro_codename} will be automatically expanded
                "${distro_id} ${distro_codename}-security";
            };
            
            // Send email to this address for problems or packages upgrades
            // If empty or unset then no email is sent, make sure that you 
            // have a working mail setup on your system. The package 'mailx'
            // must be installed or anything that provides /usr/bin/mail.
            //Unattended-Upgrade::Mail "root@localhost";
            
            // Do automatic removal of new unused dependencies after the upgrade
            // (equivalent to apt-get autoremove)
            //Unattended-Upgrade::Remove-Unused-Dependencies "false";
            
            // Automatically reboot *WITHOUT CONFIRMATION* if a 
            // the file /var/run/reboot-required is found after the upgrade 
            //Unattended-Upgrade::Automatic-Reboot "false";
 

[^yakkety]: 16.10 is not a Long Term Support release. Regular Ubuntu releases
    are supported for 9 months, while April releases on even years (i.e. 14.04,
    16.04, etc...) are designated LTS, and are supported for 5 years. It's thus
    more common to see 12.04, 14.04, and 16.04 in use on servers over other
    Ubuntu releases. This particular user has a good reason for running 16.10.
