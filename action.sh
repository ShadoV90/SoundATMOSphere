#!/bin/sh
if [ ! "$MODPATH" ]; then
    MODPATH=${0%/*}
fi

mount -o rw,remount /data
mount -o rw,remount "$MODPATH" 2>/dev/null
if [ ! -d "$MODPATH/debug" ]; then
    mkdir "$MODPATH/debug"
fi
exec 2>"$MODPATH/debug/action_debug.txt"
set -x

# Specify tuningDIY.txt location
DIY="$MODPATH/tuningDIY.txt"

# Specify temporary location
TMPDIR="$MODPATH/temp"

# Remove dolby database
rm -f /data/vendor/dolby/*

trap 'rm -rf "$TMPDIR"' EXIT

rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"
chmod 0755 "$TMPDIR"
sleep 0.5

check() {
    if grep -q "^author=ShadoV90$" "$MODPATH/module.prop" && grep -q "^name=SoundATMOSphere$" "$MODPATH/module.prop"; then
        set -x
    else
        echo " -- Nice try dude... -- "
        exit 1
    fi
}

# Copying original file to temporary folder for edit
OFILES=$(find "$MODPATH/original" -type f -name "*.xml")
FILE_COUNTER=1
printf "%b\n" "$OFILES" | while IFS= read -r FILE; do
    mkdir -p "$(dirname "$FILE" | sed "s|$MODPATH/original|$MODPATH/temp|")"
    cp "$FILE" "$(echo "$FILE" | sed "s|$MODPATH/original|$MODPATH/temp|")"
done

if [ "$IS_FLASHING" = "true" ] && [ -f "$DIY" ]; then
    check
    cp -f "$DIY" -t "$MODPATH"
fi

FILES=$(find "$MODPATH/temp" -type f -name "*.xml")
FILES_TOTAL="$(echo "$OFILES" | wc -w)"
FILE_COUNTER=1

echo " "
echo "-- Files to patch: $FILES_TOTAL --"
echo "-- Proceed --"
sleep 1

printf "%b\n" "$FILES" > "$MODPATH/temp/temp_file_list"
while IFS= read -r i; do
    REL_PATH="${i#"$MODPATH/temp"}"
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
    check
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
done < "$MODPATH/temp/temp_file_list"

[ -z "$IS_FLASHING" ] && IS_FLASHING=false

if [ "$IS_FLASHING" = "false" ]; then
    check
    SVDLB="$(find "$MODPATH" -path "*/dolby/*" -not -path "$MODPATH/original/*" -not -path "$MODPATH/temp/*" -type f \( -name "*dax*.xml" -o -name "*dap*.xml" \))"
    
    # In case of different inode detection, new file must be mounted
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
                INODE_SOURCE=$(stat -c %i "$BINDFILE")
                INODE_TARGET=$(stat -c %i "$TARGET")
                
                if [ "$INODE_SOURCE" -ne "$INODE_TARGET" ]; then
                    echo " -- Different inode detected, forcing umount & mount for $TARGET -- "
                    umount -l "$TARGET" 2>/dev/null
                    mount -o bind "$BINDFILE" "$TARGET"
                fi
            else
                echo " -- Warning: Target $TARGET not found, skipping mount -- "
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
rm -rf "$MODPATH/temp"/*
rmdir "$MODPATH/temp"
if [ "$IS_FLASHING" = "false" ]; then
    exit 0
fi
