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
