這個項目源於路由器自動智能翻牆解決方案[Autoddvpn](http://code.google.com/p/autoddvpn/)。

個人在使用Autoddvpn的腳本時發現存在一些不足，比如每次執行vpnup、vpndown都會增刪路由表，對於不穩定的VPN來說很浪費時間，實際路由表只需執行1次就行了；還有就是final check處有個死循環，有時在vpnup執行過程中VPN斷線就會卡在那裡，導致vpndown也無法執行；以及沒有VPN檢查程式，有時VPN斷線路由器無法自動重連的時候不能強制重連等等。所以我對autoddvpn的代碼進行了一些優化和改良，最開始在Autoddvpn項目上提交了一些修改後的patch，但是被無視，也許是就原來的腳本改動太大，或者原項目的管理已放棄那個項目。於是索性自己新建了一個project，來發佈我的改良版本。

因為這個程式是在Autoddvpn上改良、完善而成，同時也為了表達對Autoddvpn原作者啟發的感謝，因此將此項目命名為Autoddvpn-beta。

另外，還計畫在原先Autoddvpn的基礎上除了改善這些不足之外，再增加一些新的功能，比如手動連接PPTP（這樣可以自定義許多參數，同時又可以解決某些dd-wrt中自帶的PPTP配置檔案option.vpn存在bug等問題），以及多個VPN隨機連接（或根據ping值取最小的連接）或同時在後台連接多個VPN後根據時時速度自動切換等功能，以及研究對P2P的支持。

[Autoddvpn項目的wiki上說](http://code.google.com/p/autoddvpn/wiki/AboutP2P)「Autoddvpn的目標不是發揮dd-wrt的功能極致，而是讓家家戶戶都可以直接裝上就可以穩定而且長時間翻牆，就像裝衛星電視一樣容易」，而我們則是儘可能地發揮dd-wrt、Tomato和OpenWrt的功能極致，讓路由器有更多的方式、更多的功能智能翻牆，雖然這樣可能設置上只針對一些專業用戶和愛折騰的用戶，但是我們仍然有Optware翻牆U盤計畫（見下面「一些計畫中的功能」），將來把我們開發好、設置好的程式和腳本製成opt包，一般的用戶只需刷入U盤即可使用，也能實現「像裝衛星電視一樣容易」。

還有就是Autoddvpn只支持dd-wrt路由器，對tomato兼容性不好，對OpenWRT完全不支持，因此我的項目計畫支持dd-wrt、tomato和OpenWRT三種系統的路由，並為每種路由分別寫腳本。

另外，我還會在本項目的wiki發表一些關於翻牆和GFW的研究。
<br />

This project is originated from the the automatic smart bypassing the GFW solution based on routers — [Autoddvpn](http://code.google.com/p/autoddvpn/).

There are some disadvantages on the original Autoddvpn project. For example, it will add and delete routing tables every time executing vpnup & vpndown script. It is wasting time especially for unstable VPN service. Actually, the routing table script just need to be executed once. Besides that, there is also an infinite loop in the final check part of the scrip in Autoddvpn. It will cause that program stuck there if the VPN disconnect when the vpnup script is executing. There is also no program checking VPN connection, sometimes the router cannot re-establish the VPN connection after disconnected. In this case, I modified and optimised some codes in the original Austoddvpn project, and submitted as patches. However, they are ignored by the administrator of Autoddvpn project. Maybe my modification are too much, or maybe the administrator did not review that project anymore. Therefore, I decide to create a brand new project to publish my optimised version of Autoddvpn.

Because my project is a optimised version based Autoddvpn project, and also for the thankfulness for the illumination from Autoddvpn project, I named my project as Autoddvpn-beta.

Besides optimising, I also plan to add some new features in my project. For example, connect to PPTP VPN manually so that some custom parameters for the connection will be able to be defined, and the bug in option.vpn configuration file in some dd-wrt routers will be fixed too. Besides that, it will allow to connect to multiple VPNs, and automatically switched to the fastest and stablest one. Also I will study on the support for P2P.

[On the wiki of Autoddvpn](http://code.google.com/p/autoddvpn/wiki/AboutP2P), it is said that the goal of Autoddvpn was not extremize the functions of dd-wrt, but let all users would be able to easily use it and bypass the GFW stably, like using satellite dish to watch TV program. However, the goal of our project is trying to extremize the functions of dd-wrt, Tomato router and OpenWrt to let routers have more functions and more methods to bypass the GFW. Although it may limit the users of our project to only some professional users, we still have some plans to make it easier for configuration, such as making our configured program and scripts into package, and let it will be easier to flash into flash disks and attached to routers. That will be as easy as using satellite dish.

Besides that, the Autoddvpn was just face to dd-wrt router, and it works not too good with Tomato router, and completely not support to OpenWRT. Therefore, my project also plan to support all dd-wrt, Tomato router and OpenWRT, and I will write scripts for each router.

In addition, I will also post some researches about bypassing GFW and the methodology of GFW on the project wiki.
<br />

<font size='5'><b>現在，請根據您的路由類型選擇：</b></font>

  * <font size='3'><a href='DDWRT.md'>DD-WRT</a></font>

  * <font size='3'>Tomato (coming soon)</font>

  * <font size='3'>OpenWRT (coming soon)</font>

## 一些開發中的功能 ##
  1. [手動連接PPTP VPN](ManualPPTPDev.md)
  1. [L2TP VPN支持](L2TPDev.md)
## 一些計劃中的功能 ##
  1. [多個PPTP VPN連接](MutiPPTP.md)
  1. SSTP和IPsec協議的支持：與L2TP不同的是，dd-wrt本身似乎並不帶有SSTP客戶端程式~~和IPsec客戶端程式~~，因此可能要通過jffs或optware手動安裝相應的客戶端（研究發現dd-wrt帶有vpnc程式可用於IPsec連接）
  1. Optware翻牆U盤：許多計劃中的功能即使按照我詳細的教程操作依然配置起來很麻煩，因此想到將翻牆工具集成到[Optware](Optware.md)的U盤中，打包成tar文件，再配合上一鍵設置腳本，使用者只需下載包後刷入U盤中，並將U盤插到帶USB口的路由上，再經過非常簡單的幾步設置，就能實現智能翻牆，真正的一勞永逸。

## 一些關於翻牆的研究 ##
  1. [GFW的DNS污染問題](GfwDnsPollution.md)