---
layout: single
title: '<span class="Articles"> Wifi Monitor mode - /Articles</span>'
excerpt: "Wifi Monitor mode in order to monitoring all the air wifi spectrum, this is the introduccion of hacking hardware "
date: 2023-04-30
header:

  teaser_home_page: true



categories:

  - article
  - hacking hardware
  - hardware
tags:  
  - Tp-link
  - MonitorMode
  - spectrum
  - wifi

toc: true
toc_label: "Content"
toc_sticky: true
show_time: true
---


Learn how to use the monitor mode is important if you want to learn about Hacking hardware because is low cost and anyone can do it because is easy try them in under control enviroments.


First you have to buy a TL-WN722N  150Mbps High Gain Wireless USB Adapter | is the cheapest but there's a lot of wireless usb adapters to enter in Monitor mode. 
Make sure that the one that you buy supports monitor mode. or just buy the one that i chosed for the example [TL-WN722N](https://www.amazon.com/-/es/Tp-Link-TL-WN722N-IEEE-802-11n-borrador/dp/9800359850)

# Supports
* Android 12/13
* MESH Support
* Monitor mode
* Frame injection
* Up to kernel v6.0+
* Wifi Attacks
* Parrot (does not work for Kali)

## installation

1. You will need to blacklist another driver in order to use this one.
2. ```echo 'blacklist r8188eu'|sudo tee -a '/etc/modprobe.d/realtek.conf'```
3. Reboot
4. cd rtl8188eus
5. ```make && sudo make install```
6. Reboot in order to blacklist and load the new driver/module.

# MONITOR MODE How to turn on
Use these steps to enter monitor mode.

```bash
$ sudo airmon-ng check kill
$ sudo ip link set <interface> down
$ sudo iw dev <interface> set type monitor
```

Frame injection test may be performed with
(after kernel v5.2 scanning is slow, run a scan or simply an airodump-ng first!)

```
$ aireplay -9 <interface>
```

# NetworkManager configuration
Add these lines below to "NetworkManager.conf" and ADD YOUR ADAPTER MAC below [keyfile]
This will make the Network-Manager ignore the device, and therefore don't cause problems.
```
[device]
wifi.scan-rand-mac-address=no

[ifupdown]
managed=false

[connection]
wifi.powersave=0

[main]
plugins=keyfile

[keyfile]
unmanaged-devices=mac:A7:A7:A7:A7:A7
```

# if does not work try these steps
1
```sudo apt install linux-headers-amd64```

This command installs the Linux headers for the AMD64 architecture. The headers contain source code that is needed to build and compile certain software packages.

2

```rmmod r8188eu.ko```

This command removes the kernel module named r8188eu.ko. A kernel module is a piece of code that can be dynamically loaded into the Linux kernel to extend its functionality.

3

```sudo rmmod r8188eu.ko```


This command is similar to the previous one, but it uses sudo to run the command with superuser privileges. This is necessary because only the superuser can remove kernel modules.

4

```bash
git clone https://github.com/aircrack-ng/rtl8188eus
```

This command clones a git repository from the given URL. In this case, it is the repository for the RTL8188EUS wireless chipset driver.

5

```bash
cd rtl8188eus
```

This command changes the current working directory to the newly cloned git repository.

6
```bash
make
```
This command compiles the source code of the driver.
7
```bash
sudo make install
```

This command installs the compiled driver.

8
```bash
sudo modprobe 8188eu
```
This command loads the newly installed kernel module into the Linux kernel.
9
```bash
sudo airmong-ng
```
This command starts the airmong-ng tool, which is used for wireless network monitoring.
10
```bash
sudo airmon-ng
```
This command starts the airmon-ng tool, which is used for monitoring wireless network interfaces.
11
```bash
clear
```
This command clears the terminal screen.
12
```bash
sudo airmon-ng
```
This command starts the airmon-ng tool again.
13
```bash
sudo airmon-ng start wlx28ee520d56f1
```
This command puts the wireless interface with the name wlx28ee520d56f1 into monitor mode.
14
```bash
sudo airmon-ng check kill
```
This command kills any processes that might interfere with the wireless monitoring.
15
```bash
sudo airmong-ng start wlx28ee520d56f1
```
This command starts the airmong-ng tool again.
16
```bash
sudo airmon-ng start wlx28ee520d56f1
```
This command puts the wireless interface with the name wlx28ee520d56f1 into monitor mode again.
17
```bash
sudo airodump-ng wlx28ee520d56f1
```
This command starts the airodump-ng tool, which is used for capturing wireless network traffic.

## usage


now how you are capturing wireless network traffic, you can execute every single attack you want

examples



[Global Deauthentication Attack (Broadcast MAC Address)](https://zeekk3n.github.io/andrey.github.io/.hacking-notes)

[Fake Authentication Attack](https://zeekk3n.github.io/andrey.github.io/.hacking-notes)

[Beacon Flood Mode Attack](https://zeekk3n.github.io/andrey.github.io/.hacking-notes)

[Disassociation Amok Mode Attack](https://zeekk3n.github.io/andrey.github.io/.hacking-notes)

[Michael Shutdown Exploitation Attack](https://zeekk3n.github.io/andrey.github.io/.hacking-notes)

[Passive Exploitation Techniques](https://zeekk3n.github.io/andrey.github.io/.hacking-notes)

[Installation, Compilation, and Validation of HandShake with Pyrit](https://zeekk3n.github.io/andrey.github.io/.hacking-notes)

[Analysis of Probe Request packets](https://zeekk3n.github.io/andrey.github.io/.hacking-notes)

[Analysis of Probe Response packets](https://zeekk3n.github.io/andrey.github.io/.hacking-notes)

[Analysis of Association Request packets](https://zeekk3n.github.io/andrey.github.io/.hacking-notes)

[Analysis of Association Response packets](https://zeekk3n.github.io/andrey.github.io/.hacking-notes)



Happy hacking !!


