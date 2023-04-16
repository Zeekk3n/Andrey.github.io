---
layout: single
title: '<span class="projects">PortScanner - Project</span>'
excerpt: "A fast, TCP port scanner."
date: 2023-04-04
categories:
  - projects
tags:  
  - scanner
  - reconnaissance
show_time: true
---

A fast, concurrent a TCP port scanner for machines that actually don't have binaries such as nc or ss or nmap

## Installation

* Install in Linux, copy the code, and give it permission of execution

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

  



  ```bash
  chmod +x Portscanner.sh
  ```

* and just execute it 
  ```bash
  ./PortScanner.sh
  ```
* take underconsideration the variable "ip" in my case i will find the 65535 ports for ip 10.10.0.128 in your case will be different so make sure you change it according your preferences  !!
```bash
  output
  bash-4.4# ./Portscanner.sh 
bash-4.4# ./Portscanner.sh 
[+] Port 21 - is OPEN
[+] Port 22 - is OPEN
[+] Port 80 - is OPEN
[+] Port 139 - is OPEN
[+] Port 445 - is OPEN


[!] getting out that here...
```

Happy hacking !
