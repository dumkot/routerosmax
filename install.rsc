# RouterOSMax Master Installer (FIXED)
/system script
:do { remove [find name~"rx-"] } on-error={};

:local baseUrl "https://raw.githubusercontent.com/dumkot/routerosmax/main/src";
:local scripts {"rx-config"; "rx-config-overlay"; "rx-functions"; "rx-mod-wireless"; "rx-mod-netwatch"; "rx-system"; "rx-telegram-bot"; "rx-core"};

:foreach s in=$scripts do={
    :do {
        /tool fetch url="$baseUrl/$s.rsc" dst-path="$s.rsc" mode=https;
        :delay 1s;
        # Menghapus script lama jika ada sebelum import agar tidak duplikat
        /system script remove [find name=$s];
        /import "$s.rsc";
        /file remove "$s.rsc";
        :put "Berhasil import: $s";
    } on-error={ :put "Gagal mengunduh modul: $s" }
}

/system scheduler
:do { remove [find name~"RX-"] } on-error={};
add name="RX-BOOT" on-event="/system script run rx-core" start-time=startup policy=read,write,policy,test,sensitive
add name="RX-BOT" interval=25s on-event="/system script run rx-telegram-bot" policy=read,write,policy,test,sensitive

:delay 2s;
/system script run rx-core;
:put "INSTALASI SELESAI. SILAKAN CEK WINBOX.";