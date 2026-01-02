# Nama Script: rx-functions
# Deskripsi: Library Fungsi Global (Send TG & Logging)

:global RxLog;
:global RxSendTG;
:global rxConfig;

# Fungsi Logger Terpusat
:set RxLog do={
    :local Tag "RX-MAX";
    :do { /log info "[$Tag] $1" } on-error={ /log error "Logger failed" }
}

# Fungsi Kirim Telegram (JSON Method - Support Karakter Spesial)
:set RxSendTG do={
    :global rxConfig;
    :local Token ($rxConfig->"tgToken");
    :local Chat  ($rxConfig->"tgChatId");
    :local Ident [/system identity get name];
    :local MsgBody $message;

    # Validasi Token
    :if ([:len $Token] > 10) do={
        # Construct JSON Payload Manual (v7 Safe)
        # Note: Kita gunakan format JSON agar karakter seperti '&', '?', '=' tidak merusak URL
        :local Payload ("{\"chat_id\":\"" . $Chat . "\", \"parse_mode\":\"HTML\", \"text\":\"<b>📡 " . $Ident . "</b>\n\n" . $MsgBody . "\"}");
        
        :do {
            /tool fetch url="https://api.telegram.org/bot$Token/sendMessage" \
                http-method=post \
                http-header-field="Content-Type: application/json" \
                http-data=$Payload \
                keep-result=no;
        } on-error={
            :log warning "[RX-MAX] Gagal mengirim pesan Telegram. Cek koneksi/Token.";
        }
    } else={
        :log error "[RX-MAX] Token Telegram belum diset di rx-config-overlay!";
    }
}
:log info "[RX-MAX] Global functions loaded.";