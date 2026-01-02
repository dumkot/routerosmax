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
