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
