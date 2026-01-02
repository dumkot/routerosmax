#-------------------------------------------------------------------------------
# File: rx-telegram-bot.rsc
# Description: Telegram Bot Polling Engine (v7 Only)
#-------------------------------------------------------------------------------
:global rxConfig;
:global RxSendTG;
:global RxCmdDevices;

:local Token ($rxConfig->"tgToken");
:local Offset ($rxConfig->"tgOffset");
:local Allowed ($rxConfig->"allowedChatId");

:if ([:len $Token] = 0) do={ :return nil; }

:do {
    :local Res [/tool fetch url="https://api.telegram.org/bot$Token/getUpdates\?offset=$Offset&limit=1&timeout=10" as-value output=user];
    :if ($Res->"status" = "finished") do={
        :local Data [:deserialize from=json ($Res->"data")];
        :local Updates ($Data->"result");
        
        :foreach u in=$Updates do={
            :local Msg ($u->"message");
            :local Text ($Msg->"text");
            :local From ($Msg->"from"->"id");
            :set ($rxConfig->"tgOffset") (($u->"update_id") + 1);

            :if ([:tostr $From] = $Allowed) do={
                :if ($Text = "/leases") do={ [$RxCmdDevices]; }
                :if ($Text = "/reboot") do={
                    [$RxSendTG] message="\E2\9A\A0 <b>Rebooting System...</b>";
                    :delay 3s;
                    /system reboot;
                }
                :if ($Text = "/ping") do={ [$RxSendTG] message="\F0\9F\8F\93 Pong!"; }
            }
        }
    }
} on-error={ :log debug "TG Polling Timeout/Fail" }
