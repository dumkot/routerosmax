# Nama Script: rx-config-overlay
# Deskripsi: Konfigurasi Spesifik User (Override)

:global rxConfig;

# --- MULAI EDIT DI SINI ---

# 1. Token Bot Telegram (Dapat dari @BotFather)
:set ($rxConfig->"tgToken") "TOKEN_BOT_ANDA_DISINI";

# 2. Chat ID Admin (Dapat dari @userinfobot)
:set ($rxConfig->"tgChatId") "123456789";

# 3. Whitelist User (ID yang boleh kirim perintah)
:set ($rxConfig->"allowedChatId") "123456789";

# 4. Target Ping untuk Monitor Internet
:set ($rxConfig->"netwatchTarget") "1.1.1.1";

# 5. Monitor User Wifi Baru? (true/false)
:set ($rxConfig->"collectWireless") true;

# --- SELESAI EDIT ---

:log info "[RX-MAX] User overlay configuration loaded.";