---
layout: single
title: '<span class="vulnhub">machines synfonos3 - /VulnHub</span>'
excerpt: "imf, is a machine from Vulnhub platform. I recommend you do these CTF because the last machine for the eCCptv2 it will be something like this."
date: 2023-05-03
categories:
  - vulnhub
  - machine
tags:  
  - wordpress
  - bruteforce
  - Buffer over flow
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

imf, is a machine from Vulnhub platform. I recommend you do these CTF because for the eCCptv2 it will be something like theis machine 


**We will see all this from the perspective and methodology of a penetration test.**

- Links to the machines: [imf](https://www.vulnhub.com/entry/imf-1,162/)
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
❯ arp-scan -Iens33 --localnet
Interface: ens33, type: EN10MB, MAC: 00:0c:29:f2:37:49, IPv4: 192.168.100.53
Starting arp-scan 1.9.7 with 256 hosts (https://github.com/royhills/arp-scan)
192.168.100.1	64:5e:10:84:35:47	(Unknown)
192.168.100.10	90:e8:68:d0:da:47	(Unknown)
192.168.100.5	58:9a:3e:6e:27:40	(Unknown)
192.168.100.7	24:18:c6:dc:bd:cd	(Unknown)
192.168.100.52	00:0c:29:d2:5a:2b	VMware, Inc.
192.168.100.69	1a:b6:dd:e0:25:e9	(Unknown: locally administered)

6 packets received by filter, 0 packets dropped by kernel
Ending arp-scan 1.9.7: 256 hosts scanned in 1.954 seconds (131.01 hosts/sec). 6 responded
```

where: /explanation of the output 

MAC 00:0c:29:d2:5a:2b how arp-scan knows that is vmware ? it's because the kind of OUI  00:0c:29 use macchanger + l + | grep + "00:0c:29" they would tell us that it's vmware for the OUI which is organizationally unique identifier  


now that we have the IP let me introduce you to IPv4 and IPv6

because of the output we can notice that the IP that we will find vulnerabilities is IPv4, but how i know it?


```192.168.100.61``` la IP es basicamente una etiqueta numerica que identifica de manera logica y gerarquica a una interfaz en la red de un dispositivo que utilice el protocolo de internet 

esta IP es lo mismo que bits  en conclucion 

porque digo que son bits ? porque a simple vista me doy cuenta que son 4 pares de octetos se le dice octetos porque hay 4 pares de 8 bits  de forma que el 192 representado en binario en 8 bits seria  

ya sabemos que haciendo un echi de 192.168.100.52 me lo va a mostrar por consola 

pero si yo lo quiero dividir ahora en 4 bytes  recuerda que 1 byte son 8 bites de forma que yo quiero quieroto  tratar de representar un total de 32 bites
lo que podriamos representar el mismo ejemplo pero con cambios 

```bash 
echo "$().168.100.52"
``` 
en lugar del 192 vamos a poner $() para que 
con esta instruccion vamos a tratar de devolver el output de un comando ejecutado a nivel de sistema 

bien ahora lo que vamos a hacer es tratar de ejecutar un comando a nivel de sistema y jugado con  obase=2 ; vamos a intertar represetar el  el numero 192  en binario  como lo podriamos hacer agregando un | bc  al darle al enter me respresntaria el numero en bites pero que es bc ? ek comando bc es una calculadora que se puede usar desde la linea de comandos 

```bash 
echo "$().168.100.52"
``` 
is basically a numeric tag that identifies in a logic way an gerarchic  
dircciones IPv4 

direcciones IPv6



```24:18:c6:dc:bd:cd```



now we know the ip for the machine that we can reach, now we have to enumerate to figure out what kind of machine is based on the TTL which is time to life.
```bash
ping -c3 192.168.100.61
```
in this case seems that does not work, so we might need an external binyre i will use tcping becase was writte in go,and the progrramming languague works  very well with sockets and conecctions 

installation 
```bash


```
usage 

```bash 
❯ ./tcping 192.168.100.52
Ping tcp://192.168.100.52:80(192.168.100.52:80) connected - time=653.9µs dns=0s
Ping tcp://192.168.100.52:80(192.168.100.52:80) connected - time=868.1µs dns=0s
Ping tcp://192.168.100.52:80(192.168.100.52:80) connected - time=608.5µs dns=0s
Ping tcp://192.168.100.52:80(192.168.100.52:80) connected - time=513.8µs dns=0s

Ping statistics tcp://192.168.100.52:80
	4 probes sent.
	4 successful, 0 failed.
Approximate trip times:
	Minimum = 513.8µs, Maximum = 868.1µs, Average = 661.075µs#      

```
output 

```bash 

```

where 


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
❯ nmap -sS --open --min-rate 5000 -Pn -n -vvv 192.168.100.52 -oG allPorts
Starting Nmap 7.93 ( https://nmap.org ) at 2023-05-04 02:27 CST
Initiating ARP Ping Scan at 02:27
Scanning 192.168.100.52 [1 port]
Completed ARP Ping Scan at 02:27, 0.03s elapsed (1 total hosts)
Initiating SYN Stealth Scan at 02:27
Scanning 192.168.100.52 [1000 ports]
Discovered open port 80/tcp on 192.168.100.52
Completed SYN Stealth Scan at 02:27, 0.52s elapsed (1000 total ports)
Nmap scan report for 192.168.100.52
Host is up, received arp-response (0.00031s latency).
Scanned at 2023-05-04 02:27:51 CST for 1s
Not shown: 999 filtered tcp ports (no-response)
Some closed ports may be reported as filtered due to --defeat-rst-ratelimit
PORT   STATE SERVICE REASON
80/tcp open  http    syn-ack ttl 64
MAC Address: 00:0C:29:D2:5A:2B (VMware)

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 0.68 seconds
           Raw packets sent: 2000 (87.984KB) | Rcvd: 2 (72B)
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
- 
```bash
gobuster dir -u http://192.168.100.61/ -w /usr/share/SecLists-master/Discovery/Web-Content/directory-list-2.3-medium.txt -t 100 --add-slash
```
