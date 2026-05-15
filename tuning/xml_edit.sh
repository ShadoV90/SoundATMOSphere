#!/bin/sh
# shellcheck disable=SC2154

# Global flags
samsung=false

# --- SED COMMAND GENERATORS ---

_gen_endpoint_value() {
	# $1 = endpoint_id, $2 = setting_name, $3 = new_value
	echo "/<endpoint_type id=\"$1\">/,/<\/endpoint_type>/ s|$2 value=\"[^\"]*\"|$2 value=\"$3\"|g"
}

_gen_endpoint_no_value() {
	# $1 = endpoint_id, $2 = setting_name, $3 = new_value
	echo "/<endpoint_type id=\"$1\">/,/<\/endpoint_type>/ s|$2=\"[^\"]*\"|$2=\"$3\"|g"
}

_gen_profile_global_value() {
	# $1 = profile_name, $2 = setting_name, $3 = new_value
	echo "/name=\"$1\"/,/<\/profile>/ { /<data>/,/<\/data>/ s|$2 value=\"[^\"]*\"|$2 value=\"$3\"|g; }"
}

_gen_tuning_value() {
	# $1 = endpoint_type, $2 = setting_name, $3 = new_value
	echo "/<tuning .*endpoint_type=\"$1\"/,/<\/tuning>/ s|$2 value=\"[^\"]*\"|$2 value=\"$3\"|g"
}

_gen_tuning_rate_channels_matrix() {
	# $1 = endpoint_type, $2 = setting_name, $3 = new_value
	echo "/<tuning .*endpoint_type=\"$1\"/,/<\/tuning>/ s|$2=\"[^\"]*\"|$2=\"$3\"|g"
}

# --- DETECTION ---

detect_feature() {
	local file="$1"
	local feature_tag="$2"
	if grep -q "$feature_tag" "$file"; then
		return 0
	else
		return 1
	fi
}

detect_config(){
	local file="$1"
	if detect_feature "$file" 'id="default"'; then
		echo " -- Samsung-style config detected - Proceed -- "
		samsung=true
	else
		echo " -- Standard config detected - Proceed -- "
		samsung=false
	fi
}

# --- APPLICATION FUNCTIONS ---
apply_global_media_intelligence_settings() {
	local file="$1"
	local profile
	local sed_script_file

	echo " "
	echo " -- Applying global Media Intelligence settings -- "

	sed_script_file=$(mktemp "$TMPDIR/sed_mi_commands.XXXXXX")

	{
		for profile in "Dynamic" "Movie" "Music"; do
			if grep -q "name=\"$profile\"" "$file"; then
				_gen_profile_global_value "$profile" "mi-dv-leveler-steering-enable" "$dolbymidvlev"
				_gen_profile_global_value "$profile" "mi-ieq-steering-enable" "$dolbymiieq"
				_gen_profile_global_value "$profile" "mi-surround-compressor-steering-enable" "$dolbymisurcomp"
				_gen_profile_global_value "$profile" "mi-adaptive-virtualizer-steering-enable" "$dolbmiadaptvirt"
				_gen_profile_global_value "$profile" "headphone-virtualizer-mode" "$hvirtmod"
				_gen_profile_global_value "$profile" "mi-virtualizer-binaural-steering-enable" "$dolbymivirtbin"
				_gen_profile_global_value "$profile" "mi-dialog-enhancer-steering-enable"  "$dolbymidialenh"
			fi
		done
	} >> "$sed_script_file"

	if [ -s "$sed_script_file" ]; then
		sed -E -i -f "$sed_script_file" "$file"
	fi
	rm -f "$sed_script_file"
}

apply_tuning_settings() {
	local file="$1"
	local frequencies="47 141 234 328 469 656 844 1031 1313 1688 2250 3000 3750 4688 5813 7125 9000 11250 13875 19688"
	local freq
	local low
	local high
	local isolated
	local sed_script_file

	echo " "
	echo " -- Applying endpoint tuning settings -- "

	sed_script_file=$(mktemp "$TMPDIR/sed_tuning_commands.XXXXXX")

	{
		if [ "$headphonetuning" = "true" ]; then
			_gen_tuning_value "headphone" "volume-leveler-compressor-enable" "true"
			_gen_tuning_value "headphone" "bass-mbdrc-enable" "false"
			_gen_tuning_value "headphone" "bass-extraction-enable" "false"
			_gen_tuning_value "headphone" "bass-extraction-cutoff-frequency" "200"
			_gen_tuning_value "headphone" "regulator-speaker-dist-enable" "true"
			_gen_tuning_value "headphone" "regulator-sibilance-suppress-enable" "false"
			_gen_tuning_value "headphone" "regulator-stress-amount" "96,96,96,96"
			_gen_tuning_value "headphone" "regulator-distortion-slope" "16"
			_gen_tuning_value "headphone" "audio-optimizer-enable" "true"
			_gen_tuning_value "headphone" "height-filter-mode" "$hheightfilter"
			_gen_tuning_value "headphone" "virtualizer-front-speaker-angle" "45"
			_gen_tuning_value "headphone" "virtualizer-surround-speaker-angle" "120"
			_gen_tuning_value "headphone" "virtualizer-height-speaker-angle" "30"
			_gen_tuning_value "headphone" "regulator-enable" "$hregulator"
			_gen_tuning_value "headphone" "regulator-overdrive" "$hregoverdrive"
			_gen_tuning_value "headphone" "regulator-timbre-preservation" "$htimbre"

			for freq in $frequencies; do
				low="-192"
				high="0"
				isolated="true"
				echo "/endpoint_type=\"headphone\"/,/<\/tuning>/ s|frequency=\"$freq\" threshold_low=\"[^\"]*\" threshold_high=\"[^\"]*\" isolated_band=\"[^\"]*\"|frequency=\"$freq\" threshold_low=\"$low\" threshold_high=\"$high\" isolated_band=\"$isolated\"|"
			done

			_gen_tuning_rate_channels_matrix "headphone" "tuned_rate" "$htunedrate"
			_gen_tuning_rate_channels_matrix "headphone" "output_channels" "$h_output_channels"

			_gen_tuning_value "headphone" "bass-enhancer-enable" "true"
			_gen_tuning_value "headphone" "bass-enhancer-boost" "$hbassboost"
			_gen_tuning_value "headphone" "bass-enhancer-cutoff-frequency" "$hbasscutoff"
			_gen_tuning_value "headphone" "bass-enhancer-width" "$hbasswidth"
		fi

		if [ "$speakertuning" = "true" ]; then
			_gen_tuning_value "speaker" "volume-leveler-compressor-enable" "true"
			_gen_tuning_value "speaker" "regulator-enable" "true"
			_gen_tuning_value "speaker" "regulator-speaker-dist-enable" "true"
			_gen_tuning_value "speaker" "regulator-sibilance-suppress-enable" "false"
			_gen_tuning_value "speaker" "audio-optimizer-enable" "true"
			_gen_tuning_value "speaker" "regulator-timbre-preservation" "$stimbre"
			_gen_tuning_value "speaker" "speaker-virtualizer-mode" "$svirtmod"
			_gen_tuning_rate_channels_matrix "speaker" "tuned_rate" "$stunedrate"
			_gen_tuning_rate_channels_matrix "speaker" "output_channels" "$s_output_channels"

			if detect_feature "$file" "advanced-speaker-virtualizer-rendering-config"; then
				_gen_tuning_value "speaker" "advanced-speaker-virtualizer-rendering-config" "$sadvirtrend"
			fi
		fi
	} >> "$sed_script_file"

	# Apply tuning Virtual Bass commands directly into the script file
	if [ "$headphonetuning" = "true" ] && [ "$hrenderbass" = "VB" ]; then
		if detect_feature "$file" "virtual-bass-harmgains"; then
			apply_virtual_bass "h" "$sed_script_file"
		fi
	fi

	if [ "$speakertuning" = "true" ]; then
		if [ "$srenderbass" = "VB" ]; then
			if detect_feature "$file" "virtual-bass-harmgains"; then
				apply_virtual_bass "s" "$sed_script_file"
			fi
		fi
	fi

	if [ -s "$sed_script_file" ]; then
		sed -E -i -f "$sed_script_file" "$file"
	fi
	rm -f "$sed_script_file"
}

apply_all_profiles() {
	local file="$1"
	local sed_script_file
	local profile
	local existing_profiles
	local hdialog_setting
	local hvirtualizer_setting
	local sdialog_setting
	local svirtualizer_setting
	local hp_devices="headphone bluetooth other usb remote_submix digital_aux default"
	local endpoint_id

	sed_script_file=$(mktemp "$TMPDIR/sed_profiles.XXXXXX")

	local headphone_vbass_available=false
	local headphone_adv_virt_available=false
	local headphone_virt_dist_available=false
	local headphone_virt_lr_angle_available=false
	local speaker_vbass_available=false
	local speaker_adv_virt_available=false

	local vbass_found=false
	local h_adv_virt_found=false
	local h_dist_found=false
	local h_angle_found=false
	local s_adv_virt_found=false

	eval "$(awk '
		/virtual-bass-process-enable/ { print "vbass_found=true" }
		/advanced-headphone-virtualizer-rendering-config/ { print "h_adv_virt_found=true" }
		/headphone-virtualizer-steerer-source-distance/ { print "h_dist_found=true" }
		/advanced-headphone-virtualizer-lr-angle/ { print "h_angle_found=true" }
		/advanced-speaker-virtualizer-rendering-config/ { print "s_adv_virt_found=true" }
	' "$file" | sort -u)"

	if [ "$headphonetuning" = "true" ]; then
		[ "$vbass_found" = "true" ] && headphone_vbass_available=true
		[ "$h_adv_virt_found" = "true" ] && headphone_adv_virt_available=true
		[ "$h_dist_found" = "true" ] && headphone_virt_dist_available=true
		[ "$h_angle_found" = "true" ] && headphone_virt_lr_angle_available=true
	fi
	if [ "$speakertuning" = "true" ]; then
		[ "$vbass_found" = "true" ] && speaker_vbass_available=true
		[ "$s_adv_virt_found" = "true" ] && speaker_adv_virt_available=true
	fi

	echo " "
	echo " -- Applying profile settings -- "

	existing_profiles=$(grep -E -o 'name="(Dynamic|Movie|Music|Custom)"' "$file" | cut -d'"' -f2 | sort -u)

	{
		for profile in $existing_profiles; do
			echo "/name=\"$profile\"/,/<\/profile>/ {"

			if [ "$headphonetuning" = "true" ]; then
				hdialog_setting="$hdialog2"
				hvirtualizer_setting="$hvirtualizer2"

				if [ "$profile" = "Movie" ]; then
					hdialog_setting="$hdialog1"
					hvirtualizer_setting="$hvirtualizer1"
				fi

				for endpoint_id in $hp_devices; do
					if [ "$hrenderbass" = "VB" ] && [ "$headphone_vbass_available" = "true" ]; then
						_gen_endpoint_value "$endpoint_id" "virtual-bass-process-enable" "true"
						_gen_endpoint_value "$endpoint_id" "bass-enhancer-enable" "true"
					else
						_gen_endpoint_value "$endpoint_id" "virtual-bass-process-enable" "false"
						_gen_endpoint_value "$endpoint_id" "bass-enhancer-enable" "true"
					fi

					_gen_endpoint_value "$endpoint_id" "ieq-enable" "$hieq3"
					if [ "$samsung" = "false" ]; then
						_gen_endpoint_no_value "$endpoint_id" "include ieq_preset" "$hieq1"
						_gen_endpoint_no_value "$endpoint_id" "include preset" "ieq_$hieq2"
					else
						_gen_endpoint_no_value "$endpoint_id" "include preset" "ieq_balanced"
					fi

					_gen_endpoint_value "$endpoint_id" "ieq-amount" "$hieqamount"
					_gen_endpoint_value "$endpoint_id" "dialog-enhancer-enable" "$hdialog_setting"
					_gen_endpoint_value "$endpoint_id" "dialog-enhancer-amount" "$hdeamount"
					_gen_endpoint_value "$endpoint_id" "dialog-enhancer-ducking" "$hdeducking"
					_gen_endpoint_value "$endpoint_id" "virtualizer-enable" "$hvirtualizer_setting"
					_gen_endpoint_value "$endpoint_id" "surround-boost" "$hsurboost"
					_gen_endpoint_value "$endpoint_id" "volmax-boost" "$hlevstr"
					_gen_endpoint_value "$endpoint_id" "volume-leveler-enable" "$hleveler"
					_gen_endpoint_value "$endpoint_id" "volume-leveler-amount" "$hlevamount"
					_gen_endpoint_value "$endpoint_id" "volume-leveler-in-target" "$hlevtargetin"
					_gen_endpoint_value "$endpoint_id" "volume-leveler-out-target" "$hlevtargetout"
					_gen_endpoint_value "$endpoint_id" "peak-value" "512"
					_gen_endpoint_value "$endpoint_id" "hearing-protection-enable" "false"
					_gen_endpoint_value "$endpoint_id" "virtualizer-start-band" "0"
				done

				echo " /<data>/,/<\/data>/ s|surround-decoder-diffuse-relocating-to-front-amount value=\"[^\"]*\"|surround-decoder-diffuse-relocating-to-front-amount value=\"0\"|g;"

				if [ "$headphone_adv_virt_available" = "true" ]; then
					echo " /<data>/,/<\/data>/ s|advanced-headphone-virtualizer-rendering-config value=\"[^\"]*\"|advanced-headphone-virtualizer-rendering-config value=\"$hadvirtrend\"|g;"
				fi
				if [ "$headphone_virt_dist_available" = "true" ]; then
					echo " /<data>/,/<\/data>/ s|headphone-virtualizer-steerer-source-distance value=\"[^\"]*\"|headphone-virtualizer-steerer-source-distance value=\"$hvirtdist\"|g;"
				fi
				if [ "$headphone_virt_lr_angle_available" = "true" ]; then
					echo " /<data>/,/<\/data>/ s|advanced-headphone-virtualizer-lr-angle value=\"[^\"]*\"|advanced-headphone-virtualizer-lr-angle value=\"$hadvirtangle\"|g;"
				fi
			fi

			if [ "$speakertuning" = "true" ]; then
				sdialog_setting="$sdialog2"
				svirtualizer_setting="$svirtualizer2"
				if [ "$profile" = "Movie" ]; then
					sdialog_setting="$sdialog1"
					svirtualizer_setting="$svirtualizer1"
				fi

				if [ "$srenderbass" = "VB" ] && [ "$speaker_vbass_available" = "true" ]; then
					_gen_endpoint_value "speaker" "virtual-bass-process-enable" "true"
					_gen_endpoint_value "speaker" "bass-enhancer-enable" "false"
				else
					_gen_endpoint_value "speaker" "virtual-bass-process-enable" "false"
					_gen_endpoint_value "speaker" "bass-enhancer-enable" "true"
				fi

				_gen_endpoint_value "speaker" "ieq-enable" "$sieq3"
				_gen_endpoint_no_value "speaker" "include ieq_preset" "$sieq1"
				_gen_endpoint_value "speaker" "ieq-amount" "$sieqamount"
				_gen_endpoint_value "speaker" "dialog-enhancer-enable" "$sdialog_setting"
				_gen_endpoint_value "speaker" "dialog-enhancer-amount" "$sdeamount"
				_gen_endpoint_value "speaker" "dialog-enhancer-ducking" "$sdeducking"
				_gen_endpoint_value "speaker" "virtualizer-enable" "$svirtualizer_setting"
				_gen_endpoint_value "speaker" "surround-boost" "$ssurboost"
				_gen_endpoint_value "speaker" "volmax-boost" "$slevstr"
				_gen_endpoint_value "speaker" "volume-leveler-enable" "$sleveler"
				_gen_endpoint_value "speaker" "volume-leveler-amount" "$slevamount"
				_gen_endpoint_value "speaker" "volume-leveler-in-target" "$slevtargetin"
				_gen_endpoint_value "speaker" "volume-leveler-out-target" "$slevtargetout"
				_gen_endpoint_value "speaker" "peak-value" "512"
				_gen_endpoint_value "speaker" "hearing-protection-enable" "false"

				if [ "$speaker_adv_virt_available" = "true" ]; then
					echo " /<data>/,/<\/data>/ s|advanced-speaker-virtualizer-rendering-config value=\"[^\"]*\"|advanced-speaker-virtualizer-rendering-config value=\"$sadvirtrend\"|g;"
				fi
			fi

			echo "}"
		done
	} >> "$sed_script_file"

	if [ -s "$sed_script_file" ]; then
		sed -E -i -f "$sed_script_file" "$file"
		echo " -- Profile settings applied successfully -- "
	else
		echo " -- No profile settings to apply -- "
	fi
	rm -f "$sed_script_file"
}

apply_virtual_bass() {
	local prefix="$1"
	local out_sed_file="$2"
	local endpoint

	[ "$prefix" = "h" ] && endpoint="headphone" || endpoint="speaker"
	echo " -- Applying Virtual Bass for endpoint: $endpoint -- "
	# This time i'm using printf, because "echo may not expand escape sequences"
	{
		printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-mode value=\"[^\"]*\"|virtual-bass-mode value=\"3\"|g"

		if [ "$prefix" = "h" ]; then
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-mix-freqs frequency_low=\"[^\"]*\" frequency_high=\"[^\"]*\"|virtual-bass-mix-freqs frequency_low=\"$hbassharmmixfreqmin\" frequency_high=\"$hbassharmgenfreqmax\"|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-src-freqs frequency_low=\"[^\"]*\" frequency_high=\"[^\"]*\"|virtual-bass-src-freqs frequency_low=\"$hbassharmsrcfreqmin\" frequency_high=\"$hbassharmsrcfreqmax\"|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-overall-gain value=\"[^\"]*\"|virtual-bass-overall-gain value=\"96\"|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-slope-gain value=\"[^\"]*\"|virtual-bass-slope-gain value=\"0\"|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-rolloff-gain value=\"[^\"]*\"|virtual-bass-rolloff-gain value=\"0\"|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-subgains .*|virtual-bass-subgains harmonic_2=\"64\" harmonic_3=\"64\" harmonic_4=\"96\"/>|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-blend-linear-gain value=\"[^\"]*\"|virtual-bass-blend-linear-gain value=\"$((hbasslingain*2))\"|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-mix-frequency value=\"[^\"]*\"|virtual-bass-mix-frequency value=\"$hbassharmmixfreqmin,$hbassharmmixfreqmax\"|g"

			if [ "$hbasscompstrength" -eq 0 ]; then
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-compressor-tuning value=\"[^\"]*\"|virtual-bass-compressor-tuning value=\"0,0,0,0,0,0,0\"|g"
			else
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-compressor-tuning value=\"[^\"]*\"|virtual-bass-compressor-tuning value=\"1,$((hbasscompstrength*16)),-96,96,32,25,50\"|g"
			fi

			# Calculating formula for virtual bass
			# Multiplying by 0 is intentional for testing purposes
			if [ "$hbassharmtype" -eq 1 ]; then
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-harmgains value=\"[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-harmgains value=\"$((hbassharmboost*7)),$((hbassharmboost*25)),$((hbassharmboost*10)),$((hbassharmboost*10))\1\"/>|g"
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-hybgains value=\"[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-hybgains value=\"$((hbasslingain*-15)),$((hbasslingain*-10)),$((hbasslingain*-7)),$((hbasslingain*-5)),$((hbasslingain*-2)),$((hbasslingain*0))\1\"/>|g"
			elif [ "$hbassharmtype" -eq 2 ]; then
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-harmgains value=\"[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-harmgains value=\"$((hbassharmboost*7)),$((hbassharmboost*25)),$((hbassharmboost*40)),$((hbassharmboost*40))\1\"/>|g"
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-hybgains value=\"[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-hybgains value=\"$((hbasslingain*-15)),$((hbasslingain*-10)),$((hbasslingain*-7)),$((hbasslingain*-5)),$((hbasslingain*-2)),$((hbasslingain*0))\1\"/>|g"
			elif [ "$hbassharmtype" -eq 3 ]; then
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-harmgains value=\"[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-harmgains value=\"$((hbassharmboost*7)),$((hbassharmboost*20)),$((hbassharmboost*60)),$((hbassharmboost*80))\1\"/>|g"
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-hybgains value=\"[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-hybgains value=\"$((hbasslingain*-15)),$((hbasslingain*-10)),$((hbasslingain*-7)),$((hbasslingain*-5)),$((hbasslingain*-2)),$((hbasslingain*0))\1\"/>|g"
			elif [ "$hbassharmtype" -eq 4 ]; then
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-harmgains value=\"[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-harmgains value=\"$((hbassharmboost*5)),$((hbassharmboost*20)),$((hbassharmboost*30)),$((hbassharmboost*30))\1\"/>|g"
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-hybgains value=\"[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-hybgains value=\"$((hbasslingain*0)),$((hbasslingain*0)),$((hbasslingain*0)),$((hbasslingain*0)),$((hbasslingain*0)),$((hbasslingain*0))\1\"/>|g"
			fi
		else
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-mix-freqs .*|virtual-bass-mix-freqs frequency_low=\"289\" frequency_high=\"498\"/>|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-src-freqs .*|virtual-bass-src-freqs frequency_low=\"80\" frequency_high=\"150\"/>|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-overall-gain value=\"[^\"]*\"|virtual-bass-overall-gain value=\"-164\"|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-slope-gain value=\"[^\"]*\"|virtual-bass-slope-gain value=\"0\"|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-rolloff-gain value=\"[^\"]*\"|virtual-bass-rolloff-gain value=\"0\"|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-subgains .*|virtual-bass-subgains harmonic_2=\"-16\" harmonic_3=\"-144\" harmonic_4=\"-192\"/>|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-blend-linear-gain .*|virtual-bass-blend-linear-gain value=\"$((sbasslingain*2))\"/>|g"
			printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-mix-frequency .*|virtual-bass-mix-frequency value=\"100,600\"/>|g"
			
			if [ "$sbasscompstrength" -eq 0 ]; then
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-compressor-tuning value=\"[^\"]*\"|virtual-bass-compressor-tuning value=\"0,0,0,0,0,0,0\"|g"
			else
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-compressor-tuning value=\"[^\"]*\"|virtual-bass-compressor-tuning value=\"1,$((sbasscompstrength*36)),-96,96,32,25,50\"|g"
			fi

			if [ "$sbassharmtype" -eq 1 ]; then
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-harmgains value=\"[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-harmgains value=\"$((sbassharmboost*6)),$((sbassharmboost*6)),$((sbassharmboost*6)),$((sbassharmboost*6))\1\"/>|g"
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-hybgains value=\"[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-hybgains value=\"$((sbasslingain*6)),$((sbasslingain*6)),$((sbasslingain*6)),$((sbasslingain*6)),$((sbasslingain*6)),$((sbasslingain*6))\1\"/>|g"
			elif [ "$sbassharmtype" -eq 2 ]; then
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-harmgains value=\"[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-harmgains value=\"$((sbassharmboost*6)),$((sbassharmboost*12)),$((sbassharmboost*12)),$((sbassharmboost*12))\1\"/>|g"
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-hybgains value=\"[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-hybgains value=\"$((sbasslingain*6)),$((sbasslingain*12)),$((sbasslingain*12)),$((sbasslingain*12)),$((sbasslingain*12)),$((sbasslingain*12))\1\"/>|g"
			elif [ "$sbassharmtype" -eq 3 ]; then
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-harmgains value=\"[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-harmgains value=\"$((sbassharmboost*6)),$((sbassharmboost*9)),$((sbassharmboost*12)),$((sbassharmboost*12))\1\"/>|g"
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-hybgains value=\"[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-hybgains value=\"$((sbasslingain*6)),$((sbasslingain*12)),$((sbasslingain*16)),$((sbasslingain*18)),$((sbasslingain*20)),$((sbasslingain*20))\1\"/>|g"
			elif [ "$sbassharmtype" -eq 4 ]; then
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-harmgains value=\"[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-harmgains value=\"$((sbassharmboost*12)),$((sbassharmboost*12)),$((sbassharmboost*12)),$((sbassharmboost*12))\1\"/>|g"
				printf '%s\n' "/endpoint_type=\"$endpoint\"/,/<\/tuning>/s|virtual-bass-hybgains value=\"[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,\"]*([^\"]*)\".*|virtual-bass-hybgains value=\"$((sbasslingain*12)),$((sbasslingain*12)),$((sbasslingain*16)),$((sbasslingain*18)),$((sbasslingain*20)),$((sbasslingain*20))\1\"/>|g"
			fi
		fi
	} >> "$out_sed_file"
}

apply_ieq_settings() {
	local prefix="$1"
	local file="$2"
	local frequencies
	local freq
	local target_val
	local source_preset="balanced"
	local all_targets
	local remaining_targets
	local block
	local new_block
	local insert_point_pattern
	local sed_script_file
	local working_preset
	local endpoint
	local active_ieq
	local tuning_enabled
	local var_prefix
	local display_name
	local target_id
	local active_legacy_ieq

	# Flags
	local apply_custom=false
	local will_modify=false

	# Set variables based on the active endpoint (headphone or speaker)
	if [ "$prefix" = "h" ]; then
		endpoint="headphone"
		target_id=4
		active_ieq="$HIEQ"
		tuning_enabled="$headphonetuning"
		var_prefix="hiet"
		display_name="Headphones"
	else
		endpoint="speaker"
		target_id=5
		active_ieq="$SIEQ"
		tuning_enabled="$speakertuning"
		var_prefix="siet"
		display_name="Speaker"
	fi

	local target_preset="custom_${endpoint}"

	echo " "
	echo " -- Checking IEQ settings -- "

	sed_script_file=$(mktemp "$TMPDIR/sed_ieq_commands.XXXXXX")

	# ==========================================
	# Global (per profile) XML IEQ preset logic
	# ==========================================
	
	# Extract the current endpoint block and check if it natively supports IEQ inclusions
	if ! sed -n "/<endpoint_type id=\"$endpoint\"/,/<\/endpoint_type>/p" "$file" | grep -qE '<include (preset="ieq_|ieq_preset=)'; then
		
		# No IEQ include found inside the endpoint -> It's a legacy XML (global IEQ)
		
		# Find the global active preset (usually at the bottom of the profile)
		active_legacy_ieq=$(grep -o "<include preset=\"ieq_[^\"]*\"" "$file" | head -n 1 | cut -d'"' -f2)
		
		if [ -n "$active_legacy_ieq" ]; then
			echo " -- Legacy XML format detected -- "
			
			local legacy_targets_prefix=""
			local h_apply_legacy=false
			local s_apply_legacy=false
			
			case "$HIEQ" in [Cc]|[Cc][Bb]) h_apply_legacy=true ;; esac
			case "$SIEQ" in [Cc]|[Cc][Dd]) s_apply_legacy=true ;; esac
			
			# Priority: Headphones override Speakers if both are enabled globally
			if [ "$headphonetuning" = "true" ] && [ "$h_apply_legacy" = "true" ]; then
				legacy_targets_prefix="hiet"
				echo " -- Applying Headphone Custom IEQ globally (Legacy Override) -- "
			elif [ "$speakertuning" = "true" ] && [ "$s_apply_legacy" = "true" ]; then
				legacy_targets_prefix="siet"
				echo " -- Applying Speaker Custom IEQ globally (Legacy Override) -- "
			fi

			if [ -n "$legacy_targets_prefix" ]; then
				# Extract frequencies specifically from the active legacy preset
				frequencies=$(sed -n "/<preset.*id=\"$active_legacy_ieq\".*>/,/<\/preset>/ s/.*band_ieq frequency=\"\([0-9]*\)\".*/\1/p" "$file")
				
				{
					for freq in $frequencies; do
						eval "target_val=\$${legacy_targets_prefix}_${freq}"
						echo "/<preset .*id=\"$active_legacy_ieq\"/,/<\/preset>/ s|band_ieq frequency=\"$freq\" target=\"[^\"]*\"|band_ieq frequency=\"$freq\" target=\"$target_val\"|"
					done
				} >> "$sed_script_file"
				
				if [ -s "$sed_script_file" ]; then
					sed -i -f "$sed_script_file" "$file"
				fi
			fi
		fi
		
		# Since it's a legacy XML, we always exit early to prevent modern logic from running
		rm -f "$sed_script_file"
		return 0
	fi

	# ==========================================
	# Local (per device/endpoint) XML IEQ preset logic
	# ==========================================
	
	# Determine what we are modifying and if we need to modify anything at all
	if [ "$tuning_enabled" = "true" ]; then
		if [ "$prefix" = "h" ]; then
			case "$active_ieq" in
			[Cc]) 
				apply_custom=true
				will_modify=true
				;;
			[Cc][Bb]) 
				apply_custom=true
				target_preset="balanced"
				will_modify=true
				;;
			esac
		else
			case "$active_ieq" in
			[Cc]) 
				apply_custom=true
				will_modify=true
				;;
			[Cc][Dd]) 
				apply_custom=true
				target_preset="detailed"
				will_modify=true
				;;
			esac
		fi
	fi

	if [ "$samsung" = "true" ]; then
		case "$active_ieq" in
		[Dd]|[Ww])
			target_preset="balanced"
			will_modify=true
			;;
		esac
	fi

	# Exit early if no modifications are needed
	if [ "$will_modify" = "false" ]; then
		echo " -- No custom preset needed -- "
		rm -f "$sed_script_file"
		return 0
	fi

	# Create target preset ONLY if it doesn't exist yet AND we actually need it
	if ! grep -q "name=\"$target_preset\"" "$file" && ! grep -q "id=\"ieq_$target_preset\"" "$file"; then
		block=$(sed -n "/<preset.*name=\"$source_preset\".*>/,/<\/preset>/p" "$file")

		if [ -n "$block" ]; then
			insert_point_pattern="name=\"$source_preset\""
			new_block=$(echo "$block" | sed "s/name=\"$source_preset\"/name=\"$target_preset\"/; s/id=\"[0-9]*\"/id=\"$target_id\"/")
		else
			block=$(sed -n "/<preset.*id=\"ieq_$source_preset\".*>/,/<\/preset>/p" "$file")

			if [ -n "$block" ]; then
				insert_point_pattern="id=\"ieq_$source_preset\""
				new_block=$(echo "$block" | sed "s/id=\"ieq_$source_preset\"/id=\"ieq_$target_preset\"/; s/id=\"[0-9]*\"/id=\"$target_id\"/")
			else
				echo "Error: Source preset '$source_preset' not found! Cannot create custom preset."
				rm -f "$sed_script_file"
				return 1
			fi
		fi

		echo "$new_block" > "$TMPDIR/ieq_new_preset.tmp"
		sed -i "/<preset.*$insert_point_pattern.*>/,/<\/preset>/ {
			/<\/preset>/r $TMPDIR/ieq_new_preset.tmp
		}" "$file"

		rm "$TMPDIR/ieq_new_preset.tmp"
		echo " -- Custom preset created -- "
	fi

	working_preset="$target_preset"

	# Extract frequencies for the working preset
	frequencies=$(sed -n "/<preset.*name=\"$working_preset\".*>/,/<\/preset>/ s/.*band_ieq frequency=\"\([0-9]*\)\".*/\1/p" "$file")
	if [ -z "$frequencies" ]; then
		frequencies=$(sed -n "/<preset.*id=\"ieq_$working_preset\".*>/,/<\/preset>/ s/.*band_ieq frequency=\"\([0-9]*\)\".*/\1/p" "$file")
	fi

	# Generate sed commands for user custom IEQ targets
	if [ "$apply_custom" = "true" ]; then
		echo " -- Applying $display_name Custom IEQ to '$working_preset' -- "
		{
			for freq in $frequencies; do
				eval "target_val=\$${var_prefix}_${freq}"
				echo "/<preset .*name=\"$working_preset\"/,/<\/preset>/ s|band_ieq frequency=\"$freq\" target=\"[^\"]*\"|band_ieq frequency=\"$freq\" target=\"$target_val\"|"
				echo "/<preset .*id=\"ieq_$working_preset\"/,/<\/preset>/ s|band_ieq frequency=\"$freq\" target=\"[^\"]*\"|band_ieq frequency=\"$freq\" target=\"$target_val\"|"
			done
		} >> "$sed_script_file"
	fi

	# Generate sed commands for Samsung specific predefined targets
	if [ "$samsung" = "true" ]; then
		case "$active_ieq" in
		[Dd]|[Ww])
			echo " -- Applying Samsung IEQ to '$working_preset' -- "
			
			case "$active_ieq" in
			[Dd])
				all_targets="150 142 188 216 189 195 202 199 210 225 230 236 235 235 214 165 112 49 -24 -217"
				;;
			[Ww])
				all_targets="114 146 183 169 170 128 103 90 98 126 127 140 96 85 80 66 38 -32 -132 -275"
				;;
			esac

			remaining_targets="$all_targets"

			{
				for freq in $frequencies; do
					target_val="${remaining_targets%% *}"
					if [ -z "$target_val" ]; then break; fi
					remaining_targets="${remaining_targets#* }"

					echo "/<preset .*name=\"$working_preset\"/,/<\/preset>/ s|band_ieq frequency=\"$freq\" target=\"[^\"]*\"|band_ieq frequency=\"$freq\" target=\"$target_val\"|"
					echo "/<preset .*id=\"ieq_$working_preset\"/,/<\/preset>/ s|band_ieq frequency=\"$freq\" target=\"[^\"]*\"|band_ieq frequency=\"$freq\" target=\"$target_val\"|"
				done
			} >> "$sed_script_file"
			;;
		esac
	fi

	# Apply all accumulated sed commands at once
	if [ -s "$sed_script_file" ]; then
		sed -i -f "$sed_script_file" "$file"
	fi
	rm -f "$sed_script_file"
}

apply_volume_boosts() {
	local file="$1"
	local frequencies
	local freq
	local final_spk_gain
	local spk_hph_eq_val
	local hph_eq_val
	local final_hph_gain
	local hvolleft_gain
	local hvolright_gain
	local ep_type
	local sed_script_file

	sed_script_file=$(mktemp "$TMPDIR/sed_boosts_commands.XXXXXX")

	echo " "
	echo " -- Applying Digital Volume Gains and EQ -- "
	{
		if detect_feature "$file" 'id="default"'; then
			if [ "$speakertuning" = "true" ] && [ "$svolboost" -ne 0 ]; then
				echo "/<endpoint_type id=\"speaker\">/,/<\/endpoint_type>/ s|system-gain value=\"[^\"]*\"|system-gain value=\"$((svolboost))\"|g"
			fi
			if [ "$headphonetuning" = "true" ] && [ "$hvolboost" -ne 0 ]; then
				local final_gain=$((hvolboost + hvolbalance))
				echo "/<endpoint_type id=\"headphone\">/,/<\/endpoint_type>/ s|system-gain value=\"[^\"]*\"|system-gain value=\"$final_gain\"|g"
				echo "/<endpoint_type id=\"bluetooth\">/,/<\/endpoint_type>/ s|system-gain value=\"[^\"]*\"|system-gain value=\"$final_gain\"|g"
				echo "/<endpoint_type id=\"usb\">/,/<\/endpoint_type>/ s|system-gain value=\"[^\"]*\"|system-gain value=\"$final_gain\"|g"
				echo "/<endpoint_type id=\"default\">/,/<\/endpoint_type>/ s|system-gain value=\"[^\"]*\"|system-gain value=\"$final_gain\"|g"
			fi
		else
			if [ "$speakertuning" = "true" ]; then
				echo "/<tuning .*endpoint_type=\"speaker.*\"/,/<\/tuning>/ {"

				awk -F'"' '/<tuning .*endpoint_type="speaker.*"/, /<\/tuning>/ {
					if ($0 ~ "<band_optimizer .*frequency=") {
						f = ""; gl = ""; gr = "";
						for(i=1; i<=NF; i++) {
							if ($i ~ /frequency=$/) f = $(i+1)
							if ($i ~ /gain_left=$/) gl = $(i+1)
							if ($i ~ /gain_right=$/) gr = $(i+1)
						}
						if (f != "" && gl != "" && gr != "") {
							print f, gl, gr
						}
					}
				}' "$file" | while read -r freq gl gr; do
					eval "spk_hph_eq_val=\$seq_${freq}"
					[ -z "$spk_hph_eq_val" ] && spk_hph_eq_val=0
					
					final_spk_gain=$((svolboost + spk_hph_eq_val))

					if [ "$final_spk_gain" -ne 0 ]; then
						new_gl=$((gl + final_spk_gain))
						new_gr=$((gr + final_spk_gain))
						
						echo "s|frequency=\"$freq\" gain_left=\"$gl\" gain_right=\"$gr\"|frequency=\"$freq\" gain_left=\"$new_gl\" gain_right=\"$new_gr\"|g"
					fi
				done

				echo "}"
			fi

			if [ "$headphonetuning" = "true" ]; then
				frequencies=$(sed -E -n '/<tuning .*endpoint_type="headphone"/,/<\/tuning>/p' "$file" | sed -E -n 's/.*frequency="([0-9]*)".*/\1/p' | sort -nu)

				for ep_type in "headphone" "bluetooth"; do
					echo "/<tuning .*endpoint_type=\"$ep_type\"/,/<\/tuning>/ {"

					for freq in $frequencies; do
						eval "hph_eq_val=\$heq_${freq}"
						[ -z "$hph_eq_val" ] && hph_eq_val=0
						final_hph_gain=$((hvolboost + hph_eq_val))

						if [ "$hvolbalance" -gt 0 ]; then
							hvolleft_gain=$(( -1 * hvolbalance ))
							hvolright_gain=0
						elif [ "$hvolbalance" -lt 0 ]; then
							hvolleft_gain=0
							hvolright_gain=$(( 1 * hvolbalance ))
						else
							hvolleft_gain=0
							hvolright_gain=0
						fi

						echo "s|frequency=\"$freq\" gain_left=\"[^\"]*\" gain_right=\"[^\"]*\"|frequency=\"$freq\" gain_left=\"$((final_hph_gain + hvolleft_gain))\" gain_right=\"$((final_hph_gain + hvolright_gain))\"|g"
					done
					echo "}"
				done
			fi
		fi
	} >> "$sed_script_file"

	if [ -s "$sed_script_file" ]; then
		sed -E -i -f "$sed_script_file" "$file"
		echo " -- Volume boosts applied successfully -- "
	fi

	rm -f "$sed_script_file"
}

apply_custom_frequencies() {
	local file="$1"
	local temp_file="${file}.tmp"
	local target_list="47 141 234 328 469 656 844 1031 1313 1688 2250 3000 3750 4688 5813 7125 9000 11250 13875 19688"

	awk -v targets="$target_list" '
	BEGIN {
		count = split(targets, freqs, " ")
		current_idx = 1
	}

	/<ieq-bands/ || /<graphic-equalizer-bands/ || /<audio-optimizer-bands/ || /<regulator-tuning/ {
		current_idx = 1
	}

	/<band_/ && /frequency="[0-9]+"/ {
		if (current_idx <= count) {
			sub(/frequency="[0-9]+"/, "frequency=\"" freqs[current_idx] "\"")
			current_idx++
		}
	}

	{ print $0 }
	' "$file" > "$temp_file"

	if [ -s "$temp_file" ]; then
		mv "$temp_file" "$file"
		echo " -- Custom frequencies applied successfully -- "
	else
		echo " -- Error: Temp file empty, changes aborted -- "
		rm -f "$temp_file"
	fi
}