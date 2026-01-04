# Nama Script: rx-telegram-bot
# Deskripsi: Menangani pesan masuk (Polling)

:global rxConfig;
:global RxSendTG;
:global RxCmdHealth;

:local Token ($rxConfig->"tgToken");
:local Offset ($rxConfig->"botOffset");
:local Allowed ($rxConfig->"allowedChatId");

# Cegah running jika token kosong
:if ([:len $Token] < 10) do={ :error "Token not set"; }

:do {
    # Fetch Updates (Timeout 10s agar tidak membebani antrian script)
    :local Res [/tool fetch url="https://api.telegram.org/bot$Token/getUpdates?offset=$Offset&limit=1" as-value output=user keep-result=no];
    
    # JSON Deserialization (Fitur v7)
    :local Data [:deserialize from=json ($Res->"data")];
    :local Results ($Data->"result");

    :foreach update in=$Results do={
        # Update Offset agar pesan tidak diproses ulang
        :set ($rxConfig->"botOffset") (($update->"update_id") + 1);
        
        :local msg ($update->"message");
        :local senderId [:tostr ($msg->"from"->"id")];
        :local text ($msg->"text");

        # Security Check: Hanya proses jika Sender ID valid
        :if ($senderId = $Allowed) do={
            :log info "[RX-MAX] Cmd: $text";
            
            # Routing Perintah
            :if ($text = "/health") do={ [$RxCmdHealth]; }
            :if ($text = "/reboot") do={ 
                $RxSendTG message="System Reboot Melakukan restart dalam 3 detik...";
                :delay 3s; 
                /system reboot; 
            }
        } else={
            :log warning "[RX-MAX] Unauthorized Access Blocked from ID: $senderId";
        }
    }
} on-error={
    # Silent error (timeout fetch adalah hal wajar)
}
