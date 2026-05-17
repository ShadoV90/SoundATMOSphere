#!/bin/sh
# shellcheck source=config_loader.sh
. "$MODPATH"/tuning/config_loader.sh

# shellcheck source=xml_edit.sh
. "$MODPATH"/tuning/xml_edit.sh

# Ensure the temporary directory exists (paranoic mode, because config_loader is making it... but still) before generating temp files
TEMP_DIR="$MODPATH/temp"
mkdir -p "$TEMP_DIR"
chmod 0755 "$TEMP_DIR"

PRESET_NAME="balanced"

if [ -z "$DIY" ] || [ ! -f "$DIY" ]; then
	echo " -- Variable DIY or file tuningDIY.txt is missing --"
	exit 1
fi

if [ -z "$i" ] || [ ! -f "$i" ]; then
	echo " -- Target XML file is missing or not defined --"
	exit 1
fi

initialize_all_variables

detect_config "$i"
apply_custom_frequencies "$i"

echo " -- Starting EQ frequencies mapping --"

TEMP_FREQ_FILE=$(mktemp "$TEMP_DIR/dax_freqs.XXXXXX")

# Extract frequencies (Standard config)
sed -n '/<preset.*name="'"$PRESET_NAME"'".*>/,/<\/preset>/ s/.*band_ieq frequency="\([0-9]*\)".*/\1/p' "$i" > "$TEMP_FREQ_FILE"

# Fallback for Samsung-style configs
if [ ! -s "$TEMP_FREQ_FILE" ]; then
	sed -n '/<preset.*id="ieq_'"$PRESET_NAME"'".*>/,/<\/preset>/ s/.*band_ieq frequency="\([0-9]*\)".*/\1/p' "$i" > "$TEMP_FREQ_FILE"
fi

if [ ! -s "$TEMP_FREQ_FILE" ]; then
	echo "-- Cannot find frequencies in $i"
	rm -f "$TEMP_FREQ_FILE"
	exit 1
fi

update_tuning_comments "$DIY" "$TEMP_FREQ_FILE"

set_eq_loops_indexed "h" "$DIY" "$TEMP_FREQ_FILE"
set_eq_loops_indexed "s" "$DIY" "$TEMP_FREQ_FILE"

# Cleanup temporary mapping file
rm -f "$TEMP_FREQ_FILE"

# Apply all modifications
apply_global_media_intelligence_settings "$i"
apply_all_profiles "$i"
apply_ieq_settings "s" "$i"
apply_ieq_settings "h" "$i"
apply_tuning_settings "$i"
apply_volume_boosts "$i"