# RouterOSMax Master Installer (FIXED TOTAL)
/system script
:do { remove [find name~"rx-"] } on-error={};

:local baseUrl "https://raw.githubusercontent.com/dumkot/routerosmax/main/src";
:local scripts {"rx-config"; "rx-config-overlay"; "rx-functions"; "rx-mod-wireless"; "rx-mod-netwatch"; "rx-system"; "rx-telegram-bot"; "rx-core"};

:foreach s in=$scripts do={
    :do {
        # Download filenya dulu ke disk (jangan simpan di memori/variabel)
        /tool fetch url="$baseUrl/$s.rsc" dst-path="$s.rsc" mode=https;
        :delay 1s;
        
        # Import filenya (MikroTik bakal baca file ini secara native)
        # Syarat: isi file src/$s.rsc di GitHub Anda HARUS ada perintah /system script add
        /import "$s.rsc";
        
        # Hapus file mentahnya setelah jadi script
        /file remove "$s.rsc";
        :put "Berhasil pasang modul: $s";
    } on-error={ :put "Gagal tarik modul: $s" }
}

/system scheduler
:do { remove [find name~"RX-"] } on-error={};
add name="RX-BOOT" on-event="/system script run rx-core" start-time=startup policy=read,write,policy,test,sensitive
add name="RX-BOT" interval=30s on-event="/system script run rx-telegram-bot" policy=read,write,policy,test,sensitive

:delay 1s;
/system script run rx-core;
:put "INSTALL SELESAI. SILAKAN CEK WINBOX -> SYSTEM -> SCRIPTS.";