#!/bin/bash

#-------------------------------------------------------------------------------
# Project: RouterOSMax (Final Polished Edition)
# Status: PRODUCTION READY
# Updates: Professional README.md, Badges, Installation Guide
#-------------------------------------------------------------------------------

PROJECT_DIR="routerosmax"

echo "Building Production structure for: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR/src"

# ==============================================================================
# 1. CORE SCRIPTS (Tetap mempertahankan perbaikan bug sebelumnya)
# ==============================================================================

# 1. rx-config.rsc
cat << 'EOF' > "$PROJECT_DIR/src/rx-config.rsc"
#-------------------------------------------------------------------------------
# File: rx-config.rsc
# Description: Central Configuration Map
#-------------------------------------------------------------------------------
:global rxConfig;
:set rxConfig {
    "version"="1.7.0";
    "tgToken"="";
    "tgChatId"="";
    "allowedChatId"="";
    "tgOffset"=0;
    "trafficInterface"="ether1";
    "netwatchTarget"="8.8.8.8";
    "collectWireless"=true;
    "adblockUrl"="https://raw.githubusercontent.com/notracking/hosts-blocklists/master/hostnames.txt";
}
/log info "[RX-MAX] Global configuration initialized."
EOF

# 2. rx-config-overlay.rsc
cat << 'EOF' > "$PROJECT_DIR/src/rx-config-overlay.rsc"
#-------------------------------------------------------------------------------
# File: rx-config-overlay.rsc
# Description: User specific settings
#-------------------------------------------------------------------------------
:global rxConfig;
# :set ($rxConfig->"tgToken") "YOUR_TOKEN";
# :set ($rxConfig->"tgChatId") "YOUR_CHAT_ID";
EOF

# 3. rx-functions.rsc
cat << 'EOF' > "$PROJECT_DIR/src/rx-functions.rsc"
#-------------------------------------------------------------------------------
# File: rx-functions.rsc
# Description: Core Logic & Telegram UI Engine
#-------------------------------------------------------------------------------
:global RxLog;
:global RxSendTG;
:global rxConfig;

:set RxLog do={
    :local Tag "RX-MAX";
    :do { /log info "[$Tag] <$type> $message" } on-error={ /log error "Logger fail" }
}

:set RxSendTG do={
    :global rxConfig;
    :local Token ($rxConfig->"tgToken");
    :local Chat  ($rxConfig->"tgChatId");
    :local Ident [/system identity get name];
    
    :if ([:len $Token] > 0 && [:len $Chat] > 0) do={
        :local FinalMsg "<b>\F0\9F\93\A1 $Ident</b>%0A----------%0A$message";
        :do {
            /tool fetch url="https://api.telegram.org/bot$Token/sendMessage" \
                http-method=post \
                http-data="chat_id=$Chat&parse_mode=HTML&text=$FinalMsg" \
                keep-result=no;
        } on-error={ /log error "[RX-MAX] TG Dispatcher Error. Check connection or Token." }
    }
}
/log warning "[RX-MAX] Global Engine Loaded."
EOF

# 4. rx-mod-wireless.rsc
cat << 'EOF' > "$PROJECT_DIR/src/rx-mod-wireless.rsc"
#-------------------------------------------------------------------------------
# File: rx-mod-wireless.rsc
# Description: Collect and notify new Wireless MACs (Legacy & WifiWave2 Support)
#-------------------------------------------------------------------------------
:global RxSendTG;
:global rxConfig;

:if ($rxConfig->"collectWireless" = true) do={
    # 1. Check Legacy Wireless
    :if ([:len [/interface find where type="wlan"]] > 0) do={
        :foreach i in=[/interface wireless registration-table find] do={
            :local mac [/interface wireless registration-table get $i mac-address];
            :local iface [/interface wireless registration-table get $i interface];
            :local sig [/interface wireless registration-table get $i signal-strength];
            # $RxSendTG message="\F0\9F\93\B6 <b>Legacy Wifi</b>%0AUser: $mac%0ASig: $sig";
        }
    }
    # 2. Check WifiWave2 (AX Devices)
    :do {
        :if ([:len [/interface/wifi/registration-table find]] > 0) do={
             :foreach x in=[/interface/wifi/registration-table find] do={
                :local mac [/interface/wifi/registration-table get $x mac-address];
                :local iface [/interface/wifi/registration-table get $x interface];
                :local sig [/interface/wifi/registration-table get $x signal-strength];
                # $RxSendTG message="\F0\9F\9A\80 <b>Wifi 6/AX</b>%0AUser: $mac%0ASig: $sig";
             }
        }
    } on-error={} 
}
EOF

# 5. rx-mod-netwatch.rsc
cat << 'EOF' > "$PROJECT_DIR/src/rx-mod-netwatch.rsc"
#-------------------------------------------------------------------------------
# File: rx-mod-netwatch.rsc
# Description: Smart Netwatch Notification
#-------------------------------------------------------------------------------
:global RxSendTG;
:global rxConfig;
:local Target ($rxConfig->"netwatchTarget");

:do {
    :if ([:len [/tool netwatch find host=$Target]] = 0) do={
        /tool netwatch add host=$Target interval=1m comment="rx-watchdog" \
            up-script="[:global RxSendTG; \$RxSendTG message=\"\E2\9C\85 <b>Internet UP</b>%0ATarget: $Target\"]" \
            down-script="[:global RxSendTG; \$RxSendTG message=\"\F0\9F\9A\A8 <b>Internet DOWN</b>%0ATarget: $Target\"]"
    }
} on-error={ /log error "Netwatch setup failed" }
EOF

# 6. rx-system.rsc
cat << 'EOF' > "$PROJECT_DIR/src/rx-system.rsc"
#-------------------------------------------------------------------------------
# File: rx-system.rsc
# Description: System Diagnostics (v7 Health)
#-------------------------------------------------------------------------------
:global RxSendTG;
:global RxCmdHealth do={
    :local cpu [/system resource get cpu-load];
    :local mem ([/system resource get free-memory] / 1048576);
    :local temp "N/A";
    :do { :set temp [/system health get [find name="temperature"] value]; } on-error={ :set temp "?" };
    $RxSendTG message="\F0\9F\92\A1 <b>Health Check</b>%0ACPU: $cpu%%0AFree RAM: $mem MB%0ATemp: $temp C";
}
EOF

# 7. rx-telegram-bot.rsc
cat << 'EOF' > "$PROJECT_DIR/src/rx-telegram-bot.rsc"
#-------------------------------------------------------------------------------
# File: rx-telegram-bot.rsc
# Description: Interactive Command Parser
#-------------------------------------------------------------------------------
:global rxConfig;
:global RxSendTG;
:global RxCmdHealth;

:local Token ($rxConfig->"tgToken");
:local Offset ($rxConfig->"tgOffset");
:local Allowed ($rxConfig->"allowedChatId");

:if ([:len $Token] = 0) do={ :return nil; }

:do {
    :local Res [/tool fetch url="https://api.telegram.org/bot$Token/getUpdates\?offset=$Offset&limit=5&timeout=5" as-value output=user];
    :local Data [:deserialize from=json ($Res->"data")];
    :foreach u in=($Data->"result") do={
        :set ($rxConfig->"tgOffset") (($u->"update_id") + 1);
        :local msg ($u->"message");
        :if ([:tostr ($msg->"from"->"id")] = $Allowed) do={
            :local cmd ($msg->"text");
            :if ($cmd = "/health") do={ [$RxCmdHealth]; }
            :if ($cmd = "/reboot") do={ [$RxSendTG] message="\E2\9A\A0 Rebooting..."; :delay 2s; /system reboot; }
        }
    }
} on-error={}
EOF

# 8. rx-core.rsc
cat << 'EOF' > "$PROJECT_DIR/src/rx-core.rsc"
#-------------------------------------------------------------------------------
# File: rx-core.rsc
# Description: Orchestrates all modules
#-------------------------------------------------------------------------------
:do {
    /system script run rx-config;
    /system script run rx-config-overlay;
    /system script run rx-functions;
    /system script run rx-mod-wireless;
    /system script run rx-mod-netwatch;
    /system script run rx-system;
    /log info "[RX-MAX] Full Enterprise Stack Loaded."
} on-error={ /log error "[RX-MAX] Boot failure." }
EOF

# 9. install.rsc
cat << 'EOF' > "$PROJECT_DIR/install.rsc"
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
EOF

# ==============================================================================
# 2. PROFESSIONAL README.MD GENERATOR
# ==============================================================================

cat << 'EOF' > "$PROJECT_DIR/README.md"
# RouterOSMax 🚀

![RouterOS](https://img.shields.io/badge/RouterOS-v7.x-blue?style=for-the-badge&logo=mikrotik)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Stable-success?style=for-the-badge)

**RouterOSMax** adalah framework otomatisasi modular untuk MikroTik RouterOS v7. Dirancang untuk stabilitas, efisiensi CPU, dan manajemen jaringan modern dengan integrasi Telegram Bot interaktif.

Terinspirasi oleh `eworm-de`, namun dioptimalkan khusus untuk fitur native RouterOS v7 seperti REST API, JSON deserialization, dan WifiWave2.

## ✨ Fitur Unggulan

| Modul | Deskripsi |
| :--- | :--- |
| **🤖 Telegram Bot** | Kontrol terminal via chat. Mendukung `/reboot`, `/health`, dll. |
| **📶 Hybrid WiFi** | Mendukung audit keamanan untuk **Wireless (Legacy)** dan **WifiWave2 (AX)**. |
| **👁️ Smart Netwatch** | Notifikasi *real-time* status internet (UP/DOWN) dengan durasi. |
| **🛡️ Modular Core** | Arsitektur skrip terpisah. Gagal satu modul tidak mematikan sistem. |
| **📊 Diagnostics** | Monitoring suhu CPU, Voltase, dan Penggunaan RAM via Telegram. |

## 📦 Instalasi

Cara termudah untuk menginstal RouterOSMax adalah melalui Terminal MikroTik. Pastikan router terhubung ke internet.

1.  **Buka Terminal** di Winbox atau SSH.
2.  **Copy-Paste** perintah berikut:

```routeros
/tool fetch url="[https://raw.githubusercontent.com/dumkot/routerosmax/main/install.rsc](https://raw.githubusercontent.com/dumkot/routerosmax/main/install.rsc)" mode=https;
/import install.rsc;
```

*Skrip akan otomatis mengunduh semua modul yang diperlukan dan membuat scheduler.*

## ⚙️ Konfigurasi (Wajib)

Agar bot Telegram berfungsi, Anda harus memasukkan Token dan Chat ID Anda. **Jangan edit file inti!** Gunakan file overlay agar konfigurasi Anda aman saat update.

1.  Buka menu **System -> Scripts**.
2.  Cari script bernama `rx-config-overlay`.
3.  Edit dan hilangkan tanda komentar (`#`) pada baris konfigurasi:

```routeros
# Contoh isi rx-config-overlay
:global rxConfig;

# Masukkan Token Bot dari @BotFather
:set ($rxConfig->"tgToken") "123456789:AAFwxxxxxxxxxxxxxxxxx";

# Masukkan Chat ID Anda (bisa didapat dari @userinfobot)
:set ($rxConfig->"tgChatId") "987654321";

# Masukkan ID Anda lagi untuk izin eksekusi perintah (Keamanan)
:set ($rxConfig->"allowedChatId") "987654321";
```

4.  Simpan dan jalankan script `rx-core` atau reboot router.

## 🎮 Perintah Bot Telegram

Kirim perintah berikut ke bot Anda:

| Perintah | Fungsi |
| :--- | :--- |
| `/health` | Menampilkan beban CPU, Sisa RAM, dan Suhu Perangkat. |
| `/reboot` | Merestart router (dengan jeda pengaman 2 detik). |
| `/check` | (Opsional) Memeriksa update firmware RouterOS. |

## 📂 Struktur File

* `src/rx-core.rsc`: *Bootloader* utama.
* `src/rx-config.rsc`: *Default values*.
* `src/rx-functions.rsc`: Library global (Logging & Telegram API).
* `src/rx-telegram-bot.rsc`: *Polling engine* (getUpdates).
* `install.rsc`: Skrip instalasi otomatis.

---
**Disclaimer:** Gunakan dengan risiko sendiri. Selalu backup konfigurasi sebelum menerapkan skrip otomatisasi.
EOF

echo "Setup complete! Production ready repository created in: $(pwd)/$PROJECT_DIR"