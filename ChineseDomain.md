## Introduction ##

這份說明關於使用Google DNS和Open DNS時，中文域名的解析可能遇到的問題。


## Details ##

~~經過測試，Google DNS和Open DNS均無法對中文域名進行解析，Google DNS會直接返回NXDOMAIN，而OpenDNS則會返回解析錯誤的頁面。~~

仔細研究後發現，Google DNS和Open DNS只是無法對「.公司」、「.网络」和「.政务」這三個中文域名後綴進行解析，實際上是因為這三個中文域名在國際上有一些爭議，而且由CNNIC控制，所以國外的DNS伺服器都無法解析。而國別的中文域名，如「.中国」、「.台灣」、「.香港」用Google DNS和Open DNS都能正常解析，中文+英文後綴的域名也能正常解析。另外由於「.公司」、「.网络」和「.政务」本身就是CNNIC控制的，根解析服務器就在中國，所以要是污染了用境外DNS也沒用（而且既然是CNNIC控制，它也就不用費那麼大勁去再用gfw污染，發現有不和諧網站直接就停止解析了，和cn域名一樣）。因此「所存在問題」也就都不存在了。第一行使「.中国」域名強制走國內DNS就可以註釋掉了，只保留下面三行就可以了（如果起到和cn域名後綴一樣的CDN加速效果第一行不註釋掉也行）。

### 解決方案 ###
目前只能使用支持解析中文域名的DNS伺服器來進行解析，比如北京聯通的DNS伺服器202.106.196.115，需要在DNSmasq中添加如下配置（此設置已被添加至cncdn.conf）：
```
#Chinese_domains
#server=/xn--fiqs8s/202.106.196.115
server=/xn--55qx5d/202.106.196.115
server=/xn--io0a7i/202.106.196.115
server=/xn--zfr164b/202.106.196.115
```
第一行對應「.中国」域名，第二行對應「.公司」域名，第三行對應「.网络」域名，第四行對應「.政务」域名。

### ~~所存在問題~~ ###
  * ~~由於用來解析中文域名的DNS伺服器位於中國，因此可能會有某個中文域名被DNS污染問題。目前尚未發現可以解析中文域名的境外DNS伺服器，如果有找到的朋友請在下面回復來回報給我。~~

  * ~~這樣只能對於中文後綴的域名進行解析，而對於使用中文+英文後綴的域名依舊無法解析（如中文.com），但中文.cn除外，因為在cncdn.conf設置了cn域名全部走國內DNS伺服器。DNSmasq似乎不支持正則表達式（用**xn--**似乎就可以匹配中文域名）~~