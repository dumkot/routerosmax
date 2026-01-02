#-------------------------------------------------------------------------------
# File: rx-core.rsc
# Description: System Loader
#-------------------------------------------------------------------------------
:do {
    /system script run rx-config;
    /system script run rx-config-overlay;
    /system script run rx-functions;
    /system script run rx-dhcp-arp;
    /log info "[RX-MAX] Core components initialized."
} on-error={ /log error "[RX-MAX] CRITICAL: Load failed." }
