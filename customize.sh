#!/bin/sh
SKIPUNZIP=1


ui_print "*******************************"
ui_print "  Magisk Captive Manager (MCM) "
ui_print "*******************************"

ui_print "- Extracting module files"
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2
# --------------------------------------------

# Default permissions
set_perm_recursive $MODPATH 0 0 0755 0644

# Set permissions
set_perm $MODPATH/system/xbin/mcm 0 0 0755

ui_print "  Installation completed!"
ui_print "  You can start it with command: mcm"
