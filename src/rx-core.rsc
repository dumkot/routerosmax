# Nama Script: rx-core
# Deskripsi: Bootloader utama

:log info ">>> Starting RouterOSMax Core...";

:do {
    # 1. Load Konfigurasi
    /system script run rx-config;
    
    # 2. Load Overlay (Cek apakah user sudah buat config)
    :if ([:len [/system script find name="rx-config-overlay"]] > 0) do={
        /system script run rx-config-overlay;
    } else={
        :error "File rx-config-overlay tidak ditemukan!";
    }

    # 3. Load Functions
    /system script run rx-functions;
    
    # 4. Load Modules
    /system script run rx-system;
    /system script run rx-mod-netwatch;
    /system script run rx-mod-wireless;

    # 5. Pasang Scheduler (Agar bot jalan otomatis tiap 30 detik)
    :local schedName "rx-bot-scheduler";
    :if ([:len [/system scheduler find name=$schedName]] = 0) do={
        /system scheduler add name=$schedName interval=30s on-event="rx-telegram-bot" policy=read,write,policy,test,sensitive comment="RouterOSMax Bot Polling";
        :log info "[RX-MAX] Scheduler dipasang.";
    }

    :log info ">>> RouterOSMax Online & Ready.";
    
    # Kirim notifikasi boot (Opsional)
    :global RxSendTG;
    :global rxConfig;
    :if ([:len ($rxConfig->"tgToken")] > 10) do={
        $RxSendTG message="🚀 <b>System Boot</b>\nRouterOSMax Core telah dimuat ulang.";
    }

} on-error={
    :log error "[RX-MAX] FATAL ERROR saat booting core. Cek log.";
}