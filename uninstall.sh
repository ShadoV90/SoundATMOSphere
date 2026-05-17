#!/bin/sh
rm -f /data/vendor/dolby/*
rm -f /data/adb/service.d/sv_sndasphere_rmv.sh
# Don't modify anything after this
if [ -f "$INFO" ]; then
	while read -r LINE; do
		case "$LINE" in
			*~)
				continue
				;;
			*)
				if [ -f "$LINE~" ]; then
					 mv -f "$LINE~" "$LINE"
				else
					 rm -f "$LINE"
					 CURRENT_DIR="$(dirname "$LINE")"
					 while [ "$CURRENT_DIR" != "/" ] && [ "$CURRENT_DIR" != "." ]; do
						 if rmdir "$CURRENT_DIR" 2>/dev/null; then
							 CURRENT_DIR="$(dirname "$CURRENT_DIR")"
						 else
							 break
						 fi
					 done
				fi
				;;
		esac
	done < "$INFO"
	rm -f "$INFO"
fi