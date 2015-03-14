## Introduction ##

這份說明描述在dd-wrt路由中，連接多個PPTP VPN，並根據速度（ping值）和連通性自動選擇、切換，目前仍為構想，但已經有了一些思路，會在這個wiki頁面持續更新。


## Details ##

### 實現方法 ###
#### 方案1 ####
通過pptp程式同時建立多條VPN連接，每個相應的時間（如1min）ping一下所有的ppp連接網關，並將默認網關更改為ping值最小的

**優點**：可以保障時時得到最佳網速。

**缺點**：由於對外連接的IP位址頻繁更換，可能導致一些網路客戶端的不穩定（可以通過將IP位址加入custom\_list自定義直連列表解決，但如果是被牆的服務就沒有辦法了）；而且由於可能在短時間內頻繁更換IP位址而被一些網站（如facebook）認為是不安全行為而暫停甚至封鎖帳號；另外就是這樣必須使用classicMode，因為頻繁更換網關的話如果是graceMode腳本執行量太大很不方便；又由於這樣需要對每個pptp連接同時進行守護（確保斷線後自動重連），而需要對多個pptp進程的pid進行辨別，導致實現的難度較大

#### 方案2 ####
不同時建立多條VPN連接，在最初連接時，ping一下所有VPN伺服器的IP位址，連接ping值最小的；待這個VPN斷線時，再次ping一下所有VPN伺服器的IP位址，連接ping值最小的；如此往復

**優點**：可以保障對外連接線路始終通暢，有時受gfw干擾某個VPN暫時無法連接時能夠自動切換到其他可連接的VPN，而且只在斷線時才更換VPN，相對來說較為穩定些；而且不用打開多個pptp進程，不存在pid辨別問題，相對來說實現起來也較容易；另外還可以使用graceMode

**缺點**：有些VPN伺服器會禁止WAN網路ping，而無法獲得ping值；由於只在VPN斷線後才再次測其他VPN速度並重新選擇、連接，因此不一定能保障時時得到最佳網速

### 需要解決的問題 ###
（發現新的問題時會更新）

  1. PPTP VPN必須手動連接及自動重連：因為dd-wrt的自動連接腳本/etc/config/pptpd\_client.vpn沒有這個功能
  1. 多個VPN配置檔案的管理問題：存放在jffs中還是nvram中？調配時使用循環還是數組？（不知道sh是否支持數組）
  1. pptp程式最多可以同時開多少個：已測試可以開同時開2個，但能否同時開更多呢？
  1. 多個pptp程式的pid辨別問題：用於確保每個VPN斷線後都能自動重連
  1. 是否需要重新編譯並調試pptp程式：有可能一些人遇到的dd-wrt上的PPTP VPN連接（相比電腦）不穩定、頻繁掉線是dd-wrt上的pptp二進制程式本身就存在問題，那麼可能要重新編譯並調試pptp程式了。

### 進度 ###

#### 已解決 ####
1.PPTP VPN的手動連接及自動重連問題：參見[ManualPPTPDev](ManualPPTPDev.md)

#### 解決中 ####
##### 多個VPN配置檔案的管理問題 #####
nvram容量有限，而我們可能需要存儲很多VPN訊息，因此用jffs存儲。

初步構想如下：

在/jffs/pptp下建立configs目錄，內放置多個目錄，分別對應各個vpn（如「vpn1」、「vpn2」⋯⋯，也可是其他有個性的名字），每個目錄下放置如下檔案：

options.vpn：VPN基本配置檔案

ipaddress.conf：伺服器IP位址

domainname.conf：以域名形式存儲VPN伺服器，使用時現解析出IP位址（腳本見下）

vpnsrvsub.conf：PPTP撥上之後的VPN子網路

vpnsrvsubmsk.conf：子網路遮罩

而VPN的名字列表則可以存儲在nvram中（如「nvram set pptp\_list='vpn1 vpn2 vpn3'」）

**從domainname.conf檔案的域名解析出IP位址並存入ipaddress.conf檔案的腳本**：

_（假定在配置檔案在/jffs/pptp/vpn1目錄下）_

```
rm -f /jffs/pptp/vpn1/ipaddress.conf
echo $(ping -w 1 -c 1 $(cat /jffs/pptp/vpn1/domainname.conf) | grep -Eo "\(([0-9.]+)" | cut -d\( -f 2) >> /jffs/pptp/vpn1/ipaddress.conf
if [ $(cat /jffs/pptp/vpn1/ipaddress.conf) == $(ping -w 1 -c 1 domainnotexists | grep -Eo "\(([0-9.]+)" | cut -d\( -f 2) ]; then
  rm -f /jffs/pptp/vpn1/ipaddress.conf
  echo "Can't resolve the ip address from domainname.conf"
else
  echo "Resolved the ip address from domainname.conf and saved it to ipaddress.conf"
fi
```

#### 尚未解決 ####
3.pptp程式最多可以同時開多少個

4.多個pptp程式的pid辨別問題

5.重新編譯並調試pptp程式問題
## Materials ##
以下列一些可能會用到的資料

### pptp程式 ###
pptp客戶端程式：/usr/sbin/pptp

dd-wrt自帶的pptp連接腳本：/etc/config/pptpd\_client.vpn（或/tmp/pptpd\_client/vpn）

### pid相關 ###
#### pidof命令 ####
用法：
```
pidof [-o omitpid] [-s] [-x script] program
```

**參數**：-o omitpid

在列出的進程PID中忽略omitpid，可以有多個。

**參數**：-s program

只列出一個。

**參數**：-x script

找出shell腳本script的進程PID。

#### ps命令 ####
列出當前所有運行進程及其PID

### /dev/null ###
丟棄輸出

### PPTP客戶端 ###
PPTP Client項目主頁（on `SourceForge`）：http://pptpclient.sourceforge.net/

原始碼：http://sourceforge.net/projects/pptpclient/files/

### 獲取ping值 ###
#### get time ####
命令：
```
echo $(ping -w 1 -c 1 <ipaddress_or_domain> | grep -Eo "time=([0-9.]+)" | cut -d= -f2)
```
例：
```
echo $(ping -w 1 -c 1 127.0.0.1 | grep -Eo "time=([0-9.]+)" | cut -d= -f2)
```

#### get ip ####
命令：
```
echo $(ping -w 1 -c 1 <domain_name> | grep -Eo "\(([0-9.]+)" | cut -d\( -f 2)
```
例：
```
echo $(ping -w 1 -c 1 www.google.com | grep -Eo "\(([0-9.]+)" | cut -d\( -f 2)
```