#!/bin/bash

#-------------------------------------------------------------------------------
# Project: RouterOSMax Repo Generator
# Description: Creates local file structure for GitHub Desktop
#-------------------------------------------------------------------------------

PROJECT_DIR="routerosmax"

echo "Creating project directory: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR/src"

# 1. Create rx-core.rsc (LATEST VERSION)
cat << 'EOF' > "$PROJECT_DIR/src/rx-core.rsc"
#-------------------------------------------------------------------------------
# File: rx-core.rsc
# Description: Global Function & Logging Engine for RouterOSMax
#-------------------------------------------------------------------------------

:global RxLog;
:global RxCoreLoaded;

:set RxLog do={
:local Tag "RX-MAX";
:local LogType [:tostr $type];
:local Msg [:tostr $message];

:do {
    /log info "[$Tag] <$LogType> $Msg";
} on-error={ :log error "Logger failure." }

}

:set RxCoreLoaded true;
/log warning "[RX-MAX] Core Engine Initialized.";
EOF

# 2. Create rx-security.rsc
cat << 'EOF' > "$PROJECT_DIR/src/rx-security.rsc"
#-------------------------------------------------------------------------------
# File: rx-security.rsc
# Description: Firewall Hardening & Brute-force Protection
#-------------------------------------------------------------------------------
:global RxLog;
:do {
    /ip firewall filter;
    :if ([:len [find comment="RX-SEC-TRUSTED"]] = 0) do={
        add chain=input action=accept connection-state=established,related comment="RX-SEC-TRUSTED" place-before=0
    }
    :if ([:len [find comment="RX-SEC-DROP-INVALID"]] = 0) do={
        add chain=input action=drop connection-state=invalid comment="RX-SEC-DROP-INVALID" place-before=1
    }
    $RxLog type="security" message="Firewall policies updated.";
} on-error={ :log error "Security module error." }
EOF

# 3. Create rx-maintenance.rsc
cat << 'EOF' > "$PROJECT_DIR/src/rx-maintenance.rsc"
#-------------------------------------------------------------------------------
# File: rx-maintenance.rsc
# Description: Resource Optimization & Cache Cleanup
#-------------------------------------------------------------------------------
:global RxLog;
:do {
    /ip dns cache flush;
    /ip arp remove [find dynamic=yes];
    $RxLog type="maintenance" message="DNS/ARP Cache flushed.";
} on-error={ :log error "Maintenance module error." }
EOF

# 4. Create rx-backup.rsc
cat << 'EOF' > "$PROJECT_DIR/src/rx-backup.rsc"
#-------------------------------------------------------------------------------
# File: rx-backup.rsc
# Description: Automatic Binary Backup and Script Export
#-------------------------------------------------------------------------------
:global RxLog;
:local DeviceName [/system identity get name];
:local TimeStamp [:pick [/system clock get date] 7 11][:pick [/system clock get date] 0 3][:pick [/system clock get date] 4 6];
:local FileName "RX-$DeviceName-$TimeStamp";

:do {
    /system backup save name=$FileName;
    :delay 2s;
    /export file=$FileName;
    $RxLog type="backup" message="Backup saved as $FileName";
} on-error={ $RxLog type="error" message="Backup failed." }
EOF

# 5. Create rx-watchdog.rsc
cat << 'EOF' > "$PROJECT_DIR/src/rx-watchdog.rsc"
#-------------------------------------------------------------------------------
# File: rx-watchdog.rsc
# Description: Internet Connectivity Watchdog
#-------------------------------------------------------------------------------
:global RxLog;
:local Targets {"8.8.8.8"; "1.1.1.1"};
:local Fails 0;
:foreach T in=$Targets do={
    :do {
        :if ([/tool ping $T count=2 as-value]->"received" = 0) do={ :set Fails ($Fails + 1) }
    } on-error={ :set Fails ($Fails + 1) }
}
:if ($Fails = [:len $Targets]) do={
    $RxLog type="critical" message="INTERNET DOWN!";
}
EOF

# 6. Create Master Installer install.rsc
cat << 'EOF' > "$PROJECT_DIR/install.rsc"
# RouterOSMax Master Installer
/system script
:do { remove [find name~"rx-"] } on-error={};
add name=rx-core source=[/tool fetch url="https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-core.rsc" output=user as-value]->"data"
add name=rx-security source=[/tool fetch url="https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-security.rsc" output=user as-value]->"data"
add name=rx-maintenance source=[/tool fetch url="https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-maintenance.rsc" output=user as-value]->"data"
add name=rx-backup source=[/tool fetch url="https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-backup.rsc" output=user as-value]->"data"
add name=rx-watchdog source=[/tool fetch url="https://raw.githubusercontent.com/dumkot/routerosmax/main/src/rx-watchdog.rsc" output=user as-value]->"data"

/system scheduler
:do { remove [find name~"RX-"] } on-error={};
add name="RX-INIT" on-event="/system script run rx-core" start-time=startup
add interval=1d name="RX-DAILY-BACKUP" on-event="/system script run rx-backup" start-time=04:00:00
/system script run rx-core
/log info "RouterOSMax Installed Successfully."
EOF

# 7. Create README.md
cat << 'EOF' > "$PROJECT_DIR/README.md"
# RouterOSMax
Kumpulan skrip otomatisasi MikroTik RouterOS v7 modular.

## Instalasi
```routeros
/tool fetch url="[https://raw.githubusercontent.com/dumkot/routerosmax/main/install.rsc](https://raw.githubusercontent.com/dumkot/routerosmax/main/install.rsc)";
/import install.rsc;
```
EOF

echo "Setup complete! Project is located in: $(pwd)/$PROJECT_DIR"