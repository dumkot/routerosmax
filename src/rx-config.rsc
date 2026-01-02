#-------------------------------------------------------------------------------
# File: rx-config.rsc
# Description: Configuration with Telegram Bot Support
#-------------------------------------------------------------------------------
:global rxConfig;
:set rxConfig {
    "version"="1.3.0";
    "tgToken"="";
    "tgChatId"="";
    "allowedChatId"=""; # Chat ID yang diizinkan memberi perintah
    "tgOffset"=0;
    "backupEnabled"=true;
    "watchdogTargets"={"8.8.8.8"; "1.1.1.1"};
}
/log info "[RX-MAX] Config v1.3.0 loaded."
