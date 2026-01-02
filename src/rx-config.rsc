#-------------------------------------------------------------------------------
# File: rx-config.rsc
# Description: Central Configuration Map
#-------------------------------------------------------------------------------
:global rxConfig;
:set rxConfig {
    "version"="1.7.0";
    "tgToken"="";
    "tgChatId"="";
    "allowedChatId"="";
    "tgOffset"=0;
    "trafficInterface"="ether1";
    "netwatchTarget"="8.8.8.8";
    "collectWireless"=true;
    "adblockUrl"="https://raw.githubusercontent.com/notracking/hosts-blocklists/master/hostnames.txt";
}
/log info "[RX-MAX] Global configuration initialized."
