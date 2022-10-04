---
layout: single
title: '<span class="hackthebox">We Have A Leak - Hack The Box Challenge</span>'
excerpt: "We Have A Leak it's a osint challenge from HackTheBox where we will have to find out information about a leak"
date: 2021-04-26
header:
  teaser: /assets/images/htb-writeup-we-have-a-leak/icon.png
  teaser_home_page: true
  image_description: we have a leak hack the box
  icon: /assets/images/hackthebox.webp
  icon_description: hackthebox
categories:
  - hackthebox
  - challenge
tags:
  - osint
toc: true
toc_label: "Content"
toc_sticky: true
show_time: true
---

## Description

Super Secure Startup's private information is being leaked; can you find out how? 

## Steps

### Firt One
Download the files and uncompress them until you have to decompress the ```username.zip``` because we don't know the password.

### Second One

To find the pass, we'll search in google for "Super Secure Startup", the company.

Looking at the tweets, we found that there is a person who was going to join the company.

Since we need a user to unzip the ```username.zip```, we can try with a common format for employees within a company, like the initial dot surnames.

So it works ```j.terranwald```.

### Third One

We need the pass for ```password.zip```.

Well looking around, in relation to the company, I found another employee Bianka Phelps.

In one of her post we can find what the password looks like.

<https://pbs.twimg.com/media/D2i4sxFXcAAgHAe?format=jpg&name=medium>

```SupSecStart#Winter2018!``` , but.. it didnt works.

So, checking the zip's info..
```bash
unzip -v password.zip
```

Output:

```
Archive:  password.zip
 Length   Method    Size  Cmpr    Date    Time   CRC-32   Name
--------  ------  ------- ---- ---------- ----- --------  ----
      42  Defl:N       37  12% 2019-03-26 00:02 699ed1f3  password/flag.txt
--------          -------  ---                            -------
      42               37  12%                            1 file
```

We can extrapolate that the password was changed, and based on the fact that the last modification was in March 2019, perhaps since the other password was Winter 2018, perhaps now it is Spring2019.

```SupSecStart#Spring2019!```

So, let's try... Ok, It works. We got the flag.

Byee