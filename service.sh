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

#!/system/bin/sh

# Mode: 1 — Just change the Captive Portal URL, 0 — Completely disable Captive Portal detection
# Addr: 0 — Use the default Google, msftedge — Use the MSFT Edge, cloudflare — Use the Cloudflare
# ---------------------------------------------------------------------------------------------
MCC_MODE=<DUMMY>
MCC_ADDR=<ADDRS>

msftedge='edge.microsoft.com/captiveportal/generate_204'
cloudflare='cp.cloudflare.com/generate_204'
qualcomm='www.qualcomm.cn/generate_204'
kuketz='captiveportal.kuketz.de'

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
    kuketz)
      settings put global captive_portal_http_url "http://${kuketz}"
      settings put global captive_portal_https_url "https://${kuketz}"
    ;;
    *) >/dev/null echo ? ;;
esac

# Disable Captive Portal Detection if it is desired
# -------------------------------------------------
if [ "$MCC_MODE" -eq 0 ]; then
    settings put global captive_portal_server localhost
    settings put global captive_portal_detection_enabled 0
    settings put global captive_portal_mode 0
else
    settings delete global captive_portal_server
    settings delete global captive_portal_detection_enabled
    settings delete global captive_portal_mode
fi

# https://android.stackexchange.com/questions/186993/captive-portal-parameters
exit 0
