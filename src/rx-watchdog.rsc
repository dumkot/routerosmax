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
