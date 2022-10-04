---
layout: single
title: '<span class="hackthebox">Easy Phish - Hack The Box Challenge</span>'
excerpt: "Breach it's a osint challenge from HackTheBox where we will have to find out information about very convincing phising emails"
date: 2021-04-26
header:
  teaser: /assets/images/htb-writeup-easy-phish/icon.png
  teaser_home_page: true
  image_description: easy phish hack the box
  icon: /assets/images/hackthebox.webp
  icon_description: hackthebox
categories:
  - hackthebox
  - challenge
tags:
  - osint
  - email-spoofing
  - dns
toc: true
toc_label: "Content"
toc_sticky: true
show_time: true
---


## Description

Customers of secure-startup.com have been recieving some very convincing phishing emails, can you figure out why?

## Steps

There's 2 between others ways to preventing Email Address Spoofing, this 2 are SPF and DMARC, saying this let's scane

We'll use NsLookup which is a program used to find out if DNS is correctly resolving names and IPs.

## Step-1:
For the SPF domain of a record:

nslookup -type=txt secure-startup.com
We get the following result:

```bash
nslookup -type=txt secure-startup.com
```

Output:

```
Server:         192.168.150.2
Address:        192.168.150.2#53

Non-authoritative answer:
secure-startup.com      text = "v=spf1 a mx ?all - HTB{XXX_XXX_XXXX_XXX"

Authoritative answers can be found from:
```

## Step-2:
For the DMARC domain of a record:

nslookup -type=txt _dmarc.secure-startup.com
We get the following result:

```bash
nslookup -type=txt _dmarc.secure-startup.com
```

Output:

```
Server:         192.168.150.2
Address:        192.168.150.2#53

Non-authoritative answer:
_dmarc.secure-startup.com       text = "v=DMARC1;p=none;_XXXXX_XXXX_XXXXX}"

Authoritative answers can be found from:
```

## Step-3:

So finally the flag becomes, join both outputs:

HTB{XXX-XXXX-XXXXXX-XXXXXX-XXXX}

Byee
