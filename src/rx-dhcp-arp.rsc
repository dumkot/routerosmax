#-------------------------------------------------------------------------------
# File: rx-dhcp-arp.rsc
# Description: DHCP Leases & ARP Monitoring Module
#-------------------------------------------------------------------------------
:global RxLog;
:global RxSendTG;

:local GetDevices do={
    :local Out "<b>\F0\9F\93\B1 Connected Devices</b>%0A";
    :local Count 0;
    /ip dhcp-server lease;
    :foreach i in=[find where status=bound] do={
        :set Count ($Count + 1);
        :local host [get $i host-name];
        :local addr [get $i address];
        :set Out "$Out$Count. <code>$addr</code> - $host%0A";
    }
    :return $Out;
}

:global RxCmdDevices do={
    :global RxSendTG;
    :local List [$GetDevices];
    [$RxSendTG] message=$List;
}
