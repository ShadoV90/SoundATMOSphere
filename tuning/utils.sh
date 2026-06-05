#!/bin/sh

check_tamp() {
	if ! grep -q "^author=ShadoV90$" "$MODPATH/module.prop" && ! grep -q "^name=SoundATMOSphere$" "$MODPATH/module.prop"; then
		echo " -- Nice try dude... -- " >> "$DEBUG_DIR/check_debug.txt"
		exit 1
	fi
}

apply_permissions() {
	local orig="$1"
	local target="$2"
	local mod own con log_con ext orig_dir
	
	mod=$(stat -c %a "$orig" 2>/dev/null || echo "644")
	own=$(stat -c %U:%G "$orig" 2>/dev/null || echo "root:root")

	nsenter -t 1 -m -- chmod "$mod" "$target"
	nsenter -t 1 -m -- chown "$own" "$target"
	check_tamp > /dev/null 2>&1
	
	# shellcheck disable=SC2012
	con=$(ls -dZ "$orig" 2>/dev/null | awk '{print $1}')
	
	# Validate if the output actually looks like a SELinux context
	case "$con" in
		*:*) ;;
		*) con="?" ;;
	esac

	if [ -z "$con" ] || [ "$con" = "?" ]; then
		ext="${target##*.}"
		[ "$ext" = "$target" ] && ext="none"
		orig_dir=$(dirname "$orig")
		
		if [ "$ext" = "none" ]; then
			# shellcheck disable=SC2012
			con=$(ls -Z "$orig_dir" 2>/dev/null | awk '
				!/^d/ && $1 != "?" && $1 != "" && $1 ~ /:/ {
					c[$1]++; 
					if(c[$1] > max) { max = c[$1]; res = $1 }
				} END { print res }')
		else
			# shellcheck disable=SC2012
			con=$(ls -Z "$orig_dir/"*."$ext" 2>/dev/null | awk '
				$1 != "?" && $1 != "" && $1 ~ /:/ {
					c[$1]++; 
					if(c[$1] > max) { max = c[$1]; res = $1 }
				} END { print res }')
		fi

		if [ -z "$con" ] || [ "$con" = "?" ]; then 
			case "$orig_dir" in 
				*/system/*) con="u:object_r:system_file:s0" ;; 
				*/vendor/etc/*|*/odm/etc/*) con="u:object_r:vendor_configs_file:s0" ;; 
				*/vendor/*|*/odm/*) con="u:object_r:vendor_file:s0" ;; 
				*) con="u:object_r:system_file:s0" ;; 
			esac
		fi
	fi

	if [ -n "$con" ] && [ "$con" != "?" ]; then
		nsenter -t 1 -m -- chcon "$con" "$target"
		log_con="$con"
	else
		log_con="Failed to determine context"
	fi

	echo " -- Setting permissions for $target -- "
	echo " -- Permissions: $mod -- "
	echo " -- Owner:Group: $own -- "
	echo " -- Selinux Context: $log_con -- "
}

meta_check(){
METAMODULE_SYMLINK="/data/adb/metamodule"
check_tamp > /dev/null 2>&1
if [ -z "$META_ACTIVE" ];then
	META_ACTIVE=false
	
	if [ -L "$METAMODULE_SYMLINK" ] || [ -e "$METAMODULE_SYMLINK" ]; then
		# Resolve symlink to check the actual module directory
		META_DIR=$(readlink -f "$METAMODULE_SYMLINK" 2>/dev/null)
		[ -z "$META_DIR" ] && META_DIR="$METAMODULE_SYMLINK"
		
		# If 'disable' file does NOT exist, the metamodule is truly active
		if [ ! -f "$META_DIR/disable" ]; then
			META_ACTIVE=true
		fi
	fi
fi
}

mount() {
	[ -z "$IS_FLASHING" ] && IS_FLASHING=false
	
	MOUNT_DONE=0
	check_tamp > /dev/null 2>&1
	if [ "$IS_FLASHING" = "false" ]; then
		SVDLB="$(find "$MODPATH" -path "*/dolby/*" -not -path "$MODPATH/original/*" -not -path "$TMPDIR/*" -type f \( -name "*dax*.xml" -o -name "*dap*.xml" \))"
		
		if [ -n "$SVDLB" ]; then
			while IFS= read -r BINDFILE; do
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
						cat "$BINDFILE" > "$SAFE_TMP"
						
						# Call our robust permission function
						# $TARGET is passed so it maps to $MODPATH/system$TARGET inside
						apply_permissions "$TARGET" "$SAFE_TMP"
						
						nsenter -t 1 -m -- umount -l "$TARGET" 2>/dev/null
						nsenter -t 1 -m -- mount -o bind "$SAFE_TMP" "$TARGET"
						
						echo " -- Injected from: $SAFE_TMP to: $TARGET -- "
						export MOUNT_DONE=1
					fi
				else
					echo " -- Warning: Target $TARGET not found, skipping -- "
				fi
				
			done <<EOF
$SVDLB
EOF
		fi
	fi
}