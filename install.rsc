# RouterOSMax Master Installer (Auto-Wrap Logic)
/system script :do { remove [find name~"rx-"] } on-error={};
:local baseUrl "https://raw.githubusercontent.com/dumkot/routerosmax/main/src";
:local scripts {"rx-config"; "rx-config-overlay"; "rx-functions"; "rx-mod-wireless"; "rx-mod-netwatch"; "rx-system"; "rx-telegram-bot"; "rx-core"};

:foreach s in=$scripts do={
    :do {
        # 1. Download file mentah ke disk
        /tool fetch url="$baseUrl/$s.rsc" dst-path=("$s" . ".txt") mode=https;
        :delay 1s;
        
        # 2. Baca isi file dan bungkus ke dalam script system secara otomatis
        :local fileContent [/file get [find name=("$s" . ".txt")] contents];
        /system script add name=$s source=$fileContent;
        
        # 3. Hapus file sampah
        /file remove [find name=("$s" . ".txt")];
        :put "Successfully installed: $s";
    } on-error={ :put "Failed to install $s - file might be too large or network error" }
}

/system scheduler :do { remove [find name~"RX-"] } on-error={};
/system scheduler add name="RX-BOOT" on-event="/system script run rx-core" start-time=startup;
/system scheduler add name="RX-BOT" interval=30s on-event="/system script run rx-telegram-bot";

:delay 1s;
/system script run rx-core;
:put "INSTALLATION DONE.";