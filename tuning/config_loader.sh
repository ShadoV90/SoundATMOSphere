#!/bin/sh
# shellcheck disable=SC2154
# shellcheck source=./main_tuning.sh

# Create feature.txt and define state of features in dolby configs
touch "$MODPATH/feature.txt"
chmod 0777 "$MODPATH/feature.txt"

find "$MODPATH" -type f \( -name "*dax*.xml" -o -name "*dap*.xml" \) -exec awk -v feat_file="$MODPATH/feature.txt" '
	/virtual-bass-harmgains/ { harm=1 }
	/headphone-virtualizer-mode/ { hvirt=1 }
	/speaker-virtualizer-mode/ { svirt=1 }
	/advanced-headphone-virtualizer-lr-angle/ { angle=1 }
	/headphone-virtualizer-steerer-source-distance/ { dist=1 }
	/advanced-headphone-virtualizer-rendering-config/ { hadv=1 }
	/advanced-speaker-virtualizer-rendering-config/ { sadv=1 }
	END {
		print "harm=" (harm ? "true" : "false") > feat_file
		print "hvirtmode=" (hvirt ? "true" : "false") >> feat_file
		print "svirtmode=" (svirt ? "true" : "false") >> feat_file
		print "angle=" (angle ? "true" : "false") >> feat_file
		print "distance=" (dist ? "true" : "false") >> feat_file
		print "hadvancedvirt=" (hadv ? "true" : "false") >> feat_file
		print "sadvancedvirt=" (sadv ? "true" : "false") >> feat_file
	}
' {} +
# Source the generated file to set variables in the current shell environment
. "$MODPATH/feature.txt"

# Loading variables from tuningDIY.txt
load_config() {
	local tmpfile
	
	if [ ! -d "$MODPATH"/temp ]; then
		mkdir -p "$MODPATH/temp"
		chmod 0755 "$MODPATH/temp"
	fi
	
	tmpfile="$MODPATH/temp/config_vars_$$.tmp"
	awk -F '=' '
		$1 ~ /^(DOLBYMIDVLEV|DOLBYMIIEQ|DOLBYMISURCOMP|DOLBYMIADAPTVIRT|DOLBYMIVIRTBIN|DOLBYMIDIALENH|HEADPHONETUNING|HIEQ|HIET_[0-9]+|HIEQSTR|HEQ_[0-9]+|HRENDERBASS|HBASSBOOST|HBASSCUTOFF|HBASSWIDTH|HBASSHARMTYPE|HBASSHARMBOOST|HBASSHARMMIXFREQMIN|HBASSHARMMIXFREQMAX|HBASSHARMGENFREQMAX|HBASSHARMSRCFREQMIN|HBASSHARMSRCFREQMAX|HBASSLINGAIN|HBASSCOMPSTRENGTH|HVOLBOOST|HVOLBALANCE|HDE|HDEA|HDED|HVIRTUALIZER|HVIRTDIST|HSURBOOST|HADVIRTANGLE|HVIRTMOD|HADVIRTREND|HHEIGHTFILTER|HLEVELER|HLEVSTR|HLEVAMOUNT|HLEVTARGETIN|HLEVTARGETOUT|HREGULATOR|HREGOVERDRIVE|HTIMBRE|HTUNEDRATE|H_OUTPUT_CHANNELS|SPEAKERTUNING|SIEQ|SIET_[0-9]+|SIEQSTR|SEQ_[0-9]+|SRENDERBASS|SBASSBOOST|SBASSHARMTYPE|SBASSHARMBOOST|SBASSLINGAIN|SBASSCOMPSTRENGTH|SVOLBOOST|SDE|SDEA|SDED|SVIRTUALIZER|SSURBOOST|SVIRTMOD|SADVIRTREND|SLEVELER|SLEVSTR|SLEVAMOUNT|SLEVTARGETIN|SLEVTARGETOUT|STIMBRE|STUNEDRATE|S_OUTPUT_CHANNELS)$/ {
			gsub(/[[:space:]]*/, "", $1);
			gsub(/[[:space:]]*/, "", $2);
			if ($2 != "") print $1 "=" $2
		}
	' "$DIY" > "$tmpfile"
	
	if [ -f "$tmpfile" ]; then
		# shellcheck disable=SC1090
		. "$tmpfile"
		rm -f "$tmpfile"
	else
		echo " -- Cannot read DIY file -- " >&2
		exit 1
	fi
}

get_value() {
	local key="$1"
	local default_val="$2"
	local val
	
	eval "val=\"\$$key\""
	if [ -z "$val" ]; then
		echo "$default_val"
	else
		echo "$val"
	fi
}

set_ieq() {
	local prefix="$1"
	local ieq_var
	local ieqstr_var
	local ieq
	local ieq_preset
	local ieq_name
	local ieq_enabled
	local ieqstr
	local endpoint
	
	# Determine context and define endpoint names matching the creation script
	if [ "$prefix" = "h" ]; then
		ieq_var="HIEQ"
		ieqstr_var="HIEQSTR"
		endpoint="headphone"
	else
		ieq_var="SIEQ"
		ieqstr_var="SIEQSTR"
		endpoint="speaker"
	fi
	
	ieq=$(get_value "$ieq_var" "B")
	case "$ieq" in
		[Cc])
			if [ "$prefix" = "h" ]; then
				ieq_preset=4
			else
				ieq_preset=5
			fi
			ieq_name="custom_${endpoint}"
			ieq_enabled="true" 
			;;
		[Dd]) ieq_preset=1; ieq_name="detailed"; ieq_enabled="true" ;;
		[Ww]) ieq_preset=3; ieq_name="warm"; ieq_enabled="true" ;;
		[Nn]) ieq_preset=2; ieq_name="balanced"; ieq_enabled="false" ;;
		*)    ieq_preset=2; ieq_name="balanced"; ieq_enabled="true" ;;
	esac
	
	eval "export ${prefix}ieq1=$ieq_preset"
	eval "export ${prefix}ieq2=$ieq_name"
	eval "export ${prefix}ieq3=$ieq_enabled"
	
	ieqstr=$(get_value "$ieqstr_var" 6)
	eval "export ${prefix}ieqamount=$ieqstr"
}

get_frequency_value() {
	local file="$1"
	local key="$2"
	local default="$3"
	local val

	val=$(grep "^${key}=" "$file" | cut -d'=' -f2 | sed 's/ *#.*//' | sed 's/^[ \t]*//;s/[ \t]*$//')

	if [ -n "$val" ]; then
		echo "$val"
	else
		echo "$default"
	fi
}

update_tuning_comments() {
	local tuning_file="$1"
	local freq_list_file="$2"
	local sed_script_file
	local index=1
	
	if [ ! -s "$freq_list_file" ]; then
		echo " — There is a problem with frequency mapping — "
		return 1
	fi

	sed_script_file=$(mktemp "$TMPDIR/sed_comments.XXXXXX")
	
	while read -r freq; do
		local comment_text="# Frequency: ${freq}Hz"
		local prefixes_to_update="HIET SIET HEQ SEQ"
		local pfx
		
		for pfx in $prefixes_to_update; do
			local key="${pfx}_${index}" 
			
			printf '%s\n' "s/^\(${key}=[^#]*\).*/\1       ${comment_text}/;" >> "$sed_script_file"
		done
		
		index=$((index + 1))
	done < "$freq_list_file"

	if [ -s "$sed_script_file" ]; then
		sed -i -f "$sed_script_file" "$tuning_file"
		echo " -- Frequency bands found in config file, are added as comments in $tuning_file --"
	fi
	
	rm -f "$sed_script_file"
}

set_eq_loops_indexed() {
	local prefix="$1"
	local tuning_file="$2"
	local freq_list_file="$3"

	if [ ! -s "$freq_list_file" ]; then
		echo "ERROR (set_eq_loops_indexed): File with frequency mapping is missing."
		return 1
	fi
	eval "$(awk -v pfx="$prefix" '
		BEGIN { upfx = toupper(pfx) }
		
		# Read frequency list
		NR==FNR { freqs[++fc] = $1; next }
		
		# Parse tuning file variables into dictionary
		{
			if (index($0, "=") > 0) {
				split($0, a, "=")
				key = a[1]
				val = a[2]
				sub(/#.*/, "", val)          # Strip comments
				gsub(/^[ \t]+|[ \t]+$/, "", val) # Trim whitespaces
				dict[key] = val
			}
		}
		
		# End pass: Evaluate logic and generate export commands
		END {
			for (i = 1; i <= fc; i++) {
				f = freqs[i]
				
				# Handle IET settings for all endpoints
				iet_key = upfx "IET_" i
				iet_val = dict[iet_key] + 0 # Force numeric
				if (iet_val >= -500 && iet_val <= 500) {
					p_iet = iet_val
				} else {
					p_iet = 0
				}
				print "export " pfx "iet_" f "=" p_iet

				# Handle EQ settings
				eq_key = upfx "EQ_" i
				eq_val = dict[eq_key] + 0 # Force numeric
				if (eq_val >= -12 && eq_val <= 12) {
					p_eq = int(eq_val * 16)
				} else {
					p_eq = 0
				}
				print "export " pfx "eq_" f "=" p_eq
			}
		}
	' "$freq_list_file" "$tuning_file")"
}

set_bass() {
	local prefix="$1"
	local key_prefix
	local renderbass
	local bassboost
	local basscutoff
	local basswidth
	local bassharmtype
	local bassharmboost
	local basslingain
	local basscompstrength
	local bassharmsrcfreqmin
	local bassharmsrcfreqmax
	local bassharmmixfreqmin
	local bassharmmixfreqmax
	local bassharmgenfreqmax
	
	if [ "$prefix" = "h" ]; then
		key_prefix="H"
	else
		key_prefix="S"
	fi

	renderbass=$(get_value "${key_prefix}RENDERBASS" "VB")
	case "$renderbass" in
		[Bb][Ee]) eval "export ${prefix}renderbass=BE" ;;
		*) eval "export ${prefix}renderbass=VB" ;;
	esac

	bassboost=$(get_value "${key_prefix}BASSBOOST" 6)
	eval "export ${prefix}bassboost=$((bassboost * 32))"

	if [ "$prefix" = "h" ]; then
		basscutoff=$(get_value "HBASSCUTOFF" 90)
		eval "export hbasscutoff=$basscutoff"
		
		basswidth=$(get_value "HBASSWIDTH" 32)
		eval "export hbasswidth=$basswidth"
	fi

	bassharmtype=$(get_value "${key_prefix}BASSHARMTYPE" 3)
	case "$bassharmtype" in
		1|2|4) eval "export ${prefix}bassharmtype=$bassharmtype" ;;
		*) eval "export ${prefix}bassharmtype=3" ;;
	esac
	
	bassharmboost=$(get_value "${key_prefix}BASSHARMBOOST" 6)
	eval "export ${prefix}bassharmboost=$bassharmboost"
	
	basslingain=$(get_value "${key_prefix}BASSLINGAIN" 7)
	eval "export ${prefix}basslingain=$basslingain"

	basscompstrength=$(get_value "${key_prefix}BASSCOMPSTRENGTH" 0)
	eval "export ${prefix}basscompstrength=$basscompstrength"

	if [ "$prefix" = "h" ]; then
		bassharmsrcfreqmin=$(get_value "HBASSHARMSRCFREQMIN" 10)
		export "hbassharmsrcfreqmin=$bassharmsrcfreqmin"
		
		bassharmsrcfreqmax=$(get_value "HBASSHARMSRCFREQMAX" 90)
		export "hbassharmsrcfreqmax=$bassharmsrcfreqmax"
		
		bassharmmixfreqmin=$(get_value "HBASSHARMMIXFREQMIN" 10)
		export "hbassharmmixfreqmin=$bassharmmixfreqmin"
		
		bassharmmixfreqmax=$(get_value "HBASSHARMMIXFREQMAX" 90)
		export "hbassharmmixfreqmax=$bassharmmixfreqmax"

		bassharmgenfreqmax=$(get_value "HBASSHARMGENFREQMAX" 240)
		export "hbassharmgenfreqmax=$bassharmgenfreqmax"
	fi
}

set_volume() {
	local prefix="$1"
	local key_prefix
	local volboost
	local volbalance

	if [ "$prefix" = "h" ]; then
		key_prefix="H"
	else
		key_prefix="S"
	fi
	
	volboost=$(get_value "${key_prefix}VOLBOOST" 0)
	eval "export ${prefix}volboost=$((volboost * 16))"

	volbalance=$(get_value "${key_prefix}VOLBALANCE" 0)
	eval "export ${prefix}volbalance=$((volbalance * 16))"
}

set_dialog() {
	local prefix="$1"
	local key_prefix
	local de
	local dea
	local ded

	if [ "$prefix" = "h" ]; then
		key_prefix="H"
	else
		key_prefix="S"
	fi
	
	de=$(get_value "${key_prefix}DE" 0)
	case "$de" in
		1) eval "export ${prefix}dialog1=true"; eval "export ${prefix}dialog2=false" ;;
		2) eval "export ${prefix}dialog1=true"; eval "export ${prefix}dialog2=true" ;;
		*) eval "export ${prefix}dialog1=false"; eval "export ${prefix}dialog2=false" ;;
	esac
	
	dea=$(get_value "${key_prefix}DEA" 6)
	eval "export ${prefix}deamount=$dea"
	
	ded=$(get_value "${key_prefix}DED" 0)
	eval "export ${prefix}deducking=$ded"
}

set_virtualizer() {
	local prefix="$1"
	local key_prefix
	local virtualizer
	local surboost
	local virtmod
	local advirtrend
	local virtdist
	local advirtangle
	local heightfilter
	
	if [ "$prefix" = "h" ]; then
		key_prefix="H"
	else
		key_prefix="S"
	fi
	
	virtualizer=$(get_value "${key_prefix}VIRTUALIZER" 1)
	case "$virtualizer" in
		0) eval "export ${prefix}virtualizer1=false"; eval "export ${prefix}virtualizer2=false" ;;
		2) eval "export ${prefix}virtualizer1=true"; eval "export ${prefix}virtualizer2=true" ;;
		*) eval "export ${prefix}virtualizer1=true"; eval "export ${prefix}virtualizer2=false" ;;
	esac
	
	surboost=$(get_value "${key_prefix}SURBOOST" 3)
	eval "export ${prefix}surboost=$((surboost * 16))"
	
	virtmod=$(get_value "${key_prefix}VIRTMOD" 2)
	if [ "$virtmod" -eq 1 ]; then
		eval "export ${prefix}virtmod=1"
	else
		eval "export ${prefix}virtmod=2"
	fi
	
	advirtrend=$(get_value "${key_prefix}ADVIRTREND" "360,65535,12288,8192,0,2,3,3")
	case "$advirtrend" in
		[0-9]*,[0-9]*,[0-9]*,[0-9]*,[0-9]*,[0-9]*,[0-9]*,[0-9]*) eval "export ${prefix}advirtrend=$advirtrend" ;;
		*) eval "export ${prefix}advirtrend=360,65535,12288,8192,0,2,3,3" ;;
	esac
	
	if [ "$prefix" = "h" ]; then
		virtdist=$(get_value "HVIRTDIST" 40)
		export "hvirtdist=$virtdist"
		
		advirtangle=$(get_value "HADVIRTANGLE" 90)
		export "hadvirtangle=$advirtangle"
		
		heightfilter=$(get_value "HHEIGHTFILTER" 1)
		export "hheightfilter=$heightfilter"
	fi
}

set_leveler() {
	local prefix="$1"
	local key_prefix
	local leveler
	local levstr
	local levamount
	local levtargetin
	local levtargetout
	
	if [ "$prefix" = "h" ]; then
		key_prefix="H"
	else
		key_prefix="S"
	fi
	
	leveler=$(get_value "${key_prefix}LEVELER" "OFF")
	case "$leveler" in
		[Oo][Nn]) eval "export ${prefix}leveler=true" ;;
		*) eval "export ${prefix}leveler=false" ;;
	esac
	
	levstr=$(get_value "${key_prefix}LEVSTR" 3)
	eval "export ${prefix}levstr=$((levstr * 16))"
	
	levamount=$(get_value "${key_prefix}LEVAMOUNT" 0)
	eval "export ${prefix}levamount=$levamount"
	
	levtargetin=$(get_value "${key_prefix}LEVTARGETIN" 6)
	eval "export ${prefix}levtargetin=$((-320 + (16 * levtargetin)))"
	
	levtargetout=$(get_value "${key_prefix}LEVTARGETOUT" 6)
	eval "export ${prefix}levtargetout=$((-320 + (16 * levtargetout)))"
}

set_regulator_timbre() {
	local prefix="$1"
	local key_prefix
	local timbre
	local regulator
	local regoverdrive
	
	if [ "$prefix" = "h" ]; then
		key_prefix="H"
	else
		key_prefix="S"
	fi
	
	timbre=$(get_value "${key_prefix}TIMBRE" 3)
	eval "export ${prefix}timbre=$((timbre * 4))"
	
	if [ "$prefix" = "h" ]; then
		regulator=$(get_value "HREGULATOR" "ON")
		
		case "$regulator" in
			[Oo][Ff][Ff]) eval "export hregulator=false" ;;
			*) eval "export hregulator=true" ;;
		esac
		
		regoverdrive=$(get_value "HREGOVERDRIVE" 0)
		eval "export hregoverdrive=$((regoverdrive * 48))"
	fi
}

set_tunedrate() {
	local prefix="$1"
	local key_prefix
	local tunedrate
	
	if [ "$prefix" = "h" ]; then
		key_prefix="H"
	else
		key_prefix="S"
	fi
	
	tunedrate=$(get_value "${key_prefix}TUNEDRATE" "48000")
	eval "export ${prefix}tunedrate=$tunedrate"
}

set_output_channels() {
	local prefix="$1"
	local key_prefix
	local output_channels
	
	if [ "$prefix" = "h" ]; then
		key_prefix="H_"
	else
		key_prefix="S_"
	fi
	
	output_channels=$(get_value "${key_prefix}OUTPUT_CHANNELS" "2")
	eval "export ${prefix}_output_channels=$output_channels"
}

set_dolbymi() {
	get_mi_bool() {
		local key="$1"
		local value

		value=$(get_value "$key" "OFF")
		
		case "$value" in
			[Oo][Nn])
				echo "true"
				;;
			*)
				echo "false"
				;;
		esac
	}
	
	dolbymidvlev=$(get_mi_bool "DOLBYMIDVLEV")
	dolbymiieq=$(get_mi_bool "DOLBYMIIEQ")
	dolbymisurcomp=$(get_mi_bool "DOLBYMISURCOMP")
	dolbymiadaptvirt=$(get_mi_bool "DOLBYMIADAPTVIRT")
	dolbymivirtbin=$(get_mi_bool "DOLBYMIVIRTBIN")
	dolbymidialenh=$(get_mi_bool "DOLBYMIDIALENH")
	
	export dolbymidvlev
	export dolbymiieq
	export dolbymisurcomp
	export dolbymiadaptvirt
	export dolbymivirtbin
	export dolbymidialenh
}

initialize_all_variables() {
	echo " -- Loading config from tuningDIY.txt -- "
	
	load_config
	
	set_dolbymi
	
	headphonetuning=$(get_value "HEADPHONETUNING" "YES")
	case "$headphonetuning" in
		[Nn][Oo]) export headphonetuning="false" ;;
		*) export headphonetuning="true" ;;
	esac
	
	speakertuning=$(get_value "SPEAKERTUNING" "YES")
	case "$speakertuning" in
		[Nn][Oo]) export speakertuning="false" ;;
		*) export speakertuning="true" ;;
	esac
	
	echo ""
	echo " -- Dolby Media Intelligence Auto settings: -- "
	echo ""
	echo " -- MI - Volume leveler: $dolbymidvlev -- "
	echo ""
	echo " -- MI - IEQ Steering: $dolbymiieq -- "
	echo ""
	echo " -- MI - Surround Compressor: $dolbymisurcomp -- "
	echo ""
	echo " -- MI - Adaptive Virtualizer: $dolbymiadaptvirt -- "
	echo ""
	echo " -- MI - Virtualizer Binaural Steering: $dolbymivirtbin -- "
	echo ""
	echo " -- MI - Dialog Enhancer: $dolbymidialenh -- "
	echo ""
	echo " -- Headphone Tuning: $headphonetuning -- "
	echo ""
	echo " -- Speaker Tuning: $speakertuning -- "
	echo ""
	echo " -- Processing variables -- "
	echo ""
	
	local prefix
	for prefix in h s; do
		set_ieq "$prefix"
		set_bass "$prefix"
		set_volume "$prefix"
		set_dialog "$prefix"
		set_virtualizer "$prefix"
		set_leveler "$prefix"
		set_regulator_timbre "$prefix"
		set_tunedrate "$prefix"
		set_output_channels "$prefix"
	done
}