#-------------------------------------------------------------------------------
# File: rx-security.rsc
# Description: Firewall Hardening & Brute-force Protection
#-------------------------------------------------------------------------------
:global RxLog;
:do {
    /ip firewall filter;
    :if ([:len [find comment="RX-SEC-TRUSTED"]] = 0) do={
        add chain=input action=accept connection-state=established,related comment="RX-SEC-TRUSTED" place-before=0
    }
    :if ([:len [find comment="RX-SEC-DROP-INVALID"]] = 0) do={
        add chain=input action=drop connection-state=invalid comment="RX-SEC-DROP-INVALID" place-before=1
    }
    $RxLog type="security" message="Firewall policies updated.";
} on-error={ :log error "Security module error." }
