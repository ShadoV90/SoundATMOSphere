#!/system/bin/sh
# shellcheck disable=SC2034

SKIPUNZIP=1

# Extracting files into the module directory and service.d
unzip -qjo "$ZIPFILE" 'sv_sndasphere_rmv.sh' -d /data/adb/service.d >&2
unzip -qo "$ZIPFILE" -x 'LICENSE.txt' 'LEGAL_DISCLAIMER.txt' 'customize.sh' 'sv_sndasphere_rmv.sh' 'META-INF/*' '.shellcheckrc' -d "$MODPATH" >&2

# Set permissions for service.d script
chmod 0755 /data/adb/service.d/sv_sndasphere_rmv.sh

# Setting permissions recursively
set_perm_recursive "$MODPATH" 0 0 0755 0644

# Make all shell scripts in module directory and subdirectories executable
find "$MODPATH" -type f -name "*.sh" -exec chmod 0755 {} \;

# Assigning variables with possible paths to tuningDIY.txt
DIY="$MODPATH/tuningDIY.txt"
DIY_PREV="/data/adb/modules/sv_sndasphere/tuningDIY.txt"
DIY_STOR="/storage/emulated/0/tuningDIY.txt"

# If module is reflashed, previous tuning file can be copied to update
# -f flag is used, to be sure that default file will be overwritten
if [ -f "$DIY_PREV" ] && [ -f "$DIY_STOR" ]; then
	if [ "$DIY_PREV" -nt "$DIY_STOR" ]; then
		cp -f "$DIY_PREV" "$DIY"
	else
		cp -f "$DIY_STOR" "$DIY"
	fi
elif [ -f "$DIY_STOR" ]; then
	cp -f "$DIY_STOR" "$DIY"
elif [ -f "$DIY_PREV" ]; then
	cp -f "$DIY_PREV" "$DIY"
fi

# Checking DIY existence
# If there's no DIY file, copy it to module folder
if [ ! -f "$DIY" ]; then
	unzip -qjo "$ZIPFILE" 'tuningDIY.txt' -d "$MODPATH" >&2
	ui_print " *** PLEASE READ *** "
	sleep 1
	ui_print " -- No backup of tuningDIY.txt found -- "
	ui_print " -- Default config file (tuningDIY.txt) is copied to module directory -- "
	ui_print " "
	ui_print " -- NOW MODULE WILL PROCEED WITH DEFAULT VALUES -- "
	sleep 5
fi

export IS_FLASHING=true

# If everything is okay, then proceed with tuning process
if grep -q "^author=ShadoV90$" "$MODPATH/module.prop" && grep -q "^name=SoundATMOSphere$" "$MODPATH/module.prop"; then
	if [ -f "$MODPATH/tuning/main.sh" ]; then
		. "$MODPATH/tuning/main.sh"
	else
		abort "Error: main.sh not found in $MODPATH"
	fi
else
	abort " -- Nice try dude... -- "
fi
