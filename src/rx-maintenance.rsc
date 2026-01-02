#-------------------------------------------------------------------------------
# File: rx-maintenance.rsc
# Description: Resource Optimization & Cache Cleanup
#-------------------------------------------------------------------------------
:global RxLog;
:do {
    /ip dns cache flush;
    /ip arp remove [find dynamic=yes];
    $RxLog type="maintenance" message="DNS/ARP Cache flushed.";
} on-error={ :log error "Maintenance module error." }
