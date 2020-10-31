#!/bin/sh

send_files(){
    echo "Batching send files"
    scp -r -o "KexAlgorithms=diffie-hellman-group1-sha1" ./app/* root@$SERVER:/
}

remove_services(){
    echo "Batching remove services"
    add_cmd "/usr/sbin/update-rc.d -f start_telnetd_le remove"
    add_cmd "/usr/sbin/update-rc.d -f avahi-dnsconfd remove"
    add_cmd "/usr/sbin/update-rc.d -f wlan remove"
}

reinstall_services(){
    echo "Batching ReInstall services"
    add_cmd "/usr/sbin/update-rc.d -f wlan2 remove"
    add_cmd "/usr/sbin/update-rc.d wlan2 defaults 50"
    add_cmd "/usr/sbin/update-rc.d -f busybox-cron remove"
    add_cmd "/usr/sbin/update-rc.d busybox-cron defaults 60"
    add_cmd "sleep 1"
}

restart_services(){
    echo "Batching Restart services"
    add_cmd "/etc/init.d/wlan2 restart $1 $2 $3 $4"
    add_cmd "/etc/init.d/busybox-cron restart"
}

add_cmd(){
    CMD="$CMD && $1"
}

usage(){

    echo "Usage: $0 <address> <ssid> <passphrase> [<ssid> <passphrase>] "
    echo "Example"
    echo "As repetear"
    echo "  deploy.sh 192.168.1.1 Home 1234#5678"
    echo "As client"
    echo "  deploy.sh 192.168.1.1 Home 1234#5678 NewAP new#pass"
    exit 1
}

if [ ! -z $1 ] && [ ! -z $2 ] && [ ! -z $3 ]; then
    if [ ! -z $4 ] && [ -z $5 ]; then
        usage
    else
        SERVER=$1

        send_files
        remove_services
        reinstall_services
        restart_services $2 $3 $4 $5
        
        ssh -o "KexAlgorithms=diffie-hellman-group1-sha1" root@$SERVER true "$CMD"
    fi
else
    usage
fi