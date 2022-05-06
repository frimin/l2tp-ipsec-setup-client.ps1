# l2tp-ipsec-setup-client.ps1

快速设置 Win10 下 L2TP/ipsec 客户端配置示例，右键通过 powershell 执行。

首次配置修改注册表后需要重启系统才能连接在路由器后面的L2TP服务器，详细见 [Windows 错误 809](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients-zh.md#windows-%E9%94%99%E8%AF%AF-809) / [配置 NAT-T 设备后面的 L2TP/IPsec 服务器](https://docs.microsoft.com/zh-cn/troubleshoot/windows-server/networking/configure-l2tp-ipsec-server-behind-nat-t-device)