#!/bin/sh
if [ ! "$MODPATH" ]; then
	MODPATH=${0%/*}
fi

. "$MODPATH/tuning/utils.sh"

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
printf "%b\n" "$OFILES" | while IFS= read -r FILE; do
	mkdir -p "$(dirname "$FILE" | sed "s|$MODPATH/original|$TMPDIR|")"
	cp "$FILE" "$(echo "$FILE" | sed "s|$MODPATH/original|$TMPDIR|")"
done

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

printf "%b\n" "$FILES" > "$TMPDIR/temp_file_list"
while IFS= read -r i; do
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

[ -z "$IS_FLASHING" ] && IS_FLASHING=false

if [ "$IS_FLASHING" = "false" ]; then
	check_tamp
	SVDLB="$(find "$MODPATH" -path "*/dolby/*" -not -path "$MODPATH/original/*" -not -path "$TMPDIR/*" -type f \( -name "*dax*.xml" -o -name "*dap*.xml" \))"
	
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
	
	# Restart Dolby Service
	DLBSERV=$(find /*/bin/hw -type f -name '*dms*' -o -name '*dolby*' 2>/dev/null | grep -v "c2@")
	if [ -n "$DLBSERV" ]; then
		printf "%b\n" "$DLBSERV" | while IFS= read -r SERV; do
			if [ -s "$SERV" ]; then
				echo " "
				echo " -- restarting service: "
				echo " $SERV "
				PID=$(pidof "$(basename "$SERV")")
				if [ -n "$PID" ];then
					for p in ${PID};do
						echo "PID: $p"
						su -c "kill $p"
						sleep 0.5
					done
				fi
				sleep 0.5
			fi
			sleep 1
		done
	fi
	
	echo " "
	echo " -- DONE! -- "
fi

# Cleaning
rm -f "$LOCK_FILE"
rm -rf "${TMPDIR:?}"
if [ "$IS_FLASHING" = "false" ]; then
	exit 0
fi
