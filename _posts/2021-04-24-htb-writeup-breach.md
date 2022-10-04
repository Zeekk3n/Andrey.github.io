---
layout: single
title: '<span class="hackthebox">Breach - Hack The Box Challenge</span>'
excerpt: "Breach it's a osint challenge from HackTheBox where we will have to find out information in some files coming from a company leak."
date: 2021-04-24
header:
  teaser: /assets/images/htb-writeup-breach/icon.png
  teaser_home_page: true
  image_description: breach hack the box
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

You managed to pull some interesting files off one of Super Secure Startup's anonymous FTP servers. Via some OSINT work(a torrent or online Password breach site) you have also procured a recent data breach dump. Can you unlock the file and retrieve the key?

## Steps

Download the files, you'll find 3 files, a key (key protected), an job offer and a file of the leaks (from the breach).
So since one file is the target file and the other a filter list, maybe the next step is on the remaining file.

Reading the document, comment that the offers can be sent through the email hr@supersecurestartup.com.

If we search for the email you'll find a twitter account from Bianka Phelps.
So let's check if your data is in the data file.

Yeah, we got her.

<a href="/assets/images/htb-writeup-breach/bianka.png">
    <img src="/assets/images/htb-writeup-breach/bianka.png">
</a>

Password = "Love!July2018"

Let's try the password.. well it didn't work.

But looking at the metadata we can see that the last modification was in March and seeing how your password was, it may be that you will update it, with March and 2019 being the year.

<a href="/assets/images/htb-writeup-breach/mod.png">
    <img src="/assets/images/htb-writeup-breach/mod.png">
</a>

OK, we got the pass.

Now decoding the BASE64 code there, you'll get the flag.

Byee
