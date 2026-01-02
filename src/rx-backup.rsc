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
