# Developing #
<font size='3'><b>注意</b>：這是一份開發中的檔案，描述一個開發中的功能，而非正式的HOWTO檔案，僅供開發者調試用。檔案中可能包含一些調試信息和專業性內容，檔案中提到的程式和腳本也可能仍不完善。開發完成後會發佈正式的HOWTO檔案。</font>
<br /><br />

## Introduction ##

這份說明描述在dd-wrt路由中手動連接PPTP VPN


## Details ##

### 安裝腳本 ###
登入路由器，並執行以下命令：

_（注：以下命令假定「/jffs/pptp」目錄已經存在，並放置有相應腳本，否則請先按[此頁面](DdwrtPptpJffs.md)或[autoddvpn的說明描述](http://code.google.com/p/autoddvpn/wiki/jffs)操作）_

```
$ mkdir /jffs/pptp/manual
$ cd /jffs/pptp/manual
$ for i in options.vpn ip-up ip-down; do wget http://autoddvpn-beta.googlecode.com/svn/trunk/dev/manualpptp/$i;done;
$ chmod a+x ip-up ip-down
```

### 修改 ###
修改options.vpn檔案：
```
$ vi /jffs/pptp/manual/options.vpn
```
將「`<your_vpn_username>`」修改為您的VPN用戶名；「`<your_vpn_password>`」修改為您的VPN密碼
<br />

如果您未在web界面設置過VPN訊息，則還要在修改ip-up和ip-down檔案（如設置過可跳過，無論PPTP VPN服務是否開啓）：
```
$ vi /jffs/pptp/manual/ip-up
```
將「$(/usr/sbin/nvram get pptpd\_client\_srvsub)」修改為PPTP撥上之後的VPN子網路，「$(/usr/sbin/nvram get pptpd\_client\_srvsubmsk)」改為子網路遮罩（通常為「255.255.255.0」）。不會找的可參考[此教學](http://code.google.com/p/autoddvpn/issues/detail?id=17)
```
$ vi /jffs/pptp/manual/ip-down
```
同上

### 手動連接 ###
先在路由器web頁面把PPTP關閉（或者執行「nvram set pptpd\_client\_enable=0; nvram commit」），並確保pptp沒有在運行（執行命令「/tmp/pptpd\_client/vpn stop; killall -9 pptp」）

手動連接PPTP VPN的命令：
```
$ pptp VPN伺服器IP位址 file /jffs/pptp/manual/options.vpn
```
例如：
```
$ pptp 74.125.128.103 file /jffs/pptp/manual/options.vpn
```
_（上述例子中為虛構IP位址）_

_**注意**：此命令pptp是在前台運行的（只為調試用），因此一旦中止進程或中斷ssh/telnet連接即會導致pptp連接中斷，~~後台手動運行PPTP的腳本會在稍後更新~~。_

#### 後台運行 ####
連接：
```
$ pptp VPN伺服器IP位址 file /jffs/pptp/manual/options.vpn &
```
斷開：
```
$ kill `pidof -s pptp`; sleep 2; kill -9 `pidof -s pptp`
```

#### 自動重連 ####
下載重連程式reconnect.sh至manual目錄，並將pptp目錄下的checkvpn.sh替換為手動連接的VPN檢查腳本，即可實現VPN斷線後自動重連。

命令：
```
$ cd /jffs/pptp/manual
$ wget http://autoddvpn-beta.googlecode.com/svn/trunk/dev/manualpptp/reconnect.sh
$ chmod a+x reconnect.sh
$ cd /jffs/pptp
$ rm -f /jffs/pptp/checkvpn.sh
$ wget http://autoddvpn-beta.googlecode.com/svn/trunk/dev/manualpptp/checkvpn.sh
$ chmod a+x checkvpn.sh
```