---
layout: single
title: '<span class="projects">Port Scanner - Project</span>'
excerpt: "A fast, TCP port scanner."
date: 2023-03-03
categories:
  - projects
tags:  
  - scanner
  - reconnaissance
show_time: true
---

A fast, TCP port scanner for machines that actually don't have binaries such as nc, nmap


## Installation

* Install in Linux, copy the code, and give it permission of execution

  ```bash
  vi  PortScanner.sh
  ```

  copy the this code  and paste it on vi editor 

* here

```bash
#!/bin/bash

function ctrl_c(){
     echo -e "\n\n[!] getting out that here...\n"
     tput cnorm; exit 1
}
# Ctrl + c
trap ctrl_c INT 

tput civis

for port in $(seq 1 65535); do 
         timeout 1 bash -c "echo '' > /dev/tcp/10.10.0.128/$port" 2>/dev/null && echo "[+] Port $port - is OPEN" & 
done; wait 

tput cnorm
  
```

* take under consideration the variable "ip" in my case i will search 65535 open ports for ip 10.10.0.128 in your case will be different the variable ip so make sure you change it according your preferences  !!
  ```bash
  output
  d
  d
  bash-4.4# ./Portscanner.sh 
  [+] Port 21 - is OPEN
  [+] Port 22 - is OPEN
  [+] Port 80 - is OPEN
  [+] Port 139 - is OPEN
  [+] Port 445 - is OPEN
  ^C

  [!] getting out that here...
  ```



## Usage

Scan the 65535 ports over your ip that you want to scan


happy hacking !
