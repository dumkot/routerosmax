#-------------------------------------------------------------------------------
# File: rx-mod-wireless.rsc
# Description: Collect and notify new Wireless MACs (Legacy & WifiWave2 Support)
#-------------------------------------------------------------------------------
:global RxSendTG;
:global rxConfig;

:if ($rxConfig->"collectWireless" = true) do={
    # 1. Check Legacy Wireless
    :if ([:len [/interface find where type="wlan"]] > 0) do={
        :foreach i in=[/interface wireless registration-table find] do={
            :local mac [/interface wireless registration-table get $i mac-address];
            :local iface [/interface wireless registration-table get $i interface];
            :local sig [/interface wireless registration-table get $i signal-strength];
            # $RxSendTG message="\F0\9F\93\B6 <b>Legacy Wifi</b>%0AUser: $mac%0ASig: $sig";
        }
    }
    # 2. Check WifiWave2 (AX Devices)
    :do {
        :if ([:len [/interface/wifi/registration-table find]] > 0) do={
             :foreach x in=[/interface/wifi/registration-table find] do={
                :local mac [/interface/wifi/registration-table get $x mac-address];
                :local iface [/interface/wifi/registration-table get $x interface];
                :local sig [/interface/wifi/registration-table get $x signal-strength];
                # $RxSendTG message="\F0\9F\9A\80 <b>Wifi 6/AX</b>%0AUser: $mac%0ASig: $sig";
             }
        }
    } on-error={} 
}
