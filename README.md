# RouterOSMax 🚀

![RouterOS](https://img.shields.io/badge/RouterOS-v7.x-blue?style=for-the-badge&logo=mikrotik)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Stable-success?style=for-the-badge)

**RouterOSMax** adalah framework otomatisasi modular untuk MikroTik RouterOS v7. Dirancang untuk stabilitas, efisiensi CPU, dan manajemen jaringan modern dengan integrasi Telegram Bot interaktif.

## ✨ Fitur Unggulan

| Modul | Deskripsi |
| :--- | :--- |
| **🤖 Telegram Bot** | Kontrol terminal via chat. Mendukung `/reboot`, `/health`, dll. |
| **📶 Hybrid WiFi** | Mendukung audit untuk **Wireless (Legacy)** dan **WifiWave2 (AX)**. |
| **👁️ Smart Netwatch** | Notifikasi *real-time* status internet (UP/DOWN) dengan durasi. |
| **🛡️ Modular Core** | Arsitektur skrip terpisah. Gagal satu modul tidak mematikan sistem. |
| **📊 Diagnostics** | Monitoring suhu CPU, Voltase, dan RAM via Telegram. |

## 📦 Instalasi

Jalankan perintah berikut di Terminal MikroTik (Winbox/SSH). Pastikan router terhubung ke internet.

```bash
/tool fetch url="https://raw.githubusercontent.com/dumkot/routerosmax/main/install.rsc" check-certificate=yes;
:delay 3s;
/import install.rsc;

```

## ⚙️ Konfigurasi (Wajib)

Jangan mengedit file inti (`rx-config`). Gunakan file **overlay** agar konfigurasi aman saat update skrip.

1. Buka menu **System -> Scripts**.
2. Edit script bernama **`rx-config-overlay`**.
3. Isi dengan data bot Anda:

```routeros
:global rxConfig;

# Token Bot dari @BotFather
:set ($rxConfig->"tgToken") "123456789:AAFwxxxxxxxxxxxxxxxxx";

# Chat ID Anda dari @userinfobot
:set ($rxConfig->"tgChatId") "987654321";

# Whitelist ID untuk izin eksekusi perintah (Keamanan)
:set ($rxConfig->"allowedChatId") "987654321";

```

4. Terapkan perubahan dengan perintah:

```bash
/system script run rx-core

```

## 🎮 Perintah Bot Telegram

| Perintah | Fungsi |
| --- | --- |
| `/health` | Menampilkan beban CPU, Sisa RAM, dan Suhu Perangkat. |
| `/reboot` | Merestart router (dengan jeda pengaman 2 detik). |
| `/check` | Memeriksa update firmware RouterOS. |

---

**Disclaimer:** *Gunakan dengan risiko sendiri. Selalu backup konfigurasi sebelum menerapkan skrip otomatisasi.*

Maintainer: [Dumkot](https://www.google.com/search?q=https://github.com/dumkot)

```

### 3. Catatan Terakhir untuk `install.rsc`
Pastikan di dalam file `install.rsc` Anda terdapat logika untuk membuat scheduler secara otomatis:
```routeros
/system scheduler add name="rx-bot-job" interval=30s on-event="/system script run rx-telegram-bot" policy=read,write,policy,test,sensitive

```

