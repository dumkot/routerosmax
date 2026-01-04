# Nama Script: rx-system
# Deskripsi: Mengambil data resource router

:global RxSendTG;
:global RxCmdHealth do={
    :local cpu [/system resource get cpu-load];
    :local memTotal ([/system resource get total-memory] / 1048576);
    :local memFree ([/system resource get free-memory] / 1048576);
    :local uptime [/system resource get uptime];
    :local volt "N/A";
    :local temp "N/A";

    # Error handling untuk perangkat yang tidak punya sensor (misal CHR/VM)
    :do { :set volt ([/system health get voltage] / 10); } on-error={}
    :do { :set temp [/system health get temperature]; } on-error={}

    :local msg "System Health\n\nCPU Load: $cpu%\nRAM: $memFree MB / $memTotal MB\nUptime: $uptime\nVolt: $volt V\nTemp: $temp C";
    
    $RxSendTG message=$msg;
}
