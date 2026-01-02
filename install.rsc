# RouterOSMax Master Installer (Fixed & Clean)
/system script
:do { remove [find name~"rx-"] } on-error={};

:local baseUrl "https://raw.githubusercontent.com/dumkot/routerosmax/main/src";
:local scripts {"rx-config"; "rx-config-overlay"; "rx-functions"; "rx-mod-wireless"; "rx-mod-netwatch"; "rx-system"; "rx-telegram-bot"; "rx-core"};

:foreach s in=$scripts do={
    :do {
        /tool fetch url="$baseUrl/$s.rsc" dst-path="$s.rsc" mode=https;
        :delay 1s;
        # Menghapus script lama jika ada sebelum import
        /system script remove [find name=$s];
        /import "$s.rsc";
        /file remove "$s.rsc";
    } on-error={ :put "Gagal tarik modul: $s" }
}

/system scheduler
:do { remove [find name~"RX-"] } on-error={};
/system scheduler add name="RX-BOOT" on-event="/system script run rx-core" start-time=startup policy=read,write,policy,test,sensitive;
/system scheduler add name="RX-BOT" interval=25s on-event="/system script run rx-telegram-bot" policy=read,write,policy,test,sensitive;

:put "BERES. File src sudah di-import jadi System Script.";