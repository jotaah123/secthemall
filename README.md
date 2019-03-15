<p align="center">
<a href="https://secthemall.com"><img width="400" src="https://secthemall.com/img/sta_logo_white.png"></a><br><br>
<img src="https://img.shields.io/badge/style-GPL-blue.svg?style=flat&label=license">
<a href="https://secthemall.com"><img src="https://img.shields.io/badge/style-client-green.svg?style=flat&label=bash"></a>
<a href="https://twitter.com/secthemall"><img src="https://img.shields.io/twitter/follow/secthemall.svg?style=social&label=Follow&maxAge=2592000"></a>
</p>

<br>

# SECTHEMALL Bash Client
SECTHEMALL is a Bash script that automatically blocks IP's using iptables.
It distributes and syncs **a blacklist and a whitelist on all your Linux servers**.
It can store your security logs to the SECTHEMALL Cloud, and let's you create **Custom Rules** and **Graphical Reports**.
With SECTHEMALL you'll block **Brute Force Attacks, Port Scans, Web Vulnerability Scans** and more...

<br>

# Index
- [Requirements](#requirements)
- [Installation](#installation)
- [How it works](#how-it-works)
  - [How the client works](#how-the-client-works)
  - [Authentication](#authentication)
  - [Run the secthemall.sh client](#run-the-secthemallsh-client)
  - [Log types](#log-types)
  - [Configuration](#configuration)
  - [Autoconfig](#autoconfig)
  - [Events from file](#events-from-file)
- [Fail2ban](#fail2ban)
  - [Action configuration](#fail2ban-action-configuration)
  - [Jail configuration](#fail2ban-jail-configuration)
- Cloud
  - [Infrastructure](#infrastructure)
  - [Block whole country](#block-whole-country)
- [API](#API)

<br>

# Requirements
SECTHEMALL is centrally orchestrated, so you need a **free** account on secthemall.com but don't worry... 
it takes just a few seconds! Enter your e-mail address and secthemall.com will do the dirty job for you.

The first time you run the `secthemall.sh` script, it'll check if all required components are present.
The following software must be installed:

- **iptables** (yes... Would you believe it?)
- **OpenSSL** (for encrypting logs before sending them)
- **curl** (for the SECTHEMALL API)
- **base64** (for text string encoding)

<br>

# Installation
You just need to clone the git project and execute the `secthemall.sh` script (it requires `root` privileges, and probably, in some distributions, you should run it using `sudo`).

```bash
$ cd /opt/
$ git clone https://github.com/theMiddleBlue/secthemall.git
$ cd secthemall/
$ ./secthemall.sh -h
```

<br>

# How it works
![how it work](https://secthemall.com/img/staentral.001.jpeg?nocache=0002)

`secthemall.sh` is a Bash script that can read a log file, or the output of a command, and set an iptables rule.
For example, it could read your `/var/log/auth.log` and block an IP address that fails the ssh authentication for more than six times,
or it could read the `access.log` of your Nginx server and block an IP address that gets more than 20 "page not found" errors.

Each blocked IP address (both IPv4 or IPv6) is added to an iptables rules chain and blocked (with something like `iptables -s <ipv4> -j DROP`).
**All blocked IP's will be sent to your global blacklist on secthemall.com and distributed on all your servers that run the secthemall.sh script.**
Imagine that you have 3 Linux servers: an IP blocked for a brute force attack on the server A will be automatically blocked on servers B and C.

Get a free account on secthemall.com and start using `secthemall.sh` client.
You'll see all your servers events on the **secthemall online dashboard**, where you can add or remove IP's from your global black or white list.
You can also get graphical reports, create custom rules, get notified by e-mail or telegram when an IP went in the blacklist, etc...

`secthemall.sh` needs OpenSSL to encrypt your events before sending them to the secthemall cloud.
It encrypts all collected events using a unique passphrase generated at the first authentication.

<br>

## How the client works
![how it works](https://secthemall.com/img/secthemall-client-howitwork.001.jpeg)

```sh
# ./secthemall.sh -h
+
+ (::) SECTHEMALL
+
+  --help or -h        Show this help
+  --auth              Authenticate with your username and password
+  --start             Run client in foreground
+  --background or -b  Run client in background
+  --stop              Stop client
+  --restart           Restart client in background
+
+  --gbladd <ip>       Add <ip> to Global Blacklist
+  --gbldel <ip>       Delete <ip> to Global Blacklist
+  --gblshow           Show Global Blacklist (json)
+  --gwladd <ip>       Add <ip> to Global Whitelist
+  --gwldel <ip>       Delete <ip> to Global Whitelist
+  --gwlshow           Show Global Whitelist (json)
+
+  --lblshow           Show Local Blacklist (iptables)
+  --lwlshow           Show Local Whitelist (iptables)
+
+  --getlogs <search>  Get collected logs from all nodes (json)
+


 Examples usage:
 ./secthemall.sh --start -b                                  # start the client in background
 ./secthemall.sh --restart                                   # restart the client in background
 ./secthemall.sh --stop                                      # stop the client
 ./secthemall.sh --gbladd 1.2.3.4                            # add 1.2.3.4 to Global Blacklist
 ./secthemall.sh --getlogs "ssh and geo.countryname:china"   # add 1.2.3.4 to Global Blacklist

```

<br>

## Authentication
Once you have completed the registration, the first time you run the client it will ask you to enter your username, password and a server alias.
Server alias is a unique name that you choose for your server, and it will be assigned to all the events collected from that server.
An alias could be, for example, something like "my-webserver" or "database1" or "my-application-node1".

A valid alias can contain the following characters:

- Lowercase characters [a-z]
- Numbers [0-9]
- Dash character [-]

```sh
# ./secthemall.sh --auth
+
+ (::) SECTHEMALL
+
+  INFO     Initializing Security Dashboard client on /usr/local/secthemall
+  INFO     With PID 1337 saved in /usr/local/secthemall/conf/client.pid
+

Authentication:
Insert your secthemall.com Username and Password

Username: themiddle@secthemall.com
Password: *********

Insert Server Alias.
Allowed chars [a-z0-9] and "-" (ex: web-server-1)
Alias: mywebsite-node1
```

<br>

## Run the secthemall.sh client
[![asciicast](https://asciinema.org/a/1rpn93kcmmixwsndaf9jlud6d.png)](https://asciinema.org/a/1rpn93kcmmixwsndaf9jlud6d)

<br>

## Log types
SECTHEMALL can collect events from different sources using various types of parsers that we call: "logtype".
Following, a list of supported log types:

<table>
    <tr><td><b><i>logtype</i></b></td> <td><i>description</i></td></tr>
    <tr><td><b>SSH</b></td> <td>authentication events from sshd</td></tr>
    <tr><td><b>iptables</b></td> <td>iptables rule logs (or UFW)</td></tr>
    <tr><td><b>HTTP</b></td> <td>Web server access.log (only 40x and 50x HTTP response status)</td></tr>
    <tr><td><b>netstat</b></td> <td>events from the netstat system command</td></tr>
    <tr><td><b>fail2ban</b></td> <td>events from fail2ban log file</td></tr>
    <!-- <tr><td><b>CEF</b></td> <td>parses events using <b>C</b>ommon <b>E</b>vent <b>F</b>ormat syntax</td></tr> -->
</table>

<br>

## Configuration
`secthemall.sh` needs to be configured to collect events from logs files or commands outputs.
Just edit the file `conf/secthemall.conf` and follow the instructions inside it. For example:

```sh
# this will parse logs in the auth.log with type SSH
/var/log/auth.log ".*sshd.*password.*" "SSH"

# this will read the output of "/bin/netstat -ltunp" command
cmd "netstat" "mynetstat" "/bin/netstat -ltunp"

# this will read the access.log inside a docker container
cmd "HTTP" "my-webserver" "docker exec -t mycontainer grep 404 /usr/local/nginx/logs/access.log"
```

<br>

## Autoconfig
If you want a quick-and-dirty configuration, you could use the `--autoconf` parameter:
```sh
# ./secthemall.sh --autoconf
+ [ INFO   ] Trying to find interesting log files...

# copy under this line and paste in conf/secthemall.conf
# --------------------------------------------------
/var/log/auth.log "sshd.*password.*" "SSH"
/var/log/kern.log "MAC.+SRC.+DST.+PROTO.+DPT" "iptables"
/var/log/ufw.log "MAC.+SRC.+DST.+PROTO.+DPT" "iptables"
/var/log/nginx/access.log "HTTP\/[0-9\.]+. (4|5)[0-9]{2,2} " "HTTP"
cmd "netstat" "netstat_listen" "/bin/netstat -ltunp"
# --------------------------------------------------
```
In this case, the client will look for any interesting log file that could contain ssh logs, web server logs, iptables logs and more.
It will suggest you a configuration to include in the file `conf/secthemall.conf` so it can start collecting the events.

<br>

## Events from file
secthemall.sh can read a file and collect events from it using one of the secthemall parser (logtype). For making the client able to read a file, you need to configure it on `conf/secthemall.conf` using the following syntax:
```sh
<path to file> "<filter>" "<logtype>"
```
First of all, pay attention to the double quotes! The double quotes must be used for the filter and logtype but not for the file path.

**&lt;filter&gt;** it should be a regular expression, or a text string, that will be used to filter the content of the file using the `egrep` command. 
Something like: `cat <path to file> | egrep "<filter>"`.

**&lt;logtype&gt;** is one of the [secthemall logtype parser](#log-type)

<br>

# Fail2ban
SECTHEMALL is also compatible with fail2ban: You can integrate all ban made by fail2ban in your global blacklist and distribute it to all your nodes.
For doing it, you just need to create a fail2ban action and assign it to your jail. For example:

<br>

## Fail2ban action configuration
On Ubuntu, create the file `/etc/fail2ban/action.d/secthemall.conf` with the following configuration:
```
[Definition]

# ban using --gbladd parameter of secthemall.sh script
actionban = /opt/secthemall/secthemall.sh --gbladd <ip>

# unban using --gbldel parameter of secthemall.sh script
actionunban = /opt/secthemall/secthemall.sh --gbldel <ip>

actionstart =
actionstop =
actioncheck =
```

<br>

## Fail2ban jail configuration
Once you configure the `secthemall` action, you can assign it to your jail configuration. For example:
```
[ssh]

enabled  = true
filter   = sshd
action   = iptables[name=SSH, port=ssh, protocol=tcp]
           secthemall
logpath  = /var/log/auth.log
maxretry = 3
```

Now you can restart fail2ban (with something like `/etc/init.d/fail2ban restart`).
From this moment, whenever Fail2ban blocks (or unblocks) an IP address, it will be distributed to all your secthemall nodes.

<br>

# Cloud
## Infrastructure
![Infrastructure](https://secthemall.com/img/globemap.001.jpeg?nocache=1)

<br>

## Block whole country
from the SECTHEMALL dashboard, you can easily block a whole country IP range with just a click:
![](https://secthemall.com/img/blockcountry_ss.png)

<br>

## SECTHEMALL Blacklists
SECTHEMALL Blacklists is a continuously updated database of bad reputation IP addresses. It allows you to block all potential attackers on your servers preemptively. For example: if an IP address has already attacked ten SECTHEMALL users, you could take advantage of this information and block the threat before it attacks your server.

**All IP addresses in these lists will expire after seven days** from the date of inclusion.
You just need to click on the "subscribe" button on secthemall.com to add blacklists to one (or all) of your nodes.

<br>

# API
[https://secthemall.com/api/](https://secthemall.com/api/)

<br>

# Thanks to
thanks to @maxtsepkov for [bash_colors](https://github.com/maxtsepkov/bash_colors)
