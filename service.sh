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
    LOCK_FILE="/dev/.sv_sndasphere/.action_lock"
else
    TMPDIR="$MODPATH/temp"
    DEBUG_DIR="$MODPATH/debug"
    LOCK_FILE="$MODPATH/.action_lock"
fi

# Enable debug logging
mkdir -p "$DEBUG_DIR"
exec 2>"$DEBUG_DIR/service_debug.txt"
set -x

check_mount_restart() {
	local x y
	
	find "$MODPATH" -type f -name "*.xml" -not -path "$MODPATH/original/*" -not -path "$MODPATH/debug/*" | while read -r x; do
		case "$x" in
			"$MODPATH/system/"*)
				y="${x#"$MODPATH/system"}"
			;;
			*)
				y="${x#"$MODPATH"}"
			;;
		esac
		
		if [ -f "$y" ]; then
			if ! cmp -s "$x" "$y"; then
				echo " -- Files $x and $y are different. Flagging for mount. -- "
				touch "$FLAG_FILE"
			else
				echo " -- Files $x and $y are identical. Skip. -- "
			fi
		else
			echo " -- File $y NOT found even in service stage. Check module dependencies. --"
		fi
	done
	
	if [ -f "$FLAG_FILE" ]; then
		rm -f "$FLAG_FILE"
		
		echo " -- Changes detected. Executing action.sh -- "
		. "$MODPATH/action.sh"
		
		pkill -f mediaserver
		pkill -f audioserver
	else
		echo "No new files were mounted. No services restarted."
	fi
}

FLAG_FILE="$DEBUG_DIR/MOUNTED_FLAG"
resetprop audio.safemedia.bypass true

# Run boot-dependent tasks in the background
(
	until [ "$(getprop sys.boot_completed)" = "1" ]; do
		sleep 1
	done
	
	check_mount_restart
	
	rm -f /data/vendor/dolby/*
	
	BIN_PATHS="/vendor/bin/hw /system/bin/hw /odm/bin/hw /system_ext/bin /product/bin"
	
	# shellcheck disable=SC2086
	find $BIN_PATHS -type f \( -name '*dms*' -o -name '*dolby*' \) 2>/dev/null | grep -v "c2@" | while read -r SERV; do
		if [ -s "$SERV" ]; then
			echo " -- restarting legacy service: $SERV -- "
			PID=$(pidof "$(basename "$SERV")")
			if [ -n "$PID" ]; then
				for p in $PID; do
					echo "PID: $p"
					kill "$p"
				done
			fi
		fi
	done
) &

# Launch service watcher
chmod +x "$MODPATH/service_watcher.sh" 2>/dev/null
setsid "$MODPATH/service_watcher.sh" &

# Clean up emergency files if emergency protocol is completed
if [ -f "$MODPATH/.emergencydone" ]; then
	rm -f "$MODPATH/.emergency"
	rm -f "$MODPATH/.emergencydone"
fi