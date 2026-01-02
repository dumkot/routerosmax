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
