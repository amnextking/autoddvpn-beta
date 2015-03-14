# Developing #
<font size='3'><b>注意</b>：這是一份開發中的檔案，描述一個開發中的功能，而非正式的HOWTO檔案，僅供開發者調試用。檔案中可能包含一些調試信息和專業性內容，檔案中提到的程式和腳本也可能仍不完善。開發完成後會發佈正式的HOWTO檔案。</font>
<br /><br />

## Introduction ##

這份說明描述在dd-wrt路由中連接L2TP VPN


## Details ##

### 安裝腳本 ###
登入路由器，並執行以下命令：
```
$ mkdir /jffs/l2tp
$ cd /jffs/l2tp
$ wget http://autoddvpn-beta.googlecode.com/svn/trunk/dev/l2tp/xl2tpd.conf
$ mkdir /jffs/ppp
$ cd /jffs/ppp
$ wget http://autoddvpn-beta.googlecode.com/svn/trunk/dev/l2tp/options.l2tp
```

### 修改 ###
修改xl2tpd.conf檔案：
```
$ vi /jffs/l2tp/xl2tpd.conf
```
將「`<server_ip_address>`」修改為VPN伺服器IP位址；「`<your_vpn_username>`」修改為您的VPN用戶名
<br />

修改options.l2tp檔案：
```
$ vi /jffs/ppp/options.l2tp
```
將「`<your_vpn_username>`」修改為您的VPN用戶名；「`<your_vpn_password>`」修改為您的VPN密碼

### 連接 ###
**啓動xl2tpd程式**：
```
$ mkdir /tmp/var/run/xl2tpd
$ xl2tpd -c /jffs/l2tp/xl2tpd.conf
```

**連接VPN伺服器**：
```
$ echo 'c vpn' > /tmp/var/run/xl2tpd/l2tp-control
```

**中斷連接**：
```
$ echo 'd vpn' > /tmp/var/run/xl2tpd/l2tp-control
```

## References ##
  1. [用xl2tpd建立L2TP协议的VPN连接&Ubuntu上图形化的L2TP VPN连接工具 - iGFW](http://igfw.net/archives/4292)
  1. [L2TP setup howto on Debian/Ubuntu - iGFW](http://igfw.net/archives/4287)
  1. [linux l2tp客户端简单使用 --- xl2tpd - 花甜的工作笔记](http://www.cnblogs.com/hbycool/articles/2616554.html)
  1. [配置Linux下的l2tp客户端 - SEU\_EXtreme!](http://blog.donews.com/extreme001/archive/2006/03/19/776170.aspx)
  1. [xl2tpd.c in src/router/xl2tpd@14896 – DD-WRT](http://svn.dd-wrt.com/browser/src/router/xl2tpd/xl2tpd.c?rev=14896)