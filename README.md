# RouterOSMax: High-Performance Network Automation Framework 🚀

![RouterOS](https://img.shields.io/badge/RouterOS-v7.10%2B-blue?style=for-the-badge&logo=mikrotik)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Production-success?style=for-the-badge)
![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=for-the-badge)

**RouterOSMax** adalah kerangka kerja (framework) otomatisasi jaringan berbasis **MikroTik RouterOS v7 Native**. Proyek ini dirancang untuk menggantikan skrip monolitik tua dengan arsitektur modular yang efisien CPU, aman, dan mudah dikelola.

Menggunakan fitur modern v7 seperti `:deserialize` untuk parsing JSON dan REST API handling, RouterOSMax menjembatani router Anda dengan notifikasi real-time via Telegram tanpa membebani resource.

## ✨ Fitur Unggulan

| Fitur | Deskripsi Teknis |
| :--- | :--- |
| **🤖 Telegram Bot v2** | Engine polling asinkron dengan parsing JSON native (Anti-Regex). Mendukung command CLI interaktif. |
| **🛡️ Modular Core** | Kode terpisah antara *Config*, *Core*, dan *Modules*. Satu modul error tidak akan mematikan sistem (Fail-safe). |
| **📶 Hybrid WiFi Audit** | Mendukung monitoring user untuk interface `wireless` (Legacy) dan `wifi` (WifiWave2/AX) sekaligus. |
| **👁️ Smart Netwatch** | Monitoring koneksi internet *recursive* dengan notifikasi status UP/DOWN real-time. |
| **🔒 Secure Overlay** | Konfigurasi user terpisah di `rx-config-overlay`. Aman untuk update core tanpa kehilangan setting. |

## 📂 Struktur Repositori

```text
/
├── src/
│   ├── rx-core.rsc         # Bootloader utama (Run this first!)
│   ├── rx-config.rsc       # Deklarasi variabel default (Read-only)
│   ├── rx-config-overlay.rsc # User Configuration (EDIT THIS)
│   ├── rx-functions.rsc    # Library fungsi global (API & Logging)
│   ├── rx-telegram-bot.rsc # Engine polling & parser perintah
│   ├── rx-system.rsc       # Modul Health Check & Diagnostics
│   ├── rx-mod-netwatch.rsc # Modul Monitoring Internet
│   └── rx-mod-wireless.rsc # Modul Logging Client Wifi
└── README.md
🚀 Instalasi & Deployment
Karena RouterOS tidak mendukung git clone langsung, gunakan cara berikut untuk deployment cepat.

Opsi 1: Copy-Paste (Direkomendasikan)
Buka Winbox -> System -> Scripts.

Buat script baru sesuai nama file di folder src/ (contoh: rx-core, rx-functions, dll).

Copy isi source code dari repo ini ke masing-masing script.

Opsi 2: CLI Download (Jika repo publik)
Jalankan perintah ini di Terminal RouterOS untuk mengunduh file inti (pastikan URL raw sesuai branch main Anda):

Bash

/tool fetch url="[https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-core.rsc](https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-core.rsc)" mode=https dst-path="rx-core.rsc"
/tool fetch url="[https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-config.rsc](https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-config.rsc)" mode=https dst-path="rx-config.rsc"
# Ulangi untuk file lainnya...
⚙️ Konfigurasi (Wajib)
Sistem tidak akan berjalan sebelum Anda mengonfigurasi rx-config-overlay.

Buka script rx-config-overlay.

Edit parameter berikut sesuai data Anda:

Cuplikan kode

# rx-config-overlay
:global rxConfig;

# 1. Token Bot Telegram (Dari @BotFather)
:set ($rxConfig->"tgToken") "123456789:AAFwxxxxxxxxxxxxxxxxx";

# 2. Chat ID Admin (Dari @userinfobot)
:set ($rxConfig->"tgChatId") "987654321";

# 3. Whitelist ID (Untuk izin eksekusi perintah)
:set ($rxConfig->"allowedChatId") "987654321";

# 4. Target Monitoring Internet
:set ($rxConfig->"netwatchTarget") "1.1.1.1";
Jalankan Bootloader untuk menerapkan perubahan:

Bash

/system script run rx-core
🎮 Daftar Perintah Bot
Kirim perintah berikut ke Bot Telegram Anda:

/health — Cek status CPU, RAM, Voltase, dan Suhu.

/reboot — Restart router (dengan jeda pengaman 3 detik).

/check — (Dev) Cek koneksi API manual.

🛠️ Troubleshooting
Q: Bot tidak merespons perintah?

Cek apakah Scheduler berjalan: /system scheduler print.

Pastikan Token dan ChatID benar di rx-config-overlay.

Cek Log: /log print where topics~"RX-MAX".

Q: Error "Script usage not permitted"?

Pastikan script memiliki permission: read, write, policy, test, sensitive.

Q: Monitoring Wifi tidak muncul?

Pastikan parameter :set ($rxConfig->"collectWireless") true; aktif di overlay.

Disclaimer: Gunakan dengan risiko Anda sendiri. Selalu lakukan backup konfigurasi sebelum menerapkan skrip otomatisasi.

Maintainer: Dumkot