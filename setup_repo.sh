#!/bin/bash

#-------------------------------------------------------------------------------
# Project: RouterOSMax (Advanced Interactive Edition)
# Description: Modular structure with Telegram Bot (Polling) and DHCP/ARP modules
#-------------------------------------------------------------------------------

PROJECT_DIR="routerosmax"

echo "Creating advanced interactive project directory: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR/src"

# 1. Update rx-config.rsc (Added Allowed ID & Offset)
cat << 'EOF' > "$PROJECT_DIR/src/rx-config.rsc"
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
EOF

# 2. Update rx-functions.rsc (Added Parser & Commands)
cat << 'EOF' > "$PROJECT_DIR/src/rx-functions.rsc"
#-------------------------------------------------------------------------------
# File: rx-functions.rsc
# Description: Global Function Registry (Extended for Bot)
#-------------------------------------------------------------------------------
:global RxLog;
:global RxSendTG;
:global rxConfig;

:set RxLog do={
    :local Tag "RX-MAX";
    :do { /log info "[$Tag] <$type> $message" } on-error={ :log error "Logger fail" }
}

:set RxSendTG do={
    :global rxConfig;
    :local Token ($rxConfig->"tgToken");
    :local Chat  ($rxConfig->"tgChatId");
    :if ([:len $Token] > 0 && [:len $Chat] > 0) do={
        :local FinalMsg "<b>\F0\9F\93\A1 $[/system identity get name]</b>%0A$message";
        :do {
            /tool fetch url="https://api.telegram.org/bot$Token/sendMessage" \
                http-method=post http-data="chat_id=$Chat&parse_mode=HTML&text=$FinalMsg" \
                keep-result=no;
        } on-error={ /log error "[RX-MAX] TG send failed." }
    }
}
/log warning "[RX-MAX] Bot Functions registered."
EOF

# 3. Create rx-dhcp-arp.rsc (Leases & ARP Monitoring)
cat << 'EOF' > "$PROJECT_DIR/src/rx-dhcp-arp.rsc"
#-------------------------------------------------------------------------------
# File: rx-dhcp-arp.rsc
# Description: DHCP Leases & ARP Monitoring Module
#-------------------------------------------------------------------------------
:global RxLog;
:global RxSendTG;

:local GetDevices do={
    :local Out "<b>\F0\9F\93\B1 Connected Devices</b>%0A";
    :local Count 0;
    /ip dhcp-server lease;
    :foreach i in=[find where status=bound] do={
        :set Count ($Count + 1);
        :local host [get $i host-name];
        :local addr [get $i address];
        :set Out "$Out$Count. <code>$addr</code> - $host%0A";
    }
    :return $Out;
}

:global RxCmdDevices do={
    :global RxSendTG;
    :local List [$GetDevices];
    [$RxSendTG] message=$List;
}
EOF

# 4. Create rx-telegram-bot.rsc (The Polling Engine)
cat << 'EOF' > "$PROJECT_DIR/src/rx-telegram-bot.rsc"
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
EOF

# 5. Create rx-core.rsc (Orchestrator)
cat << 'EOF' > "$PROJECT_DIR/src/rx-core.rsc"
#-------------------------------------------------------------------------------
# File: rx-core.rsc
# Description: System Loader
#-------------------------------------------------------------------------------
:do {
    /system script run rx-config;
    /system script run rx-config-overlay;
    /system script run rx-functions;
    /system script run rx-dhcp-arp;
    /log info "[RX-MAX] Core components initialized."
} on-error={ /log error "[RX-MAX] CRITICAL: Load failed." }
EOF

# 6. Create Master Installer install.rsc
cat << 'EOF' > "$PROJECT_DIR/install.rsc"
# RouterOSMax Professional Installer
/system script
:do { remove [find name~"rx-"] } on-error={};
:local baseUrl "https://raw.githubusercontent.com/dumkot/routerosmax/main/src";
:local scripts {"rx-config"; "rx-config-overlay"; "rx-functions"; "rx-dhcp-arp"; "rx-telegram-bot"; "rx-core"};

:foreach s in=$scripts do={
    :do {
        add name=$s source=([/tool fetch url="$baseUrl/$s.rsc" output=user as-value]->"data");
    } on-error={ /log error "Failed to fetch $s" }
}

/system scheduler
:do { remove [find name~"RX-"] } on-error={};
add name="RX-BOOT" on-event="/system script run rx-core" start-time=startup
add name="RX-TG-BOT" interval=30s on-event="/system script run rx-telegram-bot"
/system script run rx-core
EOF

echo "Setup complete! Interactive Bot and DHCP/ARP modules are ready in: $PROJECT_DIR"