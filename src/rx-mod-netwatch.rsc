# Nama Script: rx-mod-netwatch
# Deskripsi: Setup Netwatch otomatis berdasarkan config

:global rxConfig;
:local Target ($rxConfig->"netwatchTarget");

:do {
    # Cek apakah rule sudah ada, jika belum buat baru
    :if ([:len [/tool netwatch find host=$Target]] = 0) do={
        /tool netwatch add host=$Target interval=1m timeout=2s comment="rx-watchdog" \
            up-script=":global RxSendTG; \$RxSendTG message=\"✅ <b>Internet UP</b>\nTarget: $Target kembali online.\"" \
            down-script=":global RxSendTG; \$RxSendTG message=\"🚨 <b>Internet DOWN</b>\nTarget: $Target tidak dapat dijangkau!\"";
            
        :log info "[RX-MAX] Netwatch rule created for $Target";
    }
} on-error={ 
    :log error "[RX-MAX] Gagal membuat Netwatch rule."; 
}