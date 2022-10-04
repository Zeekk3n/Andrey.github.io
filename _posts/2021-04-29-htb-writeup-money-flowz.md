---
layout: single
title: '<span class="hackthebox">Money Flowz - Hack The Box Challenge</span>'
excerpt: "Money Flowz it's a osint challenge from HackTheBox where we will have to find out information about cryto transactions"
date: 2021-04-26
header:
  teaser: /assets/images/htb-writeup-money-flowz/icon.png
  teaser_home_page: true
  image_description: money flowz hack the box
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

# Description
Frank Vitalik is a hustler, can you figure out where the money flows?

# Steps
Search for Frank Vitalik in Google, you'll fins his Reddit post:
<https://www.reddit.com/user/frankvitalik/comments/goxkz7/whats_the_cleverest_scam_youve_seen_in_crypto/>

Which it contains a link to etherscan address acc.

We can see the address is involved with 28,394 transactions at the moment.

However, since anyone can send a transaction to the address, we can rule these out as noise as the flag would be given by Frank Vitalik — that is, something to do with an outgoing transaction.

Since there are not a lot of transactions on this account, we can use the Etherscan web UI to find the outgoing transactions (otherwise we may interrogate a node/API with code to fetch all the outgoing transactions).

You will have to search and search until you find a transaction from when the first address joined the network, to make it easy for you, I will give you the link even so it tries to find it.
<https://ropsten.etherscan.io/tx/0xe1320c23f292e52090e423e5cdb7b4b10d3c70a8d1b947dff25ae892609f2ef4>

To read the flag you have to "see more" and then view the input as UTF-8

Byee