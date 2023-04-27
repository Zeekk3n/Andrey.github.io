---
layout: single
title: '<span class="Articles"> SQLINJECTIONS - /Articles</span>'
excerpt: "System Solaris Administrator Engineer "
date: 2023-04-26
header:

  teaser_home_page: true



categories:

  - article
  - machine
  - Web Applications / API
tags:  
  - wordpress
  - Oraclein
  - SQLin
  - privilege-escalation
  - web
  - php
  - reverse-shell
  - wpscan
  - windows
  - linux
toc: true
toc_label: "Content"
toc_sticky: true
show_time: true
---


SQLinjections  are important if you want to try your lucky in Bugbounty or pentesting Web Labs, I highly recommend you to always try them in pages that you are searching for vulnerabilities 

**We will see all this from the perspective and methodology of a penetration test.**

# RH

How do you manage packages in Solaris?

Solaris uses the pkg command for package management. To install a package, you would use the pkg install command followed by the package name. To remove a package, you would use pkg uninstall. You can also use pkg update to update installed packages to the latest version.


How do you configure and manage network interfaces in Solaris?

Solaris uses the ifconfig command to configure network interfaces. To view the current configuration of a network interface, you would use the command ifconfig <interface name>. To configure an interface, you can use the ifconfig <interface name> <options> command.

  
How do you set up and manage user accounts in Solaris?

User accounts in Solaris can be managed using the useradd and usermod commands. To create a new user account, you would use useradd <username>. To modify an existing user account, you would use usermod <options> <username>.


What are some common troubleshooting techniques you use in Solaris?

Common troubleshooting techniques in Solaris include checking system logs, running system diagnostics, and checking for hardware or network issues. You can also use the truss command to trace system calls made by a process and identify issues.

  
How do you configure and manage ZFS file systems in Solaris?

ZFS file systems in Solaris can be managed using the zfs command. To create a new ZFS file system, you would use zfs create <filesystem name>. To set properties for a file system, you would use zfs set <property> <value> <filesystem name>.

  
How do you configure and manage Solaris zones?

Solaris zones can be managed using the zonecfg command. To create a new zone, you would use zonecfg -z <zone name>. You can then use add net to add a network interface to the zone and set address to configure the IP address for the interface.

How do you manage system performance in Solaris?

System performance in Solaris can be monitored using the vmstat, prstat, and iostat commands. You can also use the sar command to collect system performance data over time.

  
How do you configure and manage system backups in Solaris?

System backups in Solaris can be managed using the ufsdump and ufsrestore commands. You can use ufsdump to create a backup of a file system and ufsrestore to restore the backup.

 What are some common networking protocols used in Solaris?

Common networking protocols used in Solaris include TCP/IP, IPv4, and IPv6.

  
How do you troubleshoot network connectivity issues in Solaris?

Troubleshooting network connectivity issues in Solaris can involve checking network interfaces, routing tables, and system logs. You can use the ping command to test connectivity to a network host.

  
How do you configure and manage network routing in Solaris?

Network routing in Solaris can be managed using the route command. To view the current routing table, you would use netstat -rn. To add a new route, you can use the route add command.

How do you set up and manage DNS in Solaris?

DNS in Solaris can be managed using the svccfg command to configure the DNS client service. You can use

  
Teach

# Solaris Admin Infrastructure:

How do you create a new logical volume in Solaris?

A/s: Use the metainit command to create a new metadevice, then format the metadevice with a file system.

How do you extend an existing logical volume in Solaris?
A/s: Use the metattach command to add a new slice to the existing metadevice, then extend the file system using growfs.

How do you check the status of a logical volume in Solaris?

A/s: Use the metastat command to check the status of the metadevice and its components.

# Solaris Admin Network:

How do you configure network interfaces in Solaris?

A/s: Use the ifconfig command to configure network interfaces, or use the netcfg utility to configure network settings persistently.

How do you troubleshoot network connectivity issues in Solaris?

A/s: Use the ping command to test network connectivity, check network interface configurations using ifconfig, and check routing tables using netstat -rn.

How do you configure network routing in Solaris?

A/s: Use the route command to add or remove routes, or use the defaultrouter property in the /etc/defaultrouter file to set a default gateway.

Solaris Admin Troubleshooting:

How do you troubleshoot system boot issues in Solaris?

A/s: Use the boot -v command to boot the system in verbose mode and identify any issues during the boot process.

How do you troubleshoot storage device issues in Solaris?

A/s: Use the cfgadm command to check the status of storage devices and their connections, and use the format command to view and modify disk partitioning and labeling.

How do you troubleshoot system performance issues in Solaris?

A/s: Use the prstat command to monitor system processes and resource usage, and use the vmstat command to monitor system memory usage and paging activity.

## Solaris Admin Services:


How do you manage Solaris services?

A/s: Use the svcadm command to start, stop, enable, or disable Solaris services.

How do you configure Solaris services to start automatically at boot time?

A/s: Use the svccfg command to modify the service configuration and enable automatic startup using the svcadm enable command.

How do you replace a failed KVM mirror in Solaris?

Answer: Use the zpool command to identify the failed mirror and its replacement disk, then use the zpool replace command to replace the failed disk with the new one.

These are just a few possible technical interview questions for System Solaris Administrator Engineer position. I am still adding questions while i am getting more experience.

Happy hacking !
