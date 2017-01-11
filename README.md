# (::) SECTHEMALL
SECTHEMALL is a bash script that automatically blocks IP using iptables.
It distributes and syncs a **blacklist and whitelist on all your linux server**.
It can store your security logs to the SECTHEMALL Cloud, and make you able to create **Custom Rules** or **Graphical Reports**.
With SECTHEMALL you'll block **Brute Force Attacks, Port Scan, Web Vulnerability Scan**, and more...

# Index
- Requirements
- Installation
- [How it works](#how-it-works)
  - [How the client works](#how-the-client-works)
  - [Authentication](#authentication)
  - [Run the secthemall.sh client](#run-the-secthemallsh-client)
  - Log type
  - [Configuration](#configuration)
  - [Autoconfig](#autoconfig)
  - Events from file
  - Read command output
- Blacklist
  - Block an IP to all your servers
  - Sync a server blacklist
- Cloud
  - Correlation Rules
  - Public Blacklist
- API




# Requirements
SECTHEMALL is centrally orchestrated, so you need a **free** account on secthemall.com but don't worry... 
it takes just few seconds! Just enter your e-mail address, and secthemall.com will do the dirty job for you.

The first time you run the `secthemall.sh` script, it'll check if all required components are present.
The following software must be installed:

- **iptables** (yes... Would you believe it?)
- **openssl** (for encrypt logs before send it)
- **curl** (for the SECTHEMALL API)
- **base64** (for text string encode)



# Installation
You just need to clone the git project and execute the `secthemall.sh` script (it needs root privileges and probably, in some distributions, you should run it using sudo).
```bash
$ cd /opt/
$ clone https://github.com/theMiddleBlue/secthemall.git
$ cd secthemall/
$ ./secthemall.sh -h
```




# How it works
![how it work](https://secthemall.com/img/staentral.001.jpeg)

`secthemall.sh` is a bash script that can read a log file, or the output of a command, and set an iptables rule.
For example, it could reads your `/var/log/auth.log` and block an IP address that fails the ssh authentication for more then 6 times,
or it could read the `access.log` of your nginx server and block an IP address that get more then 20 "page not found" errors.

Each blocked IP address (both IPv4 or IPv6) is added to an iptables rules chain and blocked (with something like `iptables -s <ipv4> -j DROP`).
**All blocked IPs will be sent to your global blacklist on secthemall.com and distributed on all your servers that run the secthemall.sh script.**
Imagine that you have 3 linux server: a brute force attack blocked on the server A will be automatically blocked on servers B and C.

Get a free account on secthemall.com and start to use the secthemall.sh client.
You'll see all your servers events on the secthemall online dashboard, where you can add or remove IP from your global black or white list.
You can also get graphical reports, create correlation rules, get notified by e-mail or telegram when an IP went in blackist, etc...

`secthemall.sh` needs OpenSSL to encrypt your events before send them to the secthemall cloud.
It encrypts all collected events using a unique passphrase generated at the first authentication.




## How the client works
![how it work](https://secthemall.com/img/secthemall-client-howitwork.001.jpeg)

```sh
# ./secthemall.sh -h
+
+ (::) SECTHEMALL
+
+  --help or -h        Show this help
+  --auth              Authenticate with your username and pasword
+  --start             Run client in foreground
+  --background or -b  Run client in background
+  --stop              Stop client
+  --restart           Restart client in background
+
+  --gbladd <ip>       Add <ip> to your Global Blacklist
+  --gbldel <ip>       Delete <ip> to your Global Blacklist
+  --gblshow           Show your Global Blacklist (json)
+  --gwladd <ip>       Add <ip> to your Global Whitelist
+  --gwldel <ip>       Delete <ip> to your Global Whitelist
+  --gwlshow           Show your Global Whitelist (json)
+
+  --lblshow           Show your Local Blacklist (iptables)
+  --lwlshow           Show your Local Whitelist (iptables)
+
+  --getlogs [-q ...]  Get collected logs from your nodes (json)
+


 Example usage:
 ./secthemall.sh --start -b         # this will start the client in background
 ./secthemall.sh --restart          # this will restart the client in background
 ./secthemall.sh --stop             # this will stop the client
 ./secthemall.sh --gbladd 1.2.3.4   # this will add 1.2.3.4 to all your nodes blacklist

```

### secthemall.sh is not a Remote Control!



## Authentication
Once you have successfully completed the registration, the first time you run the client it will ask you to enter your username, password and a server alias.
Server alias is a name (or a label) that you choose which the client will assign to all collected events.
An alias can be, for example, something like "my-webserver" or "database1" or "my-application-node1".

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

Server alias, allowed chars [a-zA-Z0-9] and "-" (ex: web-server-1): mywebsite-node1
```




## Run the secthemall.sh client
[![asciicast](https://asciinema.org/a/1rpn93kcmmixwsndaf9jlud6d.png)](https://asciinema.org/a/1rpn93kcmmixwsndaf9jlud6d)




## Log type
SECTHEMALL can collect events from different sources. For doing it, it uses different type of parsers that we call: "logtype".
Following, a list of supported logtype:

<table>
	<tr><td><b>SSH</b></td> <td>collects all authentication events from sshd</td></tr>
	<tr><td><b>iptables</b></td> <td>collects events from iptables rule logs (or from UFW)</td></tr>
	<tr><td><b>nginx_access</b></td> <td>collects events from Nginx access.log (only 40x and 50x HTTP response status)</td></tr>
	<tr><td><b>netstat</b></td> <td>collects events from the netstat system command</td></tr>
	<tr><td><b>CEF</b></td> <td>collects events using <b>C</b>ommon <b>E</b>vent <b>F</b>ormat syntax</td></tr>
</table>




## Configuration
`secthemall.sh` needs to be configured to collect events from log files or commands output.
Just edit the file `conf/parser.conf` and follow the instructions inside it. For example:

```sh
# this will parse logs in the auth.log with type SSH
/var/log/auth.log ".*sshd.*password.*" "SSH"

# this will read the output of "/bin/netstat -ltunp" command
cmd "netstat" "mynetstat" "/bin/netstat -ltunp"

# this will read the access.log inside a docker container
cmd "nginx_access" "my-webserver" "docker exec -t mycontainer grep 404 /usr/local/nginx/logs/access.log"
```




## Autoconfig
If you want a quick-and-dirty configuration, you could use the `--autoconf` parameter:
```sh
# ./secthemall.sh --autoconf
+ [ INFO   ] Trying to find intresting log files...

# copy under this line and paste in conf/parser.conf
# --------------------------------------------------
/var/log/auth.log "sshd.*password.*" "SSH"
/var/log/kern.log "MAC.+SRC.+DST.+PROTO.+DPT" "iptables"
/var/log/ufw.log "MAC.+SRC.+DST.+PROTO.+DPT" "iptables"
/var/log/nginx/access.log "HTTP\/[0-9\.]+. (4|5)[0-9]{2,2} " "nginx_access"
cmd "netstat" "netstat_listen" "/bin/netstat -ltunp"
# --------------------------------------------------
```
In this case, the client will look for any interesting log file that could contain ssh logs, web server logs, iptables logs and more.
It will suggest you a configuration that you can put in `conf/parser.conf` and start to collect events.




## Events from file
secthemall.sh can read a file and collect events from it, using one of the secthemall parser (logtype). For make the client able to read a file, you need to configure it on `conf/parser.conf` using the following syntax:
```sh
<path to file> "<filter>" "<logtype>"
```
First of all, pay attention to the double quotes! The double quotes must be used for the filter and logtype but not for the file path.

**&lt;filter&gt;** it should be a regular expression, or a text string, that will be used to filter the content of the file using the `egrep` command. 
Something like: `cat <path to file> | egrep "<filter>"`.

**&lt;logtype&gt;** is one of the [secthemall logtype parser](#log-type)


## Read command output


# Blacklist
## Block an IP to all your servers
## Sync a server blacklist


# Cloud
## Correlation Rules
## Public Blacklist
A public blacklist collects all security events, of all SECTHEMALL users, and makes a "bad reputation" database that you could use to block attackers on your servers.
The purpose of these lists is to prevent attacks before they occur on your servers. For example: if an IP address has already attacked 10 SECTHEMALL users,
you could take advantage of this information and block the threat before it comes true.

**All IP addresses in these lists will expire after 7 days** from the date of inclusion.
You just need to click on the "subscribe" button to add this blacklist to one (or all) of your nodes.
Remember that you'll not receive a notification when an IP goes in any of the following lists.

# API


# Thanks to
thanks to @maxtsepkov for [bash_colors](https://github.com/maxtsepkov/bash_colors)
