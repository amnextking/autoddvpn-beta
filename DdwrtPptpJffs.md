## Introduction ##

這份說明描述在dd-wrt路由中，使用PPTP VPN，在jffs模式下的配置方法。

_**注意**：此說明默認JFFS已經開啓，如果您未開啓JFFS，請參考[autoddvpn中關於如何打開jffs支持的說明](http://code.google.com/p/autoddvpn/wiki/jffs#如何打開jffs支持)；如果您的DD-WRT路由器無法開啓或不支持JFFS，請參考[這份說明](DdwrtPptpNojffs.md)_


## Details ##
### 安裝腳本 ###
透過ssh或telnet登入路由器，執行如下指令：
```
$ cd /jffs
$ wget http://autoddvpn-beta.googlecode.com/svn/trunk/cnips.lst
$ mkdir /jffs/pptp
$ cd /jffs/pptp
$ wget http://autoddvpn-beta.googlecode.com/svn/trunk/dd-wrt/pptp/run.sh
$ for i in vpnup vpndown checkvpn; do wget http://autoddvpn-beta.googlecode.com/svn/trunk/dd-wrt/$i.sh;done;
$ chmod a+x *.sh
```

### 設置 ###
  1. 在路由器管理web頁面的Service/VPN設置好PPTP客戶端配置，可參考[autoddvpn的相關說明](http://code.google.com/p/autoddvpn/wiki/HOWTO#設置PPTP_client)
  1. 在Setup/Basic Setup設置DNS為OpenDNS或Goole DNS來防止DNS劫持，也可參考[autoddvpn的相關說明](http://code.google.com/p/autoddvpn/wiki/HOWTO#設置DNS)
  1. 設置開機啓動：
```
$ nvram set rc_startup='/jffs/pptp/run.sh'
$ nvram commit
# 或者執行通過下面的命令用Script Execution來實現自啓動也可以：
$ mkdir /jffs/etc
$ /jffs/etc/config
$ mv /jffs/pptp/run.sh /jffs/etc/config/autoddvpn.startup
```
  1. 重啓路由：
```
$ reboot
```

**It's done, enjoy!**

### 檢視 ###
正常情況下路由器啓動之後2-3分鐘左右路由器就會執行完相應腳本，實現IP位址國內外分流。您可訪問[formyip.com](http://formyip.com)來查看是否已經是國外IP位址，再訪問[www.ip138.com](http://www.ip138.com)查看是不是國內IP位址，如果是的話，說明已經成功了。

您亦可再次透過ssh或telnet登入路由器，可以用「tail -f /tmp/autoddvpn.log」指令來檢視日誌，透過日誌可以獲得VPN運行狀況等訊息，如果出現VPN無法連接等錯誤亦可透過日誌來進行排查。

在檢視時，「route」指令可以查看路由表，來顯示默認網關是否為VPN網關，以及國內IP分流的路由表是否已經添加；由於路由表非常多，亦可使用「route | tail -n 10」指令來只查看最後10條紀錄。

有時雖然VPN確實已經連接上了，formyip.com亦能看到國外IP，然而卻依舊無法訪問Facebook、Youtube等牆外網站，這可能是由於您的DNS緩存受到了污染，您可在計算機上透過如下指令來清除DNS緩存：

**Windows作業系統**（cmd中）：
```
ipconfig /flushdns
```
**Mac OS X 10.6及以下作業系統**（terminal中）：
```
$ dscacheutil -flushcache
```
**Mac OS X 10.7及以上作業系統**（terminal中）：
```
$ sudo killall -HUP mDNSResponder
```
**Linux作業系統**（terminal中）：
```
$ sudo /etc/init.d/nscd restart
```
或
```
$ rndc flush
```
或
```
$ /etc/init.d/dnsmasq restart
```
或
```
$ ./xrgsu -d
```

_如果您有興趣想要詳細了解GFW的DNS緩存污染，可以看看[這份檔案](GfwDnsPollution.md)_

如果您遇到問題但無法判定確定哪里出現了問題，可以[在此提交issue](http://code.google.com/p/autoddvpn-beta/issues/entry)並附上相應的日誌和一些您認為可能會有用的額外訊息。

### 進階 ###
由於設置了Open DNS或Google DNS，雖然避免了DNS劫持，但是可能會影響國內一些網站的CDN加速，可以通過設置DNSmasq來使國內一些常用網站的域名解析走本地ISP DNS，還可解決[一些中文域名無法解析的問題](ChineseDomain.md)，具體請參考[這篇說明](DNSmasq.md)。

此外，您還可以選擇手動連接PPTP VPN，這樣可以解決某些dd-wrt版本的默認PPTP配置檔案存在問題，以及加入一些進階參數等。這個功能正在開發中，如有興趣請參看[此檔案](ManualPPTPDev.md)。

**`GraceMode`**（實驗性）：

對於一些VPN非常不穩定，而且主要訪問墻內網站，牆外基本上只訪問Twitter、Facebook、Youtube等網站，對國內CDN、P2P依賴較高的用戶，我修改了vpnup.sh的代碼，實驗性支持`GraceMode`，目前這一功能正在進一步測試中。

首先下載GFW IP列表：
```
$ cd /jffs
$ wget http://autoddvpn-beta.googlecode.com/svn/trunk/gfwips.lst
```
之後設置nvram的gracevpn\_enable值為1：
```
$ nvram set gracevpn_enable=1
```
之後重啓路由即可

更新gfwips.lst列表：

由於gfwips.lst這個IP列表相比中國大陸IP列表cnips.lst變化頻率很高，因此有時在訪問某個國外網站無法訪問時可能需要手動更新gfwips.lst，首先需要下載至裝有python的環境下（如果路由器裝有python可直接下載至路由器中）：
```
wget http://code.google.com/p/autoddvpn-beta/source/browse/trunk/tools/gengfwipv4lst.py
```
（在圖形化的作業系統中，如Windows、Mac OS X，也可以直接用瀏覽器訪問上面的地址後直接另存為）

之後執行：
```
$ python gengfwipv4lst.py
```
注：Mac OS X系統的python中並未集成上述腳本中需要用到的dns.resolver模塊，需要手動安裝，不然會出錯。安裝方法：先下載安裝[ActivePython](http://www.activestate.com/activepython/downloads#)，之後在終端（Terminal）運行命令「`pypm install dnspython`」即可。

## References ##
  1. [HOWTO - autoddvpn - DD-WRT自動翻牆解決方案 - Google Project Hosting](http://code.google.com/p/autoddvpn/wiki/HOWTO)
  1. [jffs - autoddvpn - DD-WRT自動翻牆解決方案 - Google Project Hosting](http://code.google.com/p/autoddvpn/wiki/jffs)