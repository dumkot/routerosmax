# RouterOSMax Master Installer - FIXED LOGIC
/system script :do { remove [find name~"rx-"] } on-error={};

:local baseUrl "https://raw.githubusercontent.com/dumkot/routerosmax/main/src";
:local scripts {"rx-config"; "rx-config-overlay"; "rx-functions"; "rx-mod-wireless"; "rx-mod-netwatch"; "rx-system"; "rx-telegram-bot"; "rx-core"};

:foreach s in=$scripts do={
    :do {
        # 1. Download sebagai file fisik .rsc
        /tool fetch url="$baseUrl/$s.rsc" dst-path=("$s" . ".rsc") mode=https;
        :delay 1s;
        
        # 2. Hapus script dengan nama yang sama agar tidak bentrok
        /system script remove [find name=$s];
        
        # 3. BUNGKUS file mentah menjadi script system
        # Ini teknik eworm: buat script kosong dulu, lalu isi source-nya dari file
        /system script add name=$s;
        /system script set $s source=[/file get ("$s" . ".rsc") contents];
        
        # 4. Hapus file sampah
        /file remove ("$s" . ".rsc");
        :put "Berhasil pasang: $s";
    } on-error={ :put "Gagal pasang modul: $s" }
}

/system scheduler :do { remove [find name~"RX-"] } on-error={};
/system scheduler add name="RX-BOOT" on-event="/system script run rx-core" start-time=startup;
/system scheduler add name="RX-BOT" interval=30s on-event="/system script run rx-telegram-bot" policy=read,write,test,policy,sensitive,reboot;

:put "INSTALL SELESAI.";
