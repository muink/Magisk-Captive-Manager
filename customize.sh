# Copyright (C) 2020 Atrate <atrate@protonmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Thanks to Jman420 for these volume input functions
# --------------------------------------------------
keytest() 
{
    ui_print "- Vol Key Test -"
    ui_print "   Press Vol Up:"
    (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > "$TMPDIR"/events) || return 1
    return 0
}

choose() 
{
    #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
    while (true); do
        /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > "$TMPDIR"/events
        if (`cat "$TMPDIR"/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
            break
        fi
    done
    if (`cat "$TMPDIR"/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
        return 1
    else
        return 0
    fi
}

# Check whether using a legacy device
# -----------------------------------
if keytest; then
    FUNC=choose
else
    FUNC=false
    ui_print "   ! Legacy device detected! Setting module to default state (1). You can change it in $MODPATH/service.sh !"
    ui_print "   ! Setting MCC_MODE to 0 will disable CPD completely, while setting it to 1 will change the Google URL to MSFTEdge or Cloudflare!"
    ui_print "   ! Setting MCC_ADDR to 0 will keep the default Google Captive Portal URL, while setting it to 'msftedge' will change the Google URL to MSFTEdge, and setting it to 'cloudflare' will change the Google URL to Cloudflare !"
fi

# Ask user for Captive Portal Detection mode
# ------------------------------------------
ui_print " "
ui_print "--- Select Captive Portal Detection mode ---"
ui_print "  Vol+ = Completely disable CPD            "
ui_print "  Vol- = Change Google URL or Restore URL  "
ui_print " "

if "$FUNC"; then
    MCC_MODE=1
    MCC_ADDR=0
    ui_print "Selected: Change the Captive Portal Detection URL to other than Google or Restore default URL"
else
    MCC_MODE=0
    MCC_ADDR=0
    ui_print "Selected: Completely disable Captive Portal Detection"
fi


if [ "$MCC_MODE" -eq 1 ]; then
# Ask user if wants to restore default
# ------------------------------------
ui_print " "
ui_print "--- Need to restore the default ? ---"
ui_print "  Vol+ = Yes  "
ui_print "  Vol- = No   "
ui_print " "

if "$FUNC"; then
    # Ask user for Captive Portal Detection address
    # ---------------------------------------------
    ui_print " "
    ui_print "--- Select Captive Portal Detection address ---"
    ui_print " "

    for _key in msftedge cloudflare qualcomm kuketz; do
        ui_print " "
        ui_print "  Change to $_key  "
        ui_print "  Vol+ = Yes , Vol- = No  "
        ui_print " "
        if ! "$FUNC"; then
            MCC_ADDR="$_key"
            ui_print "Selected: Change the Captive Portal Detection URL to $_key"
            break
        fi
    done

fi
fi

ui_print " "
ui_print "Writing Captive Portal Detection mode and address to startup script…  "
sed -i "s/<DUMMY>/$MCC_MODE/g; s/<ADDRS>/$MCC_ADDR/g" "$MODPATH/service.sh"

# Just in case, make startup script executable
# --------------------------------------------
chmod 0755 "$MODPATH/service.sh"
