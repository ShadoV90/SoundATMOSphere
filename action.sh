#!/bin/sh
if [ ! "$MODPATH" ]; then
	MODPATH=${0%/*}
fi

. "$MODPATH/tuning/utils.sh"

servicetest() {
	local BIN_PATHS="/vendor/bin/hw /system/bin/hw /odm/bin/hw /system_ext/bin /product/bin"
	
	# shellcheck disable=SC2086
	DLBSERV=$(find $BIN_PATHS -type f \( -name '*dms*' -o -name '*dolby*' \) 2>/dev/null)
	
	if [ -z "$DLBSERV" ]; then
		echo " -- No Dolby service BINARIES found - Watcher have nothing to do in this case. Exiting. -- "
		exit 1
	else
		echo " -- Dolby service binaries found! - Proceed -- "
		DOLBYSERVICE=1
	fi
}

# Dynamically find bin directories in /data/adb/ for any unknown root solutions
ROOT_BINS=$(find /data/adb -maxdepth 2 -type d \( -name "bin" -o -name "magisk" \) 2>/dev/null | tr '\n' ':')
# Exporting reliable PATH combining dynamic root paths and standard system paths
export PATH="${ROOT_BINS}/apex/com.android.runtime/bin:/system/bin:/system/xbin:$PATH"

mount -o rw,remount /data
mount -o rw,remount "$MODPATH" 2>/dev/null

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
exec 2>"$DEBUG_DIR/action_debug.txt"
set -x

# Specify tuningDIY.txt location
DIY="$MODPATH/tuningDIY.txt"

# Remove dolby database
rm -f /data/vendor/dolby/*

trap 'rm -rf "${TMPDIR:?}"' EXIT

rm -rf "${TMPDIR:?}"
mkdir -p "$TMPDIR"
chmod 0755 "$TMPDIR"
touch "$LOCK_FILE"

sleep 0.5

# Copying original file to temporary folder for edit
OFILES=$(find "$MODPATH/original" -type f -name "*.xml")
FILE_COUNTER=1
if [ -n "$OFILES" ]; then
	printf "%b\n" "$OFILES" | while IFS= read -r FILE; do
		[ -z "$FILE" ] && continue
		mkdir -p "$(dirname "$FILE" | sed "s|$MODPATH/original|$TMPDIR|")"
		cp "$FILE" "$(echo "$FILE" | sed "s|$MODPATH/original|$TMPDIR|")"
	done
fi

if [ "$IS_FLASHING" = "true" ] && [ -f "$DIY" ]; then
	check_tamp
	cp -f "$DIY" -t "$MODPATH"
fi

FILES=$(find "$TMPDIR" -type f -name "*.xml")
FILES_TOTAL="$(echo "$OFILES" | wc -l)"
FILE_COUNTER=1

echo " "
echo "-- Files to patch: $FILES_TOTAL --"
echo "-- Proceed --"
sleep 1

if [ -n "$FILES" ]; then
	printf "%b\n" "$FILES" > "$TMPDIR/temp_file_list"
	while IFS= read -r i; do
		[ -z "$i" ] && continue
		REL_PATH="${i#"$TMPDIR"}"
		REL_PATH="${REL_PATH#/}"
		REL_PATH="${REL_PATH#system/}"
		
		TOP_DIR=$(echo "$REL_PATH" | cut -d/ -f1)
		
		if [ -L "$MODPATH/system/$TOP_DIR" ]; then
			TARGET="$MODPATH/$REL_PATH"
		else
			TARGET="$MODPATH/system/$REL_PATH"
		fi
		
		mkdir -p "$(dirname "$TARGET")"
		
		echo " "
		echo " -- Applying tuning to file number: $FILE_COUNTER -- "
		echo " "
		# Applying tuning
		check_tamp
		. "$MODPATH/tuning/main_tuning.sh"
		
		if [ -s "$i" ]; then
			cat "$i" > "$TARGET"
			if [ ! -s "$TARGET" ]; then
				echo " -- Failed to copy to $TARGET (file empty) --"
				cp -f "$i" "$TARGET"
				
				if [ -L "$MODPATH/system/$TOP_DIR" ]; then
					ORIG_CON="/$REL_PATH"
				else
					ORIG_CON="/system/$REL_PATH"
				fi
				
				if [ -e "$ORIG_CON" ]; then
					chcon --reference="$ORIG_CON" "$TARGET"
				fi
				if [ ! -s "$TARGET" ]; then
					echo " -- $TARGET is still empty after fallback copy --"
					exit 1
				fi
			fi
		else
			echo " -- Temporary file $i is empty or missing! --"
			exit 1
		fi
		
		FILE_COUNTER=$((FILE_COUNTER + 1))
	done < "$TMPDIR/temp_file_list"
fi

mount

if [ "$IS_FLASHING" = "false" ]; then
	# Restart Dolby Servicew
	servicetest
	if [ "$DOLBYSERVICE" -eq 1 ]; then
		printf "%b\n" "$DLBSERV" | while IFS= read -r SERV; do
			if [ -s "$SERV" ]; then
				echo " "
				echo " -- restarting service: "
				echo " $SERV "
				PID=$(pidof "$(basename "$SERV")")
				if [ -n "$PID" ];then
					echo "PIDs: $PID"
					# shellcheck disable=SC2086
					kill $PID
					sleep 0.5
				fi
				sleep 0.5
			fi
			sleep 1
		done
	fi
fi
	echo " "
	echo " -- DONE! -- "

# Cleaning
rm -f "$LOCK_FILE"
rm -rf "${TMPDIR:?}"
if [ -d "$MODPATH/temp" ]; then
	rm -rf "$MODPATH/temp"
fi

if [ "$IS_FLASHING" = "false" ]; then
	exit 0
fi
