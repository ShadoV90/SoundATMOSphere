#!/bin/sh
mount -o rw,remount /data

[ -z "$MODPATH" ] && MODPATH=/data/adb/modules/sv_sndasphere

# shellcheck source=./utils.sh
. "$MODPATH/tuning/utils.sh"

install_file() {
	local src_file="$1"
	local rel_path target_path backup_path local_backup
	
	rel_path="${src_file#/data/adb/modules/*/}"
	rel_path="${rel_path#/}"
	rel_path="${rel_path#system/}"

	target_path="$MODPATH/system/$rel_path"
	backup_path="/data/adb/modules/sv_sndasphere/original/system/$rel_path"
	local_backup="$MODPATH/original/system/$rel_path"

	mkdir -p "$(dirname "$target_path")"
	mkdir -p "$(dirname "$local_backup")"

	if [ -f "$backup_path" ]; then
		cp -p "$backup_path" "$local_backup"
		cp -p "$local_backup" "$target_path"
	else
		if [ -s "$src_file" ]; then
			cp -p "$src_file" "$local_backup"
			cp -p "$local_backup" "$target_path"
		fi
	fi
}

perms() {
	echo " "
	echo " -- Setting Permissions --"
	
	local filedir clean_path orig

	find "$MODPATH" \( -path "$MODPATH/original" -o -path "$MODPATH/debug" -o -path "$MODPATH/tuning" -o -path "$MODPATH/temp" \) -prune -o -type f -print | while IFS= read -r filedir; do
		if [ "$filedir" = "$MODPATH" ]; then
			continue
		fi
		
		clean_path="${filedir#"$MODPATH/system"}"

		if [ "$clean_path" = "$filedir" ]; then
			clean_path="${filedir#"$MODPATH"}"
		fi

		case "$clean_path" in
			/vendor*|/odm*|/product*|/system_ext*|/oem*|/data*)
				orig="$clean_path"
				;;
			*)
				orig="/system$clean_path"
				;;
		esac
		
		if [ -e "$orig" ]; then
			apply_permissions "$orig" "$filedir"
		fi
	done
}

modulemode() {
	echo " -- Dolby config file in module detected! -- "
	sleep 0.75
	echo " -- Proceed with Module mode -- "
	echo " "
	sleep 0.5
	echo " -- It may take some seconds. Please wait. -- "
	echo " "

	export builtinmode=false

	if [ -n "$DDLB" ]; then
		printf "%b\n" "$DDLB" | while IFS= read -r found_file; do
			install_file "$found_file"
		done
		touch "$MODPATH/.modulemode"
	fi
}

builtinmode() {
	echo " -- Dolby integrated in ROM detected! -- "
	sleep 0.75
	echo " -- Proceed with ROM integrated mode -- "
	echo " "
	sleep 0.5
	echo " -- It may take some seconds. Please wait. -- "
	echo " "

	export builtinmode=true

	if [ -n "$DLB" ]; then
		printf "%b\n" "$DLB" | while IFS= read -r found_file; do
			install_file "$found_file"
		done
		touch "$MODPATH/.builtinmode"
	fi
}

meta_check

if [ "$META_ACTIVE" = true ]; then
    TMPDIR="/dev/.sv_sndasphere/temp"
	if [ "$IS_FLASHING" = "true" ]; then
		DEBUG_DIR="/data/adb/modules_update/sv_sndasphere/debug"
	else
    	DEBUG_DIR="/data/adb/modules/sv_sndasphere/debug"
	fi
    LOCK_FILE="/dev/.sv_sndasphere/.action_lock"
else
    TMPDIR="$MODPATH/temp"
    DEBUG_DIR="$MODPATH/debug"
    LOCK_FILE="$MODPATH/.action_lock"
fi

mkdir -p "$TMPDIR" "$DEBUG_DIR"
exec 2>"$DEBUG_DIR/main_or_emergency_debug.txt"


for DIR in "$MODPATH/"*; do
	[ -d "$DIR" ] || continue
	dirname="${DIR##*/}"
	case "$dirname" in
		vendor|product|odm|oem|system_ext|my_*|mi_ext)
			mkdir -p "$MODPATH/system"
			mv "$DIR" "$MODPATH/system/"
			;;
	esac
done

echo " -- This module have two modes -- "
sleep 0.75
echo " -- ROM integrated mode and Module mode -- "
sleep 0.75
echo " -- Script will automatically choose proper mode -- "
sleep 0.75
echo " "
echo " -- Detecting active Dolby -- "
echo " "
sleep 1

DDLB=$(find /data/adb/modules -path "*/dolby/*" -not -path "/data/adb/modules/sv_sndasphere/*" -type f \( -name "*dax*.xml" -o -name "*dap*.xml" \))
DLB=$(find /system /vendor /odm /my* /product -path "*/dolby/*" -type f \( -name "*dax*.xml" -o -name "*dap*.xml" \) 2>/dev/null)

if [ -n "$DDLB" ]; then
	modulemode
elif [ -n "$DLB" ]; then
	builtinmode
else
	echo " -- No Dolby found -- "
	sleep 1
	echo " -- ABORT --"
	rm -rf "${MODPATH:?}/"*
	rmdir "$MODPATH"
	exit 1
fi

perms

chmod +x "$MODPATH/action.sh"
# shellcheck source=../action.sh
. "$MODPATH/action.sh"
	
if [ -f "$MODPATH/.emergency" ]; then
	rm -f "$MODPATH/.emergency"
	touch "$MODPATH/.emergencydone"
fi
