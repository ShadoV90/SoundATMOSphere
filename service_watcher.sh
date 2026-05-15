#!/bin/sh
MODPATH=${0%/*}
if [ ! -d "$MODPATH/debug" ]; then
	mkdir "$MODPATH/debug"
fi

exec >"$MODPATH/debug/watcher.txt" 2>&1
set -x

# Looking for builtin mode, it's important
[ -f "$MODPATH/.builtinmode" ] && BUILTIN=true || BUILTIN=false

# Assigning variables, by default they are zero
BOOTCOMPLETE=0
DOLBYSERVICE=0
DLBSERV=""

# Fail-safe variables
FAIL_COUNT=0
MAX_FAILS=10

# Checking for boot complete
boottest(){
	timeout1=60
	while [ "$(getprop sys.boot_completed)" != 1 ] && [ $timeout1 -gt 0 ]; do
		sleep 1
		timeout1=$((timeout1-1))
	done
	
	if [ "$timeout1" -eq 0 ]; then
		echo " -- System boot_complete prop wasn't set to 1 -- "
		exit 1
	else
		echo " -- System boot completed - Proceed -- "
		BOOTCOMPLETE=1
	fi
}

# Checking for dolby service files
servicetest(){
	DLBSERV=$(find /*/bin/hw -type f -name '*dms*' -o -name '*dolby*' 2>/dev/null | grep -v "c2@")
	
	if [ -z "$DLBSERV" ]; then
		echo " -- no Dolby service BINARIES found - break operation immediately! -- "
		exit 1
	else
		echo " -- Dolby service binaries found! - Proceed -- "
		DOLBYSERVICE=1
	fi
}

# Launching functions
boottest
servicetest

# Main watcher logic
if [ "$BOOTCOMPLETE" -eq 1 ] && [ "$DOLBYSERVICE" -eq 1 ]; then
	if [ ! -z "$DLBSERV" ]; then
		
		restart_service() {
			srv_path="$1"
			srv_name=$(basename "$srv_path")
			PID_RECHECK=$(pidof "$srv_name")
			
			if [ -z "$PID_RECHECK" ]; then
				echo " -- restarting service: $srv_name -- "
				# Detach process from shell to keep it alive and avoid Rescue Party reboots
				su -c "setsid $srv_path > /dev/null 2>&1 &"
			fi
		}
		
		check_service() {
			for SRV in $DLBSERV; do
				if [ -s "$SRV" ]; then
					SRV_NAME=$(basename "$SRV")
					PID=$(pidof "$SRV_NAME")
					
					if [ -z "$PID" ]; then
						# Service is down, increment fail counter
						FAIL_COUNT=$((FAIL_COUNT + 1))
						
						if [ "$FAIL_COUNT" -ge "$MAX_FAILS" ]; then
							echo " -- CRITICAL: Service failed to start $MAX_FAILS times in a row. Aborting watcher! -- "
							exit 1
						fi
						
						set -x
						echo " -- Service $SRV_NAME seems to be down! (Consecutive fails: $FAIL_COUNT) -- "
						if [ "$BUILTIN" = true ]; then
							sleep 5
						else
							sleep 1
						fi
						restart_service "$SRV" &
						set +x
					else
						# Service is up and running normally, reset the fail counter
						FAIL_COUNT=0
					fi
				fi
			done
		}
		
		set +x
		
		# Main watcher loop
		while true; do
			# Grab the exact line with mWakefulness (stops parsing after first match for efficiency)
			WAKE_STATE=$(dumpsys power 2>/dev/null | grep -m 1 "mWakefulness=")
			
			if [ -z "$WAKE_STATE" ]; then
				# FAIL-SAFE: If dumpsys fails or format changes completely
				# Fall back to a safe 3-second interval and proceed with checking.
				echo "N/A"
				sleep 3
			elif echo "$WAKE_STATE" | grep -q -e "Awake" -e "1"; then
				# Screen is ON
				echo "A"
				sleep 1
			else
				# Screen is OFF (e.g. Asleep (or 0), Dozing (or 3))
				echo "O"
				sleep 10
			fi
			
			# Mutex lock: Wait if action.sh is killing the service for configuration update
			[ -f "$MODPATH/.action_lock" ] && continue
			
			check_service
		done
	fi
fi