function Add-MyNewVpn() 
{
    # 名称
    $VpnName="VPNName"
    # 连接地址
    $VpnAddr="vpnaddr.local"
    # 预共享密钥
    $L2tpPsk="password"
    # DNS 服务器
    $Dns="192.168.1.1"
    # DNS 后缀匹配此后缀的走指定的 DNS 服务器解析
    $DnsSuffix="internal.local"
    # 连接时添加到路由表，访问这些地址时走vpn
    $InternalIpAddress=@('10.10.10.0/24')
    
    $VpnOpts=@{
        Name = $VpnName
        TunnelType = "L2TP"
        ServerAddress = $VpnAddr
        EncryptionLevel = "Required"
        L2TP = $L2tpPsk
        SplitTunneling = $true
        RememberCredential = $true
        Force = $true
    }

    if ($VpnConn = Get-VpnConnection -Name $VpnName -ErrorAction SilentlyContinue)
    {  
        if ('Disconnected' -ne $VpnConn.ConnectionStatus) {
            Write-Error "VPN 配置 '$VpnName' 正在使用，请断开后再试"
            return;
        }

        $Selection = Read-Host "VPN 配置 '$VpnName' 已存在, 尝试删除旧的配置? (Y/N)"

        If ($Selection -eq "N")
        {
            Write-Output "取消操作"
            return
        }

        Remove-VpnConnection -Name $VpnName -Force -ErrorAction Stop
    }

    Add-VpnConnection @VpnOpts -ErrorAction Stop
    Add-VpnConnectionTriggerTrustedNetwork -ConnectionName $VpnName -DnsSuffix $DnsSuffix -Force
    Add-VpnConnectionTriggerDnsConfiguration -ConnectionName $VpnName -DnsSuffix $DnsSuffix -DnsIPAddress $Dns -Force

    foreach ($ipAddr in $InternalIpAddress) 
    {
        Add-VpnConnectionRoute -ConnectionName $VpnName -DestinationPrefix $ipAddr -ErrorAction Stop
    }

    REG ADD HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 0x2 /f
    REG ADD HKLM\SYSTEM\CurrentControlSet\Services\RasMan\Parameters /v ProhibitIpSec /t REG_DWORD /d 0x0 /f

    Write-Output "VPN 配置 '$VpnName' 已添加"
}

function Test-Administrator  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

if (-Not (Test-Administrator))
{
    Write-Output "此脚本必须以管理员权限执行，继续以管理员权限打开新窗口";
    pause
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit 1;
}
else 
{
    Add-MyNewVpn
    pause
}