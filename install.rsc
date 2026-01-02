# RouterOSMax Professional Installer
/system script
:do { remove [find name~"rx-"] } on-error={};
:local baseUrl "https://raw.githubusercontent.com/dumkot/routerosmax/main/src";
:local scripts {"rx-config"; "rx-config-overlay"; "rx-functions"; "rx-dhcp-arp"; "rx-telegram-bot"; "rx-core"};

:foreach s in=$scripts do={
    :do {
        add name=$s source=([/tool fetch url="$baseUrl/$s.rsc" output=user as-value]->"data");
    } on-error={ /log error "Failed to fetch $s" }
}

/system scheduler
:do { remove [find name~"RX-"] } on-error={};
add name="RX-BOOT" on-event="/system script run rx-core" start-time=startup
add name="RX-TG-BOT" interval=30s on-event="/system script run rx-telegram-bot"
/system script run rx-core
