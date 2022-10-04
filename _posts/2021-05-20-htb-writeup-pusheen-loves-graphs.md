---
layout: single
title: '<span class="hackthebox">Pusheen Loves Graphs - Hack The Box Challenge</span>'
excerpt: "Pusheen Loves Graphs is a stegonography challenge where you will find a binary that you'll have to inspect"
date: 2021-05-20
header:
  teaser: /assets/images/htb-writeup-pusheen-loves-graphs/icon.png
  teaser_home_page: true
  image_description: pusheen loves graphs hack the box
  icon: /assets/images/hackthebox.webp
  icon_description: hackthebox
categories:
  - hackthebox
  - challenge
tags:  
  - steganography
  - cipher
  - reversing
toc: true
toc_label: "Content"
toc_sticky: true
show_time: true
---

<a href="/assets/images/htb-writeup-pusheen-loves-graphs/hackthebox.png">
    <img src="/assets/images/htb-writeup-pusheen-loves-graphs/hackthebox.png">
</a>

Unzipping the package as always we got a file called ```Pusheen```, since it has no extension, with ```file``` we can figure out which type of file it's. 

```bash
file Pusheen
```

Output:

```
Pusheen: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, not stripped
```

Pusheen it's an linux executable.
So let's run the file..

```bash
./Pusheen
```

Output:

```
   ▐▀▄      ▄▀▌   ▄▄▄▄▄▄▄             
   ▌▒▒▀▄▄▄▄▀▒▒▐▄▀▀▒██▒██▒▀▀▄          
  ▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▀▄        
  ▌▒▒▒▒▒▒▒▒▒▒▒▒▒▄▒▒▒▒▒▒▒▒▒▒▒▒▒▀▄      
▀█▒▒█▌▒▒█▒▒▐█▒▒▀▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▌     
▀▌▒▒▒▒▒▀▒▀▒▒▒▒▒▀▀▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▐   ▄▄
▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▌▄█▒█
▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▐▒█▀ 
▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▐▀   
▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▌    
 ▌▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▐     
 ▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▌     
  ▌▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▐      
  ▐▄▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▄▌      
    ▀▄▄▀▀▀▀▄▄▀▀▀▀▀▀▄▄▀▀▀▀▀▀▄▄▀       
 
                                                   
```

Okey it's a cat haha, thanks to the clues in the description of the challenge, we know that we will have to use IDA.

So when we open the file we got an error about the program cant create/display a graph cuz the file has more than 1000 nodes so we'll change this limit:

Options>IDA Options>Graph>Max number of nodes

<a href="/assets/images/htb-writeup-pusheen-loves-graphs/nodes.png">
    <img src="/assets/images/htb-writeup-pusheen-loves-graphs/nodes.png">
</a>

20000 nodes it's enough.

Now the graph was created and we can display it

<a href="/assets/images/htb-writeup-pusheen-loves-graphs/display_graph.png">
    <img src="/assets/images/htb-writeup-pusheen-loves-graphs/display_graph.png">
</a>

In the graph we found the flag, rather the content.

