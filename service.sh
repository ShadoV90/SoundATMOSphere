#!/bin/sh
MODPATH=${0%/*}
if [ ! -d "$MODPATH/debug" ]; then
	mkdir "$MODPATH/debug"
fi
exec 2>"$MODPATH/debug/service_debug.txt"
set -x

check_mount_restart() {
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
				echo " -- Files $x and $y are different. Mounting modded file. -- "
				mount -o bind "$x" "$y" && touch "$FLAG_FILE"
			else
				echo " -- Files $x and $y are identical. Skip. -- "
			fi
		else
			echo " -- File $y NOT found even in service stage. Check module dependencies. --"
		fi
	done
	
	if [ -f "$FLAG_FILE" ]; then
		rm -f "$FLAG_FILE"
		pkill -f mediaserver
		pkill -f audioserver
	else
		echo "No new files were mounted. No services restarted."
	fi
}

FLAG_FILE="$MODPATH/debug/MOUNTED_FLAG"
resetprop audio.safemedia.bypass true

(
	until [ "$(getprop sys.boot_completed)" = "1" ]; do
		sleep 1
	done
	
	check_mount_restart
	
	rm -f /data/vendor/dolby/*
	
	find /*/bin/hw -type f -name '*dolby*' 2>/dev/null | while read -r SERV; do
		if [ -s "$SERV" ]; then
			echo " -- restarting service: $SERV"
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

# Launching service watcher (file should have it, but just in case, give executive permissions)
chmod +x "$MODPATH/service_watcher.sh" 2>/dev/null
setsid "$MODPATH/service_watcher.sh" &

# If emergency protocol is done, delete all emergency related files
if [ -f "$MODPATH/.emergencydone" ]; then
	rm -f "$MODPATH/.emergency"
	rm -f "$MODPATH/.emergencydone"
fi
