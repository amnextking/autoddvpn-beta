## Introduction ##

這份說明描述在dd-wrt、Tomato和openwrt中如何開啓optware支持，以及安裝一些常用的optware組件的配置方法。


## Details ##
### 掛載/opt分區 ###

### 安裝ipkg-opt ###
透過ssh或telnet登入路由器後，根據下面的每種路由器的相應命令操作：

**dd-wrt路由器**：
```
$ wget http://autoddvpn-beta.googlecode.com/svn/trunk/tools/optware/optware-install-ddwrt.sh -O - | tr -d '\r' > /tmp/optware-install.sh
$ sh /tmp/optware-install.sh
```

**Tomato路由器**：
```
$ cd /opt
$ wget http://autoddvpn-beta.googlecode.com/svn/trunk/tools/optware/optware-install-tomato.sh -O - | tr -d '\r' > optware-install.sh
$ sh optware-install.sh
```

**`OpenWrt`路由器**<sup>[8]</sup>：

編輯ipkg.conf：
```
$ vi /etc/ipkg.conf
```
加入「`src optware http://ipkg.nslu2-linux.org/feeds/optware/openwrt-ixp4xx/cross/unstable`」

之後：
```
$ ipkg update
$ ipkg install ipkg-opt
```

然後建議再將「`src optware http://ipkg.nslu2-linux.org/feeds/optware/openwrt-ixp4xx/cross/unstable`」從檔案/etc/ipkg.conf中移除，再添加到檔案/opt/bin/ipkg-opt中。

### 安裝常用的一些optware組件 ###

**`BusyBox`** ：
```
$ ipkg-opt install busybox
```
**Python 2.6**：
```
$ ipkg-opt install python26
$ ln -s /opt/bin/python2.6 /opt/bin/python
```
**OpenSSL** ：
```
$ ipkg-opt install openssl
$ ipkg-opt install py26-openssl
```
**SVN** ：
```
$ ipkg-opt install svn
```

**Python 2.6 setup tools** （可選，如需編譯Gevent則需安裝）<sup>[7]</sup>：
```
$ ipkg-opt install py26-setuptools
```

**編譯工具** （可選，如需編譯Gevent或其他程式則需安裝）<sup>[7]</sup>：
```
$ ipkg-opt install buildroot
$ ipkg-opt install make
```
_根據MaskV的部落格所述buildroot程式很大，下載和安裝的時間較長_

**Twisted** （可選，如需使用[pwx-dns-proxy](http://code.google.com/p/pwx-dns-proxy/)則需安裝）：
```
$ ipkg-opt install py26-twisted
```

**Lighttpd** （可選）：
```
$ ipkg-opt install lighttpd
```
安裝完成後需要對lighttpd.conf進行修改，否則lighttpd會無法啓動<sup>[5]</sup>：
```
$ /opt/etc/lighttpd/lighttpd.conf
```
找到「`# server.event-handler = "freebsd-kqueue" # needed on OS X`」修改為「`server.event-handler = "poll"`」

另外S80lighttpd最好也修改一下，將日誌弄到內存裡面，這樣有助於減少U盤/移動硬盤的讀寫，保護設備：
```
vi /opt/etc/init.d/S80lighttpd
```
找到「`    start)`」，在「`echo "Starting web server: $NAME"`」和「`$DAEMON $DAEMON_OPTS`」中間加入以下代碼：
```
        echo "Starting web server: $NAME"
        if [ ! -d /tmp/lighttpd ]; then
                mkdir /tmp/lighttpd
                mkdir /tmp/lighttpd/log
                rm -rf /opt/var/log/lighttpd
                ln -s /tmp/lighttpd/log /opt/var/log/lighttpd
        fi
```
之後重啓lighttpd即可：
```
$ /opt/etc/init.d/S80lighttpd restart
```

**PHP和GD庫** （可選，需要Lighttpd）：
```
$ ipkg-opt install php php-fcgi
$ ipkg-opt install php-gd
```

**SQLite** （可選）：
```
$ ipkg-opt install sqlite
```

## References ##
  1. [USB storage - DD-WRT Wiki](http://www.dd-wrt.com/wiki/index.php/USB_storage)
  1. [Optware - DD-WRT Wiki](http://www.dd-wrt.com/wiki/index.php/Optware)
  1. [Index of /feeds/optware/ddwrt/cross/stable/](http://ipkg.nslu2-linux.org/feeds/optware/ddwrt/cross/stable/)
  1. [DD-WRT掛U盤，裝lighttpd+php+SQLite建路由站 - DD-WRT專版 - 恩山WIFI論壇](http://www.right.com.cn/forum/thread-42186-1-1.html)
  1. [Fix DD-WRT Lighttpd error "(server.c.1105) fdevent\_init failed" on Asus WL-500 | Matt Gibson](http://www.mattgibson.ca/2009/11/05/fix-dd-wrt-lighttpd-error-server-c-1105-fdevent_init-failed-on-asus-wl-500/)
  1. [DD Wrt 路由器級VPN翻牆方案 « 小野大神 Blog](https://oogami.name/941/)
  1. [Tomato中編譯安裝Gevent | MaskV](https://maskv.com/technology/192.html)
  1. [NSLU2-Linux - OpenWrt / HomePage browse](http://www.nslu2-linux.org/wiki/OpenWrt/HomePage)