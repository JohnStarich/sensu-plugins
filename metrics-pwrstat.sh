#!/bin/bash -e

has_scheme='.*--scheme.*'
after_scheme='(?<=\-\-scheme(=|\s))\s*\S+'

if [[ "$@" =~ $has_scheme ]]; then
	PREFIX="$(echo "$@" | grep -oP $after_scheme)"
else
	PREFIX="$HOSTNAME"
fi

STATUS=$(sudo pwrstat -status)
DATE=$(date +%s)

STATUS=$(echo "$STATUS" | sed -re 's/^\s+//' -e 's/\.+/:/')

function extract_var() {
	local tmp="$@"
	echo "$STATUS" | grep -oP "(?<=$tmp:\s).*"
}

debug_regex='.*--debug.*'

if [[ "$@" =~ $debug_regex ]]; then
	#echo "$STATUS"
	echo "State=$(extract_var State)"
	echo "Power Supply=$(extract_var Power Supply by)"
	echo "Utility Voltage=$(extract_var Utility Voltage | sed 's/\sV//')"
	echo "Output Voltage=$(extract_var Output Voltage | sed 's/\sV//')"
	echo "Battery Capacity (%)=$(extract_var Battery Capacity | sed 's/\s%//')"
	echo "Remaining Runtime (min.)=$(extract_var Remaining Runtime | sed 's/\smin\.//')"
	LOAD=$(extract_var Load)
	echo "Load (W)=$(echo $LOAD | sed 's/\sWatt.*//')"
	echo "Load (%)=$(echo $LOAD | sed -e 's/.*\sWatt(//' -e 's/\s%)//')"
	echo "Line Interaction=$(extract_var Line Interaction)"
	echo "Test Result=$(extract_var Test Result)"
	echo "Last Power Event=$(extract_var Last Power Event)"
fi

function output_var() {
	if [ ! -z $1 ] && [ ! -z $2 ]; then
		echo "$PREFIX.$1 $2 $DATE"
		return 0
	else
		echo 'Two arguments required. Usage: output_var name value'
		return 1
	fi
}

output_var voltage.utility $(extract_var Utility Voltage)
output_var voltage.output $(extract_var Output Voltage)
output_var battery.percent $(extract_var Battery Capacity)
output_var battery.time $(extract_var Remaining Runtime | sed 's/\smin\.//')
LOAD=$(extract_var Load)
output_var load.watts $(echo $LOAD | sed 's/\sWatt.*//')
output_var load.percent $(echo $LOAD | sed -e 's/.*\sWatt(//' -e 's/\s%)//')


