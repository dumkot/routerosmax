#-------------------------------------------------------------------------------
# File: rx-system.rsc
# Description: System Diagnostics (v7 Health)
#-------------------------------------------------------------------------------
:global RxSendTG;
:global RxCmdHealth do={
    :local cpu [/system resource get cpu-load];
    :local mem ([/system resource get free-memory] / 1048576);
    :local temp "N/A";
    :do { :set temp [/system health get [find name="temperature"] value]; } on-error={ :set temp "?" };
    $RxSendTG message="\F0\9F\92\A1 <b>Health Check</b>%0ACPU: $cpu%%0AFree RAM: $mem MB%0ATemp: $temp C";
}
