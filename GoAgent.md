## Introduction ##

這份說明描述在dd-wrt、Tomato、Openwrt路由器中配置`GoAgent`實現翻牆

## Details ##

這份文檔以`GoAgent`客戶端版本2.0.14為例子，測試發現該版本運行良好，暫未測試高版本的運行狀況，該版本的`GoAgent`可在[Downloads](http://code.google.com/p/autoddvpn-beta/downloads/list)中下載。

這個功能需要開啓Optware，並安裝Python 2.6和OpenSSL，具體可參見[這份說明](Optware.md)。

在按照此說明配置路由器客戶端之前，應確保在GAE上已經有配置好的伺服器端，GAE伺服器端的配置方法可參考[官方說明](http://code.google.com/p/goagent/wiki/InstallGuide)。另請注意教程中的2.0.14版本的客戶端未必能夠向上兼容最新版本的官方伺服器端，所以我準備了一個已經確認可以兼容這個版本的2.0.12版本的伺服器端，可以在[這裡](http://code.google.com/p/autoddvpn-beta/downloads/detail?name=goagent-server-2.0.12.tar.gz)下載。

如果使用google\_cn profile配置`GoAgent`客戶端的話，此方法和VPN並不衝突，可同時使用，`GoAgent`將作為一個備選方案，在VPN連不上時或需要高帶寬（如觀看Youtube視頻）時使用。

**需要注意的是**：`GoAgent`安全性很低，而且在路由器中運行佔用的資源也較大，因此極其**不推薦**當作**首選**的翻牆方式！

### 安裝 ###
透過ssh或telnet登入路由器後，執行如下指令：
```
$ cd /opt/etc
$ wget http://autoddvpn-beta.googlecode.com/files/goagent-client-2.0.14.tar.gz
$ tar -zcvf goagent-client-2.0.14.tar.gz
# 注：測試發現在某些版本的dd-wrt中系統自帶的tar程式存在問題，請按照Optware中的說明安裝busybox後使用/opt/bin/tar命令代替
$ cd /opt/etc/goagent
$ chmod +x *
```

### 配置 ###
修改proxy.ini：
```
$ vi /opt/etc/goagent/proxy.ini
```
在「appid」後填入GAE上的app id，多個app用管線（「 | 」）隔開；password後填入密碼；「`[google_cn]`」部分下面的hosts後填入找到的在你所在地區仍能訪問的谷歌北京數據中心的IP位址，可以在[這裡](http://smarthosts.googlecode.com/svn/trunk/hosts)查找，「`203.208.*.*`」的都是，填寫之前先訪問一下，如果能打開google主頁說明這個IP沒有被你所在地區封鎖，將所有能訪問的IP位址都填寫上，用管線（「 | 」）隔開（相同的IP位址只填寫一次即可）；如果所有谷歌北京數據中心的IP位址都無法訪問，請將上面的profile後面的google\_cn改為google\_hk

### 運行與檢視 ###
輸入命令：
```
$ nohup python /opt/etc/goagent/proxy.py > /tmp/goagent.log &
```
之後`GoAgent`便會在系統後台運行，在路由下的電腦上將瀏覽器代理改為「路由器IP位址:8087」即可翻牆，可配合GFWlist進行智能翻牆。

透過如下命令可對日誌進行檢視：
```
$ tail -f /tmp/goagent.log
```

如需結束`GoAgent`運行，可通過命令「`jobs`」查找出其任務序號，就是「[.md](.md)」中的數字，通常為「1」，通過命令「`fg %n`」命令（n即為前面找到的任務序號，如果是1的話命令就是「`fg %1`」）將其調回前台後，通過control+c將其結束。

### 進階 ###
**設置swap虛擬內存** ：

經過測試發現，`GoAgent`非常吃路由內存，運行時很容易導致路由器死機，因此建議最好設置一些swap虛擬內存，執行如下命令（需安裝busybox，可參看[這份說明](Optware.md)）：
```
dd if=/dev/zero of=/opt/swapfile bs=1024 count=131072
/opt/bin/busybox mkswap /opt/swapfile
/opt/bin/busybox swapon /opt/swapfile
```
_註：其中131072為虛擬內存的大小，單位是KB，必須為1024的整數倍，131072就是128MB\*1024，請根據路由器實際情況設置，一般為路由器實際內存的2倍。_

之後設置開機自動加載虛擬內存：

將「`/opt/bin/busybox swapon /opt/swapfile`」保存在開機命令中即可

**添加更多證書** ：

經過測試發現，在dd-wrt上運行`GoAgent`透過SSL方式訪問網站時，如果cert目錄內沒有相應的證書，新生成證書很慢，而且容易出錯，所以我在`GoAgent`的下載包中集成了一些證書，但可能仍然也無法保障涵蓋了所有經常訪問的網站的證書，因此您可以先將`GoAgent`客戶端在電腦上運行並訪問一些您經常需要瀏覽的SSL方式的網站，之後將certs目錄下生成的證書上傳至dd-wrt上的/opt/etc/goagent/certs目錄即可。

**編譯Gevent 0.13.8**<sup>[3]</sup>：

雖然這個版本的GoAgent已經能夠兼容無Gevent的環境，但是由於路由器上沒有Gevent，可能對運行效率有一些影響，可以自行在路由器上編譯Gevent，具體步驟如下：

首先確保optware安裝了busybox、Python 2.6 setup tools和編譯工具，可參看[這份說明](Optware.md)。

之後下載gevent 0.13.8並解包：
```
$ cd /opt/etc
$ wget http://autoddvpn-beta.googlecode.com/files/gevent-0.13.8.tar.gz
$ tar -zxvf gevent-0.13.8.tar.gz
# 還是tar如果存在問題請用/opt/bin/tar
```
然後下載libevent依賴：
```
$ cd /opt/etc/gevent-0.13.8
$ python fetch_libevent.py
```
這時如果路由器沒有透過VPN翻牆的話，libevent可能會無法下載，請修改fetch\_libevent.py：
```
$ vi /opt/etc/gevent-0.13.8/fetch_libevent.py
```
找到「http://github.com/downloads/libevent/libevent/libevent-1.4.14b-stable.tar.gz」，改為「http://autoddvpn-beta.googlecode.com/files/libevent-1.4.14b-stable.tar.gz」或「http://maskv.com/wp-content/uploads/2012/11/libevent-1.4.14b-stable.tar.gz」均可

libevent依賴下載完之後，就可以開始編譯了：
```
$ cd /opt/etc/gevent-0.13.8
$ python setup.py build && python setup.py install
```
編譯成功後就OK了

**在Python 2.7+gevent1.0rc2環境下運行最新版`GoAgent`** ：

最新版本的`GoAgent`增強了翻牆能力，需要在Python 2.7+gevent1.0rc2的環境下才能更好地運行，python2.7+gevent1.0rc2環境的搭建請參看[這篇部落格](https://maskv.com/technology/272.html)，由於步驟十分繁瑣，而且那篇部落格寫得也比較詳細，因此這里就不再敘述。

**透過iptables實現智能翻牆，無需手動設置代理** ：

還在進一步研究中

## References ##
  1. [Dualwan路由器使用goagent高速自動爬長城簡明教程 - 交流討論區 - Tomato DualWAN 論壇](http://bbs.dualwan.cn/viewthread.php?tid=229261)
  1. [在 3.5MB 超小空閒空間的路由器上部署 Python + GoAgent（以Tomato DualWAN WR500V 為例） - Yonsm.NET](http://www.yonsm.net/post/645)
  1. [Tomato中編譯安裝Gevent | MaskV](https://maskv.com/technology/192.html)