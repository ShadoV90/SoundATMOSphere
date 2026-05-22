#!/bin/sh
MODPATH=/data/adb/modules/sv_sndasphere

if [ ! -d "$MODPATH" ]; then
	rm -f "$0"
	exit 0
fi

[ ! -d "$MODPATH/debug" ] && mkdir "$MODPATH/debug"

exec 2>"$MODPATH/debug/service.d_debug.txt"
set -x
#locations variables
DDLB=$(find /data/adb/modules -path "*/dolby/*" -not -path "/data/adb/modules/sv_sndasphere/*" -type f \( -name "*dax*.xml" -o -name "*dap*.xml" \))

if [ -f "$MODPATH/.modulemode" ] && [ -z "$DDLB" ];then
	echo "Houston! We have a problem!"
	sed -E -i 's/^description=.*/description=THIS MODULE WILL BE DELETED! DETECTED DOLBY UNINSTALLED!/' "$MODPATH/module.prop"
	touch "$MODPATH/disable"
	touch "$MODPATH/remove"
fi
