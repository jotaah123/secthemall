# (::) SECTHEMALL
SECTHEMALL is a bash script that distributes and syncs a **blacklist on all your linux server** using iptables.
It can store your logs to the SECTHEMALL cloud and make you able to create **correlation rules** or **graphical reports**.
With SECTHEMALL you can block **Brute Force Attacks, Port Scan, Web Vulnerability Scan**, and more...

## Index
- How the client work

## How the client work
```sh
# ./secthemall.sh -h
+
+ (::) SECTHEMALL
+
+  --help or -h        Show this help
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

thanks to @maxtsepkov for [bash_colors](https://github.com/maxtsepkov/bash_colors)
