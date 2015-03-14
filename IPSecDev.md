# Developing #
<font size='3'><b>注意</b>：這是一份開發中的檔案，描述一個開發中的功能，而非正式的HOWTO檔案，僅供開發者調試用。檔案中可能包含一些調試信息和專業性內容，檔案中提到的程式和腳本也可能仍不完善。開發完成後會發佈正式的HOWTO檔案。</font>
<br /><br />

## Introduction ##

這份說明描述在dd-wrt路由中連接Cisco IPSec VPN


## Details ##

### 安裝腳本 ###


### 修改 ###
修改/tmp/vpnc/config.conf檔案：
```
IPSec gateway VPN_IP_address
IPSec ID VPN_group_name
IPSec secret VPN_group_password
Xauth username VPN_username
Xauth password VPN_password
NAT Traversal Mode cisco-udp
```

### 連接 ###
**連接VPN伺服器**：
```
$ vpnc /tmp/vpnc/config.conf
```

## References ##
  1. [路由器上使用 Cisco IPSec VPN client | Daily Publish](https://w3.owind.com/pub/%E8%B7%AF%E7%94%B1%E5%99%A8%E4%B8%8A%E4%BD%BF%E7%94%A8-cisco-ipsec-vpn-client/)
  1. [VPNC - DD-WRT Wiki](http://www.dd-wrt.com/wiki/index.php/VPNC)