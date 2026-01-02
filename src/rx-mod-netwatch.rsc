#-------------------------------------------------------------------------------
# File: rx-mod-netwatch.rsc
# Description: Smart Netwatch Notification
#-------------------------------------------------------------------------------
:global RxSendTG;
:global rxConfig;
:local Target ($rxConfig->"netwatchTarget");

:do {
    :if ([:len [/tool netwatch find host=$Target]] = 0) do={
        /tool netwatch add host=$Target interval=1m comment="rx-watchdog" \
            up-script="[:global RxSendTG; \$RxSendTG message=\"\E2\9C\85 <b>Internet UP</b>%0ATarget: $Target\"]" \
            down-script="[:global RxSendTG; \$RxSendTG message=\"\F0\9F\9A\A8 <b>Internet DOWN</b>%0ATarget: $Target\"]"
    }
} on-error={ /log error "Netwatch setup failed" }
