---
layout: single
title: '<span class="vulnhub">IMF machine - /VulnHub</span>'
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

explanation of the output 

MAC 00:0c:29:d2:5a:2b how arp-scan knows that is vmware ? it's because the kind of OUI  ```00:0c:29``` use macchanger + l + | grep + "00:0c:29" they would tell us that it's vmware for the OUI which is organizationally unique identifier and the rest of the number belongs to he NIC d2:5a:2b nic means Network interface controller and actually the company made the NIC.


now that we have the IP let me introduce you to IPv4
IPv4 

because of the output we can notice that the IP that we will find vulnerabilities is IPv4, but how i know it?


```192.168.100.61``` is basically a numeric label that logically and hierarchically identifies an interface on a device's network that uses the internet protocol.

This IP is the same as bits, in conclusion. 


Why do I say they are bits? Because at a glance, I can see that there are 4 pairs of octets. They are called octets because there are 4 pairs of 8 bits here, 4 pairs  ```1octets,2octets,3octets,4octets```  Therefore, we know how I realized that there are 4 octets, but how did I realize that they are 8 bits? Well, that's because the 192 represented in binary in 8 bits would be, for example:

We know that by doing an ```echo``` of ```192.168.100.52```  it will show up in the console, so it will print it.

pero si yo lo quiero dividir ahora en 4 bytes  recuerda que 1 byte son 8 bites de forma que yo quiero quiero  tratar de representar un total de 32 bytes
But if I want to divide it into 4 bytes, remember that 1 byte is 8 bits, so I want to represent a total of 32 bytes. We could represent the same example but with changes:

```bash 
echo "$().168.100.52"
``` 
Instead of 192, we are going to put $() so that we can try to return the output of a command executed at the system level.

Now we are going to execute a command at the system level and play with ```obase=2;``` to try to represent the number 192 in binary. We can do this by adding a | bc to represent the number in bytes, but what is ```bc``` ? this command is a calculator that can be used from the command line.

```bash 
echo $(echo "obase=2; 192" | bc).$(echo "obase=2; 168" | bc).$(echo "obase=2;100" | bc).(echo "obase=2; 52" | bc )
``` 
The output should be represented in binary, and since it is a 32-bit binary, the size of the IPs would be 2^32.
```bash 
❯ echo $(echo "obase=2; 192" | bc).$(echo "obase=2; 168" | bc).$(echo "obase=2;100" | bc).$(echo "obase=2; 52" | bc)
11000000.10101000.1100100.110100
```

In other words, the size of the IP would be:


```bash
❯ echo "2^32" | bc
4294967296
```

output



That's why IPv6 exists, because there are very few IPv4 addresses compared to the world's population, and that's why IPv6 is gradually being implemented.

Since IPv6 uses a 128-bit format, it is 2^128.

```bash
echo "2^128" | bc
```



IPv6 addresses are represented by a 128-bit format, so it would be 2^128.

output 

```bash 
340282366920938463463374607431768211456
```


```24:18:c6:dc:bd:cd```



now we know the iPv4 for the machine that we can reach, now we have to enumerate to figure out what kind of machine is based on the TTL which is time to life.
```bash
ping -c3 192.168.100.61
```
in this case seems that does not work, so we might need an external binary i will use tcping because was writte in go,and the Programming language works very well with sockets and connections  

installation 

```bash
gitclone  https://github.com/cloverstd/tcping
```
usage binary + ip

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
where 


output:

```php
Ping tcp://192.168.100.52:80(192.168.100.52:80) connected - time=653.9µs dns=0s
Ping tcp://192.168.100.52:80(192.168.100.52:80) connected - time=868.1µs dns=0s
Ping tcp://192.168.100.52:80(192.168.100.52:80) connected - time=608.5µs dns=0s
Ping tcp://192.168.100.52:80(192.168.100.52:80) connected - time=513.8µs dns=0s

--- 192.168.100.61 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2031ms
rtt min/avg/max/mdev = 0.291/0.327/0.357/0.027 ms
```

- ```-TTL-``` : means the time to life of the machine, if it's 64 the machine is Linux, or if it's 124 the machine will be windows.
- ```--3 packets transmitted, 3 received``` : with this output means that the machine is active.

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
nmap -sS --open --min-rate 5000 -Pn -n -vvv 192.168.100.52 -oG allPorts
Starting Nmap 7.93 ( https://nmap.org ) at 2023-05-04 14:47 CST
Initiating ARP Ping Scan at 14:47
Scanning 192.168.100.52 [1 port]
Completed ARP Ping Scan at 14:47, 0.05s elapsed (1 total hosts)
Initiating SYN Stealth Scan at 14:47
Scanning 192.168.100.52 [1000 ports]
Discovered open port 80/tcp on 192.168.100.52
Completed SYN Stealth Scan at 14:47, 0.53s elapsed (1000 total ports)
Nmap scan report for 192.168.100.52
Host is up, received arp-response (0.00040s latency).
Scanned at 2023-05-04 14:47:07 CST for 1s
Not shown: 999 filtered tcp ports (no-response)
Some closed ports may be reported as filtered due to --defeat-rst-ratelimit
PORT   STATE SERVICE REASON
80/tcp open  http    syn-ack ttl 64
MAC Address: 00:0C:29:D2:5A:2B (VMware)

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 0.70 seconds
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
❯ nmap -sCV -p80 192.168.100.52 -oN targeted
Starting Nmap 7.93 ( https://nmap.org ) at 2023-05-04 14:59 CST
Nmap scan report for 192.168.100.52
Host is up (0.00036s latency).

PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: IMF - Homepage
MAC Address: 00:0C:29:D2:5A:2B (VMware)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 11.85 seconds
```

To find out what we are dealing with, we will run **WhatWeb** in order to find the codename as well

```bash
❯ whatweb 192.168.100.52
http://192.168.100.52 [200 OK] Apache[2.4.18], Bootstrap, Country[RESERVED][ZZ], HTML5, HTTPServer[Ubuntu Linux][Apache/2.4.18 (Ubuntu)], IP[192.168.100.52], JQuery[1.10.2], Modernizr[2.6.2.min], Script, Title[IMF - Homepage], X-UA-Compatible[IE=edge]

```

seems that does not give us a lo of information.

So let's visit the web the port 


After testing each of the attacks SSRF,SQLI,PATHtraversal I did not find anything relevant, on the other hand we are able to search for possible routes using gobuster for example

Since there seems to be no more information in sight then these possible users i found them in > ```contact us ``` tab
```bash 

Roger S. Michaels

rmichaels@imf.local

Director
Alexander B. Keith

akeith@imf.local

Deputy Director
Elizabeth R. Stone

estone@imf.local

Chief of Staff


```


, we will proceed to do *Fuzzing*, which consists of making requests to the server of several routes extracted from a dictionary with the objective of obtaining routes that exist. For this we will use *Wfuzz* although another powerful tool is *Ffuf* or gobuster.

- With wfuzz would be:

```bash
wfuzz -c -L --hc=404 -t 200 -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt http://192.168.100.52///FUZZ
```

- With ffuf would be:

```bash
ffuf -u http://192.168.100.52//FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -mc 200 -c -t 200
```
- With gobuster would be:
- 
```bash
gobuster dir -u http://192.168.100.52/ -w /usr/share/SecLists-master/Discovery/Web-Content/directory-list-2.3-medium.txt -t 100 --add-slash
```

in this example i will use gobuster so 

```bash
gobuster dir -u http://192.168.100.52 -w //usr/share/SecLists-master/Discovery/Web-Content/directory-list-2.3-medium.txt -t 100 --add-slash

```
output 

```php
===============================================================
Gobuster v3.1.0
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://192.168.100.52/
[+] Method:                  GET
[+] Threads:                 100
[+] Wordlist:                /usr/share/SecLists-master/Discovery/Web-Content/directory-list-2.3-big.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.1.0
[+] Add Slash:               true
[+] Timeout:                 10s
===============================================================
2023/05/04 14:53:59 Starting gobuster in directory enumeration mode
===============================================================
/css/                 (Status: 403) [Size: 279]
/js/                  (Status: 403) [Size: 279]
/fonts/               (Status: 403) [Size: 279]
/images/              (Status: 403) [Size: 279]
/icons/               (Status: 403) [Size: 279]
/less/                (Status: 403) [Size: 279]
/server-status/       (Status: 403) [Size: 279]
                                               
===============================================================
2023/05/04 14:57:26 Finished
```

we have a few routes but with 403 forrbiden status, let's check inside of the page and actually using ```ctrl``` + ```u``` we found a few things

```bash
    <script src="js/ZmxhZzJ7YVcxbVl.js"></script>
        <script src="js/XUnRhVzVwYzNS.js"></script>
        <script src="js/eVlYUnZjZz09fQ==.min.js"></script>
        <script>
         new WOW(
```
seems to be base64 encode let's check them using echo + base64

```bash 

❯ echo "js/ZmxhZzJ7YVcxbVl.js" | base64 -d  echo ""
base64: operando extra «»
Pruebe 'base64 --help' para más información.
❯ echo "js/ZmxhZzJ7YVcxbVl.js" | base64 -d
Y̞U[Vbase64: entrada inválida
❯ echo "js/ZmxhZzJ7YVcxbVl.js" | base64 -d; echo ""
Y̞U[Vbase64: entrada inválida

❯ echo "/ZmxhZzJ7YVcxbVl" | base64 -d; echo ""
\ŵe
❯ echo "ZmxhZzJ7YVcxbVl" | base64 -d; echo ""
flag2{aW1mYbase64: entrada inválida

❯ echo "/ZmxhZzJ7YVcxbVl" | base64 -d; echo ""
\ŵe
❯ echo "/ZmxhZzJ7YVcxbVlZmxhZzJ7YVcxbVlZmxhZzJ7YVcxbVl" | base64 -d; echo ""
\ŵeflag2{aW1mYYY̞U[Vbase64: entrada inválida

❯ echo "ZmxhZzJ7YVcxbVlZmxhZzJ7YVcxbVlZmxhZzJ7YVcxbVl" | base64 -d; echo ""
flag2{aW1mYYY̞U[VVfs'sbase64: entrada inválida

❯ echo "ZmxhZzJ7YVcxbVl" | base64 -d; echo ""
flag2{aW1mYbase64: entrada inválida

❯ echo "ZmxhZzJ7YVcxbVl" | base64 -d; echo ""
flag2{aW1mYbase64: entrada inválida

❯ echo "eVlYUnZjZz09fQ==.min" | base64 -d; echo ""
yYXRvcg==}base64: entrada inválida

❯ echo "eVlYUnZjZz09fQ==." | base64 -d; echo ""
yYXRvcg==}base64: entrada inválida

❯ echo "eVlYUnZjZz09fQ==" | base64 -d; echo ""
yYXRvcg==}
❯ 
❯ echo "ZmxhZzJ7YVcxbVlXUnRhVzVwYzNSeVlYUnZjZz09fQ==" | base64 -d; echo ""
flag2{aW1mYWRtaW5pc3RyYXRvcg==}

```

we have another base64 encode let's check 
```bash
❯ echo "aW1mYWRtaW5pc3RyYXRvcg" | base64 -d;
imfadministratorbase64: entrada inválida
❯ echo "aW1mYWRtaW5pc3RyYXRvcg" | base64 -d; echo
imfadministratorbase64: entrada inválida

❯ echo "aW1mYWRtaW5pc3RyYXRvcg==" | base64 -d; echo
imfadministrator

```
the only port open is 80, let's check if it's a route that gobuster did not find 

and actually it works 

```bash
Invalid username.
Username:
Password:

```

it's a loggin panel let's find with the codigo fuente 


```bash
Invalid username.<form method="POST" action="">
<label>Username:</label><input type="text" name="user" value=""><br />
<label>Password:</label><input type="password" name="pass" value=""><br />
<input type="submit" value="Login">
<!-- I couldn't get the SQL working, so I hard-coded the password. It's still mad secure through. - Roger -->
</form>
```

and we found a comment, according with the programmer he did not could take the work done in the SQL data bases 

so it might be a vulneral panel of SQLIN let's enumerate the page 


```bash 
Invalid username.
Username: administrator-- -
Password: cualquiercosa 
```
and did not work, let's capture the request with burpSuite if you don't know to use it click [here] (https://zeekk3n.github.io/andrey.github.io/.hacking-notes)

so how i said before let's capture the request

open ```BurpSuite``` > ```proxy``` > ```open browser``` > copy your url + route and paste it in my case will be ```http://192.168.100.52/imfadministrator/``` > turn off the ```interception``` that burpsuite is doing it, now we are able to watch the same loggin platform, let's capture with the burp Suite the comunication when we press ```login``` tab 

i capture this 

```php
POST /imfadministrator/ HTTP/1.1
Host: 192.168.100.52
Content-Length: 17
Cache-Control: max-age=0
Upgrade-Insecure-Requests: 1
Origin: http://192.168.100.52
Content-Type: application/x-www-form-urlencoded
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.5563.65 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer: http://192.168.100.52/imfadministrator/
Accept-Encoding: gzip, deflate
Accept-Language: es-419,es;q=0.9
Cookie: PHPSESSID=rftk9b1ducfunqjmrks8bcfb04
Connection: close

user=asd&pass=asd

```
seems that we can use a method called ```trugglin``` if is not sanitized  

let's try 

the attack consist in to add [] in the field of password and we found some possible users when we were enumerating the port 80 let's try it 
