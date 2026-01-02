#-------------------------------------------------------------------------------
# File: rx-core.rsc
# Description: Orchestrates all modules
#-------------------------------------------------------------------------------
:do {
    /system script run rx-config;
    /system script run rx-config-overlay;
    /system script run rx-functions;
    /system script run rx-mod-wireless;
    /system script run rx-mod-netwatch;
    /system script run rx-system;
    /log info "[RX-MAX] Full Enterprise Stack Loaded."
} on-error={ /log error "[RX-MAX] Boot failure." }
