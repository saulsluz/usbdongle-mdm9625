#!/bin/sh
#
# Copyright (c) 2012-2013, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

send_files(){
    echo "Batching send files"
    scp -r -o "KexAlgorithms=diffie-hellman-group1-sha1" ./app/* root@$SERVER:/
}

install_services(){
    echo "Batching install services"
    add_cmd "/usr/sbin/update-rc.d start_iptables defaults 90 40"
    add_cmd "/usr/sbin/update-rc.d wlan2 defaults 90 40"
    add_cmd "/usr/sbin/update-rc.d start_iplogd defaults 90 40"
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

if [ $# -gt 2 ]; then
    
    if [ $# -eq 4 ]; then
        usage
    fi

    echo "Starting deploy "

    SERVER=$1

    wpa_passphrase "$2" "$3" > app/etc/wlan2/wpa_supplicant.conf

    APSSID="$2"
    APPASSWD="$3"
    if [ ]; then
        APSSID="$4"
        APPASSWD="$5"
    fi

    cat <<EOF > app/etc/wlan2/hostapd.conf
##### Interface & driver configuration #####################
interface=wlan1
#Commenting the bridge interface for now
bridge=bridge0
driver=ar6000
dump_file=/tmp/hostapd.dump
ctrl_interface=/var/run/hostapd

ssid=$APSSID
channel_num=0
ignore_broadcast_ssid=0
#ieee80211n=1
#wifi_mode=bgnmixed
max_num_sta=10
wpa=3
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
wpa_passphrase=$APPASSWD
dtim_period=1
beacon_int=20
wps_state=0
EOF

    send_files
    install_services
    
    #ssh -o "KexAlgorithms=diffie-hellman-group1-sha1" root@$SERVER "true $CMD && /sbin/reboot"
    ssh -o "KexAlgorithms=diffie-hellman-group1-sha1" root@$SERVER "true $CMD"
    if [ $? -gt 0 ];then
        #echo "IP: 192.168.2.1"
        #echo "DHCP: 192.168.2.20-40"
        echo "Deploy done"
    fi
else
    usage
fi