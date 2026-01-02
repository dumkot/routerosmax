# Nama Script: rx-config
# Deskripsi: Definisi Variabel Global (Default Values)

:global rxConfig;
:set $rxConfig {
    "tgToken"="";
    "tgChatId"="";
    "allowedChatId"="";
    "pollInterval"="10s";
    "botOffset"=0;
    "netwatchTarget"="8.8.8.8";
    "collectWireless"=true;
    "debugMode"=false
};
:log info "[RX-MAX] Default configuration loaded.";