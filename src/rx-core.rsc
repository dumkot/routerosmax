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
