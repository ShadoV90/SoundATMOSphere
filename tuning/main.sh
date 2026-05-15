#!/bin/sh
mount -o rw,remount /data

[ -z "$MODPATH" ] && MODPATH=/data/adb/modules/sv_sndasphere

if [ ! -d "$MODPATH/debug" ]; then
	mkdir -p "$MODPATH/debug"
	chmod 0755 "$MODPATH/debug"
fi

exec 2>"$MODPATH/debug/main_or_emergency_debug.txt"
set -x

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

check() {
	if grep -q "^author=ShadoV90$" "$MODPATH/module.prop" && grep -q "^name=SoundATMOSphere$" "$MODPATH/module.prop"; then
		set -x
	else
		echo " -- Nice try dude... -- "
		exit 1
	fi
}

apply_permissions() {
	local orig="$1"
	local target="$2"
	local mod own con log_con ext orig_dir

	mod=$(stat -c %a "$orig" 2>/dev/null || echo "755")
	own=$(stat -c %U:%G "$orig" 2>/dev/null || echo "root:root")

	chmod "$mod" "$target"
	chown "$own" "$target"

	if ! chcon --reference="$orig" "$target" 2>/dev/null; then
		con=$(stat -c %C "$orig" 2>/dev/null)

		if [ -z "$con" ] || [ "$con" = "?" ]; then
			# shellcheck disable=SC2012
			con=$(ls -dZ "$orig" 2>/dev/null | awk '{print $1}')
		fi

		if [ -z "$con" ] || [ "$con" = "?" ]; then
			ext="${target##*.}"
			[ "$ext" = "$target" ] && ext="none"
			orig_dir=$(dirname "$orig")
			
			if [ "$ext" = "none" ]; then
				# shellcheck disable=SC2012
				con=$(ls -Z "$orig_dir" 2>/dev/null | awk '
					!/^d/ && $1 != "?" && $1 != "" {
						c[$1]++; 
						if(c[$1] > max) { max = c[$1]; res = $1 }
					} END { print res }')
			else
				# shellcheck disable=SC2012
				con=$(ls -Z "$orig_dir/"*."$ext" 2>/dev/null | awk '
					$1 != "?" && $1 != "" {
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

		if [ -n "$con" ]; then
			 chcon "$con" "$target"
			 log_con="$con (fallback applied)"
		else
			 log_con="Failed to determine context"
		fi
	else
		# shellcheck disable=SC2012
		log_con=$(ls -dZ "$target" 2>/dev/null | awk '{print $1}')
	fi

	echo " -- Setting permissions for $target -- "
	echo " -- Permissions: $mod -- "
	echo " -- Owner:Group: $own -- "
	echo " -- Selinux Context: $log_con -- "
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

set +x
check
set -x

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
