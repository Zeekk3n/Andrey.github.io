---
layout: single
title: '<span class="projects">HostDiscovery - Project</span>'
excerpt: "A fast, IP scanner."
date: 2023-04-04
categories:
  - projects
tags:  
  - scanner
  - reconnaissance
show_time: true
---

A fast, concurrent and multithread TCP port scanner for machines that actually don't have binaries such as netcat or ss

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

for i in $(seq 1 254); do 
         timeout 1 bash -c "ping -c 1 10.10.0.$i" &> /dev/null && echo "[+] host 10.10.0.$i - is ACTIVE"& 
done; wait 

tput cnorm 
  
```

  



  ```bash
  chmod +x hostdiscovery.sh
  ```

* and just execute it 
  ```bash
  ./hostdiscovery.sh
  ```
* take underconsideration the variable "ip" in my case i will find 255 variables for ip 10.10.0.$1 in your case will be different so make sure you change it according your preferences  !!
```bash
  output
  bash-4.4# ./hostdiscovery.sh 
[+] host 10.10.0.1 - is ACTIVE
[+] host 10.10.0.129 - is ACTIVE
[+] host 10.10.0.128 - is ACTIVE
bash-4.4# 
```

Happy hacking !
