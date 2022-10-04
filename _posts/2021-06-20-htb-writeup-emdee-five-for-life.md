---
layout: single
title: '<span class="hackthebox">Emdee Five For Life - Hack The Box Challenge</span>'
excerpt: "Emdee Five For Life is a web challenge where you will have to encrypt as fast as possible to get the flag."
date: 2021-06-20
header:
  teaser: /assets/images/htb-writeup-emdee-five-for-life/icon.png
  image_description: emdee five for life hack the box
  teaser_home_page: true
  icon: /assets/images/hackthebox.webp
  icon_description: hackthebox
categories:
  - hackthebox
  - challenge
tags:  
  - web
  - md5
  - cipher
  - scripting
toc: true
toc_label: "Content"
toc_sticky: true
show_time: true
---

<a href="/assets/images/htb-writeup-emdee-five-for-life/hackthebox.png">
    <img src="/assets/images/htb-writeup-emdee-five-for-life/hackthebox.png">
</a>

We start the web instance and when we access we will see the following interface:

<a href="/assets/images/htb-writeup-emdee-five-for-life/page.png">
    <img src="/assets/images/htb-writeup-emdee-five-for-life/page.png">
</a>

The string displayed by the page changes every time we visit it. Also, when entering the MD5 hash of the string "by hand" we will get a message saying "Too slow!"

From this message we can deduce that the challenge consists of encrypting the string and sending it as quickly as possible.

This is a really easy challenge, and there are a few ways to do it, I'll show u two, the first using curl and some bash commands via the command line, and the second using a python script (several ways to do it)

## Using curl and the command line:

* curl: It allows us to interact with the page via HTTP requirements (GET to obtain the content and POST to send the response).
* grep: It allows us to extract the useful content from the content of the web page, that is, the string to encode.
* tr: Very important to obtain the flag, it helps us to eliminate unwanted characters from some input/output.
* md5sum: With this command we carry out the encryption of the string.

With these commands, we execute the following line in the console to obtain the flag:

```bash
curl -s http://178.62.14.240:30096/ -X POST -d hash=$(curl -s http://209.97.187.224:31840/ -c cookie.txt | grep -oP "(?<=h3 align='center'>).*(?=</)" | tr -d "\n" | md5sum | tr -d -) -b cookies.txt
```

* We have to replace this line ```http://178.62.14.240:30096/``` (in both cases) with the line that hack the box gives us when starting an instance

* The curl command used to send the hash (POST request) is input the output of another command using the syntax curl <url> -X POST -d hash = $ (curl ...). On the other hand, the -c and -b flags are used to save / read a file with the session cookies.

* The argument -oP “(? <= H3 align = 'center'>). * (? = /)” Of the grep command is to get the string that is between the two strings that are in parentheses.

* Linux commands contain a line break (```\n```) at the end of their output, so that the output and the next input are on separate lines. If we do not use tr-d "n" we will be passing the string with the line break included to the md5sum command, resulting in an erroneous hash.

* In addition to the above, when the output of another command is passed to md5sum using a pipe, it returns a dash (-) at the end of the hash, so it is necessary to use tr -d - to remove it and send the input.

**It is worth mentioning that this command does not work 100% of the time (apparently it requires a good internet connection).**


## Using a Python script

The procedure is the same, but in this case we are more likely to obtain the flag.

There are two scripts, one if you want to modify the url in the code and the other if you want to pass the url as a parameter.

```python
#!/usr/bin/env python3

import requests
import hashlib
import sys

URL = ""

if (len(sys.argv)==2):
	URL=sys.argv[1]#taking arg as the url/target

else:
    print("-------------------------- ERROR FOUND -----------------------")
    print("Usage: "+str(sys.argv[0])+"http://url:port") # error msg
    exit()
    

# Get PHPSESSID


def get_cookie():
    response = requests.get(URL)
    headers = dict(response.headers)
    return headers["Set-Cookie"]

# Get value from response string


def get_value(data, type=False):
    tagsrt = ""
    tagend = ""
    if type:
        tagsrt = "<p align='center'>"
        tagend = "</p>"
    else:
        tagsrt = "<h3 align='center'>"
        tagend = "</h3>"
    return data[data.find(tagsrt)+len(tagsrt):data.rfind(tagend)]

# Main function


def main():
    print("[*] Getting cookie...")
    cookie = get_cookie()

    print("[*] Asking for data to hash...")
    data = requests.get(URL, headers={'cookie': cookie}).text
    value = get_value(data)
    md5 = hashlib.md5(value.encode()).hexdigest()

    print("[*] Sending hash...")
    data = requests.post(URL, data={'hash': md5}, headers={
                         'cookie': cookie}).text
    flag = get_value(data, True)

    print("[*] Retreiving data...")
    print("Flag: " + flag)


if __name__ == '__main__':
    main()
```

Output:

```bash
[*] Getting cookie...
[*] Asking for data to hash...
[*] Sending hash...
[*] Retreiving data...
Flag: HTB{XXXXXXXXXXXXXXX}
```

Bye