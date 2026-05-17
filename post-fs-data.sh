#!/bin/sh
MODPATH=${0%/*}
if [ ! -d "$MODPATH/debug" ]; then
mkdir -p "$MODPATH/debug"
fi
exec 2>"$MODPATH/debug/post-fs_debug.txt"
set -x

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
	printf "%b\n" "$DLB" | while IFS= read -r i; do
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
	printf "%b\n" "$DDLB" | while IFS= read -r i; do
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

MOD_ID="sv_sndasphere"
MOD_PATH="/data/adb/modules/$MOD_ID"
MOD_DIR="$MOD_PATH/system"
METAMODULE_SYMLINK="/data/adb/metamodule"

# Initialize log and clear old data
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting bind mount script for $MOD_ID"

# Function to log messages with a timestamp
log_message() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Yield to metamodules
if [ -L "$METAMODULE_SYMLINK" ] || [ -e "$METAMODULE_SYMLINK" ]; then
	log_message "Metamodule detected. Exiting to avoid conflicts."
	exit 0
fi

# Check if module system directory exists
[ ! -d "$MOD_DIR" ] && { log_message "ERROR: $MOD_DIR not found."; exit 1; }

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

# Main bind mount loop
for mod_subdir in "$MOD_DIR"/*; do
	[ -d "$mod_subdir" ] || continue
	
	# Extract base name using parameter expansion (faster than basename)
	logical_base="${mod_subdir##*/}"
	
	# Resolve KernelSU Next physical directory location
	actual_dir="$(realpath "$mod_subdir" 2>/dev/null || echo "$mod_subdir")"
	
	log_message "Scanning $logical_base -> $actual_dir"
	
	# Find and mount files
	find "$actual_dir/" -type f 2>/dev/null | while read -r mod_file; do
		# Extract internal path and reconstruct logical path
		internal_path="${mod_file#"$actual_dir"/}"
		sys_file="$(resolve_target_path "$logical_base/$internal_path")"
		
		if [ -f "$sys_file" ]; then
			if error_msg=$(mount --bind "$mod_file" "$sys_file" 2>&1); then
				log_message "SUCCESS: $sys_file"
			else
				log_message "ERROR: $sys_file ($error_msg)"
			fi
		else
			log_message "WARN: Target file $sys_file does not exist in system."
		fi
	done
done

log_message "Mount script finished."