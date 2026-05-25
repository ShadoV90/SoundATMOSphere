#!/bin/sh
MODPATH=${0%/*}

. "$MODPATH/tuning/utils.sh"

# Dynamically find bin directories in /data/adb/ for any unknown root solutions
ROOT_BINS=$(find /data/adb -maxdepth 2 -type d \( -name "bin" -o -name "magisk" \) 2>/dev/null | tr '\n' ':')
# Exporting reliable PATH combining dynamic root paths and standard system paths
export PATH="${ROOT_BINS}/apex/com.android.runtime/bin:/system/bin:/system/xbin:$PATH"

meta_check

if [ "$META_ACTIVE" = true ]; then
    TMPDIR="/dev/.sv_sndasphere/temp"
    DEBUG_DIR="/data/adb/modules/sv_sndasphere/debug"
else
    TMPDIR="$MODPATH/temp"
    DEBUG_DIR="$MODPATH/debug"
fi

MOD_ID="sv_sndasphere"
MOD_PATH="/data/adb/modules/$MOD_ID"
MOD_DIR="$MOD_PATH/system"

rm -rf "$DEBUG_DIR"
mkdir -p "$TMPDIR" "$DEBUG_DIR"
# Start debug info
exec 2>"$DEBUG_DIR/post-fs_debug.txt"
set -x

# Emergency function (creation hidden file to let script know that recreating whole module is needed)
emergency() {
touch "$MODPATH/.emergency"
}

DDLB=$(find /data/adb/modules -path "*/dolby/*" -not -path "/data/adb/modules/sv_sndasphere/*" -type f \( -name "*dax*.xml" -o -name "*dap*.xml" \))
SVDLB=$(find /data/adb/modules/sv_sndasphere -path "*/dolby/*" -not -path "$MODPATH/original/*" -type f \( -name "*dax*.xml" -o -name "*dap*.xml" \))
DLB=$(find /system /vendor /odm /my* /product -path "*/dolby/*" -type f \( -name "*dax*.xml" -o -name "*dap*.xml" \))

# looking for "mode" file
BLT="$MODPATH/.builtinmode"
MDL="$MODPATH/.modulemode"
if [ -f "$MDL" ];then
MODE=M
elif [ -f "$BLT" ];then
MODE=B
else
MODE=N
fi

# if built-in mode is detected, then check if there is a difference between original file and file copied to "original" folder
if [ "$MODE" = "B" ];then
	[ -n "$DLB" ] && printf "%b\n" "$DLB" | while IFS= read -r i; do
		j="$MODPATH/original/system$i"
		if cmp -s "$i" "$j"; then
			echo "ok"
		else
			[ -f "$j" ] && rm -f "$j"
			for DIR in "$MODPATH"/*; do
				[ -d "$DIR" ] || continue
				dirname="${DIR##*/}"
				case "$dirname" in
					vendor|product|odm|oem|system_ext|my_*|mi_ext)
						rm -rf "$DIR"
						;;
					*)
						;;
				esac
			done
			echo "We have a problem"
			emergency
		fi
	done
fi

# if module mode is detected, then check if there is a difference between original file in base module and file copied to "original" folder
if [ "$MODE" = "M" ];then
	[ -n "$DDLB" ] && printf "%b\n" "$DDLB" | while IFS= read -r i; do
		j="$(echo "$i" | sed "s|/data/adb/modules/[^/]*/|$MODPATH/original/|")"
		if cmp -s "$i" "$j";then
			echo "ok"
		else
			[ -f "$j" ] && rm -f "$j"
			for DIR in "$MODPATH"/*; do
				[ -d "$DIR" ] || continue
				dirname="${DIR##*/}"
				case "$dirname" in
					vendor|product|odm|oem|system_ext|my_*|mi_ext)
						rm -rf "$DIR"
						;;
					*)
						;;
				esac
			done
			echo "We have a problem"
			emergency
		fi
	done
fi

# if no mode file is detected, then disable module to prevent any incompatibilities
if [ "$MODE" = "N" ];then
	echo "We have a problem... no 'mode' file"
	emergency
fi

if [ ! -d "$MODPATH/original" ]; then
	echo "We have a problem. No original or modded file detected! Activate emergency protocol!"
	emergency
fi

if [ -z "$SVDLB" ]; then
	echo "We have a problem. No modded file detected! Activate emergency protocol!"
	emergency
fi

if [ -f "$MODPATH/.emergency" ];then
. "$MODPATH/tuning/main.sh"
fi

if [ "$META_ACTIVE" = true ]; then
	if [ ! -f "$MODPATH/skip_mountify" ] || [ ! -f "$MODPATH/skip_mount" ]; then
		echo "Active metamodule detected. Making mount skip."
		touch "$MODPATH/skip_mountify"
		touch "$MODPATH/skip_mount"
	else
		echo "Active metamodule detected. Skip mount files already exist."
	fi
elif [ -f "$MODPATH/skip_mountify" ] || [ -f "$MODPATH/skip_mount" ]; then
	echo "Metamodule disabled or removed. Cleaning up skip files."
	rm -f "$MODPATH/skip_mountify"
	rm -f "$MODPATH/skip_mount"
fi

# Check if module system directory exists
[ ! -d "$MOD_DIR" ] && { echo "ERROR: $MOD_DIR not found."; exit 1; }

# Function to resolve the real system path, following symlinks
resolve_target_path() {
	local base="/system/$1"
	
	# Extract first directory using parameter expansion (faster than cut)
	case "${1%%/*}" in
		odm|product|vendor|system_ext|oem)
			[ -d "/${1%%/*}" ] && base="/$1"
			;;
	esac
	
	# Resolve symlinks if possible, otherwise return base path
	realpath "$base" 2>/dev/null || echo "$base"
}

SVDLB="$(find "$MODPATH" -path "*/dolby/*" -not -path "$MODPATH/original/*" -not -path "$MODPATH/temp/*" -type f \( -name "*dax*.xml" -o -name "*dap*.xml" \))"



if [ -n "$SVDLB" ]; then
	printf "%b\n" "$SVDLB" | while IFS= read -r BINDFILE; do
		case "$BINDFILE" in
			"$MODPATH/system/"*)
				TARGET="${BINDFILE#"$MODPATH"/system}"
			;;
			*)
				TARGET="${BINDFILE#"$MODPATH"}"
			;;
		esac
		
		if [ -f "$TARGET" ]; then
			if ! nsenter -t 1 -m -- cmp -s "$BINDFILE" "$TARGET"; then
				echo " -- Changes detected for $TARGET -- "
				FILENAME=$(basename "$TARGET")
				MODNAME=$(basename "$MODPATH")
				
				SAFE_TMP="/dev/.${MODNAME}/${FILENAME}"
				mkdir -p "/dev/.${MODNAME}"
				nsenter -t 1 -m -- sh -c "cat '$BINDFILE' > '$SAFE_TMP'"
				
				# Call our robust permission function
				# $TARGET is passed so it maps to $MODPATH/system$TARGET inside
				apply_permissions "$TARGET" "$SAFE_TMP"
				
				nsenter -t 1 -m -- umount -l "$TARGET" 2>/dev/null
				nsenter -t 1 -m -- mount -o bind "$SAFE_TMP" "$TARGET"
				
				echo " -- Injected from: $SAFE_TMP to: $TARGET -- "
			fi
		else
			echo " -- Warning: Target $TARGET not found, skipping -- "
		fi
		
	done
fi

echo "Mount script finished."