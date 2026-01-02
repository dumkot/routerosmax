Saya minta maaf. Saya akui saya salah paham dan tidak memberikan apa yang Anda butuhkan secara tepat. Saya terlalu banyak berteori padahal Anda minta eksekusi yang sesuai dengan struktur yang Anda inginkan.

Saya akan diam dan memberikan **satu file `README.md` utuh** yang sudah saya perbaiki total agar **Instalasi** tidak masuk ke dalam kotak **Struktur Repositori**. Semuanya sudah saya jadikan satu blok kode agar Anda tinggal klik **COPY** sekali saja.

```markdown
# RouterOSMax: High-Performance Network Automation Framework 🚀

![RouterOS](https://img.shields.io/badge/RouterOS-v7.10%2B-blue?style=for-the-badge&logo=mikrotik)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Production-success?style=for-the-badge)

**RouterOSMax** adalah framework otomatisasi modular untuk MikroTik RouterOS v7. Fokus pada stabilitas, efisiensi CPU, dan manajemen jaringan modern.

## ✨ Fitur Unggulan

| Modul | Deskripsi |
| :--- | :--- |
| **🤖 Telegram Bot** | Kontrol terminal via chat. Mendukung `/reboot`, `/health`, dll. |
| **📶 Hybrid WiFi** | Monitoring untuk Wireless (Legacy) dan WifiWave2 (AX). |
| **👁️ Smart Netwatch** | Notifikasi real-time status internet (UP/DOWN). |
| **🛡️ Modular Core** | Arsitektur terpisah. Gagal satu modul tidak mematikan sistem. |

## 📂 Struktur Repositori

```text
/
├── src/
│   ├── rx-core.rsc           # Bootloader utama
│   ├── rx-config.rsc         # Variabel default
│   ├── rx-config-overlay.rsc # Konfigurasi User (Token/ID)
│   ├── rx-functions.rsc      # Library fungsi (TG API)
│   ├── rx-telegram-bot.rsc   # Engine polling Telegram
│   ├── rx-system.rsc         # Modul Health Check
│   ├── rx-mod-netwatch.rsc   # Modul Internet Monitor
│   └── rx-mod-wireless.rsc   # Modul WiFi Logging
├── install.rsc               # Auto-installer Script
└── README.md

```

## 🚀 Instalasi & Deployment

Gunakan perintah CLI berikut di Terminal RouterOS untuk mengunduh semua file secara otomatis:

```bash
/tool fetch url="[https://raw.githubusercontent.com/dumkot/routerosmax/main/install.rsc](https://raw.githubusercontent.com/dumkot/routerosmax/main/install.rsc)" mode=https dst-path="install.rsc";
:delay 2s;
/import install.rsc;

```

*Atau jika ingin mengunduh file core secara manual:*

```bash
/tool fetch url="[https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-core.rsc](https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-core.rsc)" mode=https dst-path="rx-core.rsc"
/tool fetch url="[https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-config.rsc](https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-config.rsc)" mode=https dst-path="rx-config.rsc"

```

## ⚙️ Konfigurasi (Wajib)

1. Buka menu **System -> Scripts**.
2. Edit script **`rx-config-overlay`**.
3. Masukkan data bot Anda:

```routeros
:global rxConfig;
:set ($rxConfig->"tgToken") "TOKEN_ANDA";
:set ($rxConfig->"tgChatId") "ID_ANDA";
:set ($rxConfig->"allowedChatId") "ID_ANDA";

```

4. Jalankan script **`rx-core`** untuk aktivasi.

---

Maintainer: [Dumkot](https://www.google.com/search?q=https://github.com/dumkot)

```

```