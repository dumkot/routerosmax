# Nama Script: rx-mod-wireless
# Deskripsi: Log device baru yang connect ke Wifi

:global RxSendTG;
:global rxConfig;

:if ($rxConfig->"collectWireless" = true) do={
    
    # 1. Cek Wireless Legacy (Interface 'wlan')
    :do {
        :foreach i in=[/interface wireless registration-table find] do={
            # Logika deteksi user baru bisa dikembangkan dengan menyimpan MAC ke array global
            # Untuk versi lite ini, kita hanya log debug agar tidak spam Telegram
            :local mac [/interface wireless registration-table get $i mac-address];
            :log debug "[RX-MAX] Legacy Client: $mac";
        }
    } on-error={}

    # 2. Cek WifiWave2 / Wifi (Interface 'wifi') - v7 Only
    :do {
        :if ([:len [/interface/wifi/registration-table find]] > 0) do={
             :foreach x in=[/interface/wifi/registration-table find] do={
                :local mac [/interface/wifi/registration-table get $x mac-address];
                :local sig [/interface/wifi/registration-table get $x signal-strength];
                :log debug "[RX-MAX] AX Client: $mac ($sig)";
            }
        }
    } on-error={}
}