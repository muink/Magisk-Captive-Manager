#!/system/bin/sh

# Copyright (C) 2022 muink <hukk1996@gmail.com>
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

if ! $BOOTMODE; then
    ui_print "================================================="
    ui_print "! ERROR: Installation from recovery NOT supported"
    ui_print "! Please use Magisk / KernelSU / APatch app"
    ui_print "================================================="
    abort
fi

# Android < 7.1.1 not supported
[ "$API" -lt 25 ] && abort "❌ Android < 7.1.1 is not supported!"

sleep_pause() {
    # APatch and KernelSU needs this
    # but not KSU_NEXT, MMRL
    if [ -z "$MMRL" ] && [ -z "$KSU_NEXT" ] && { [ "$KSU" = "true" ] || [ "$APATCH" = "true" ]; }; then
        sleep 6
    fi
}

# Startup message
echo ""
cat <<-EOF
  Current captive_portal_mode:       $(settings get global captive_portal_mode)
  Current captive_portal_http_url:   $(settings get global captive_portal_http_url)
  Current captive_portal_https_url:  $(settings get global captive_portal_https_url)
EOF
echo ""

# ======== Init variables ========

# Mode: 1 — Just change the Captive Portal URL, 0 — Completely disable Captive Portal detection
# Addr: 0 — Use the default Google, msftedge — Use the MSFT Edge, cloudflare — Use the Cloudflare
# ---------------------------------------------------------------------------------------------
MCC_MODE=0
MCC_ADDR=0
TMPDIR=/data/local/tmp

msftedge='edge.microsoft.com/captiveportal/generate_204'
cloudflare='cp.cloudflare.com/generate_204'
qualcomm='www.qualcomm.cn/generate_204'
samsung='connectivity.samsung.com.cn/generate_204'
kuketz='captiveportal.kuketz.de'

# ======== Menu ========

keytest()
{
    echo "- Vol Key Test -"
    echo "   Press Vol Up:"
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
    echo "   ! Legacy device detected! Setting module to default state (1). you can change it in line 42, 43"
    echo "   ! Setting MCC_MODE to 0 will disable CPD completely, while setting it to 1 will change the Google URL to MSFTEdge or Cloudflare!"
    echo "   ! Setting MCC_ADDR to 0 will keep the default Google Captive Portal URL, while setting it to 'msftedge' will change the Google URL to MSFTEdge, and setting it to 'cloudflare' will change the Google URL to Cloudflare !"
fi

# Ask user for Captive Portal Detection mode
# ------------------------------------------
echo " "
echo "--- Select Captive Portal Detection mode ---"
echo "  Vol+ = Completely disable CPD            "
echo "  Vol- = Change Google URL or Restore URL  "
echo " "

if "$FUNC"; then
    MCC_MODE=1
    MCC_ADDR=0
    echo "Selected: Change the Captive Portal Detection URL to other than Google or Restore default URL"
else
    MCC_MODE=0
    MCC_ADDR=0
    echo "Selected: Completely disable Captive Portal Detection"
fi


if [ "$MCC_MODE" -eq 1 ]; then
# Ask user if wants to restore default
# ------------------------------------
echo " "
echo "--- Need to restore the default ? ---"
echo "  Vol+ = Yes  "
echo "  Vol- = No   "
echo " "

if "$FUNC"; then
    # Ask user for Captive Portal Detection address
    # ---------------------------------------------
    echo " "
    echo "--- Select Captive Portal Detection address ---"
    echo " "

    for _key in msftedge cloudflare qualcomm samsung kuketz; do
        echo " "
        echo "  Change to $_key  "
        echo "  Vol+ = Yes , Vol- = No  "
        echo " "
        if ! "$FUNC"; then
            MCC_ADDR="$_key"
            echo "Selected: Change the Captive Portal Detection URL to $_key"
            break
        fi
    done

fi
fi

# ======== Setup ========

# Set the Captive Portal URL to other than Google
# -----------------------------------------------
#settings put global captive_portal_http_url "http://"
#settings put global captive_portal_https_url "https://"
#settings put global captive_portal_fallback_url "http://"
#settings put global captive_portal_other_fallback_urls "http://"

case "$MCC_ADDR" in
    0)
      settings delete global captive_portal_http_url
      settings delete global captive_portal_https_url
    ;;
    msftedge)
      settings put global captive_portal_http_url "http://${msftedge}"
      settings put global captive_portal_https_url "https://${msftedge}"
    ;;
    cloudflare)
      settings put global captive_portal_http_url "http://${cloudflare}"
      settings put global captive_portal_https_url "https://${cloudflare}"
    ;;
    qualcomm)
      settings put global captive_portal_http_url "http://${qualcomm}"
      settings put global captive_portal_https_url "https://${qualcomm}"
    ;;
    samsung)
      settings put global captive_portal_http_url "http://${samsung}"
      settings put global captive_portal_https_url "https://${samsung}"
    ;;
    kuketz)
      settings put global captive_portal_http_url "http://${kuketz}"
      settings put global captive_portal_https_url "https://${kuketz}"
    ;;
    *) >/dev/null echo ? ;;
esac

# Disable Captive Portal Detection if it is desired
# -------------------------------------------------
if [ "$MCC_MODE" -eq 0 ]; then
    # Android < 7.1.1
    #    settings put global captive_portal_server localhost
    #    settings put global captive_portal_detection_enabled 0
    settings put global captive_portal_mode 0 # 0: Don’t attempt to detect captive portals; 1: When detecting a captive portal, display a notification that prompts the user to sign in (default); 2: When detecting a captive portal, immediately disconnect from the network and do not reconnect to that network in the future
else
    settings delete global captive_portal_server
    settings delete global captive_portal_detection_enabled
    settings delete global captive_portal_mode
fi

# https://android.stackexchange.com/questions/186993/captive-portal-parameters
echo "🎉 Operation completed successfully!"
sleep_pause
