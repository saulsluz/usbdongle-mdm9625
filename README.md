# usbdongle-mdm9625

### Whata?
Small piece of implementations to explore more possibilities and features that are available at MDM9625 dongle

### What it can do
Until now It's possible to turn this device in a little Wifi Repeater or just a SSH jumper over Wifi/GSM. It's possible to read  SMS messages in JSON format too.

### How to use

Get some device, plug n deploy it using shell:

```sh
Usage: ./deploy.sh <address> <ssid> <passphrase> [<ssid> <passphrase>] 
Example
As repetear
  deploy.sh 192.168.1.1 Home 1234#5678
As client
  deploy.sh 192.168.1.1 Home 1234#5678 NewAP new#pass
```

### Whish list
- Send SMS messages
- fix bugs
