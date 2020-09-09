## DNS
1. confirm "Never forward non-FQDNs" and "Never forward reverse lookups for private IP ranges" are unchecked
2. Set up **conditional forwarding**
3. [edit /etc/pihole/setupVars.conf](https://www.reddit.com/r/pihole/comments/a9ktnl/getting_pihole_to_do_reverse_lookup/) and add the reverse lookups:
    ```CONDITIONAL_FORWARDING_REVERSE=10.in-addr.arpa```
4. Run ```pihole -r``` to repair using the updated setupVars.conf file