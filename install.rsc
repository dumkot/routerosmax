# RouterOSMax Master Installer
/system script
:do { remove [find name~"rx-"] } on-error={};
:local baseUrl "https://raw.githubusercontent.com/dumkot/routerosmax/main/src";
:local scripts {"rx-config"; "rx-config-overlay"; "rx-functions"; "rx-mod-wireless"; "rx-mod-netwatch"; "rx-system"; "rx-telegram-bot"; "rx-core"};

:foreach s in=$scripts do={
    :do {
        add name=$s source=([/tool fetch url="$baseUrl/$s.rsc" output=user as-value]->"data");
    } on-error={ /log warning "Could not fetch $s. Check repo URL." }
}

/system scheduler
:do { remove [find name~"RX-"] } on-error={};
add name="RX-BOOT" on-event="/system script run rx-core" start-time=startup policy=read,write,policy,test,sensitive
add name="RX-BOT" interval=25s on-event="/system script run rx-telegram-bot" policy=read,write,policy,test,sensitive

/system script run rx-core
