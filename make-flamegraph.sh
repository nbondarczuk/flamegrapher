#!/bin/bash

###############################################################################
#
# Script Name: make-flamegraph.sh
#
# Description: Makes a flame graph from perf samples
#
# Args       : 1. Duration of sampling is sec
#              2. Freq of sampling in Hz
#
# Author     : Norbert Bondarczuk norbertxbondarczuk@intel.com
#
###############################################################################

[ -z ${DEBUG+x} ] || set -x

#
# functions
#

function log () {
	TS=$(date +"%Y-%m-%d_%H-%M-%S")
	echo "$TS $$ $1"
}

function failure () {
	TS=$(date +"%Y-%m-%d_%H-%M-%S")
	echo "$TS $$ Failure: $2"
	exit $1
}

function killed_by_sigint () {
	log "Killed by SIGINT, exiting"
	exit
}

#
# traps
#

trap killed_by_sigint SIGINT

#
# main
#

log "Started"

#
# Process options and prepare env with default values of the parameters
#

FG_SAMPLING_TIME_SEC="${1:-60}"
FG_SAMPLING_FREQ_HZ="${2:-500}"
FG_FILE=flamegraph-$(date '+%Y%m%d%H%M%S')

if [ -d /work ]; then
	cd /work
fi

log "Working in: $PWD"

rm -f perf.data perf.data.old out.perf out.stacks out.svg

echo 0 > /proc/sys/kernel/kptr_restrict
log "Set /proc/sys/kernel/kptr_restrict = 0"
msg=$(sysctl kernel.perf_event_paranoid=-1 2>&1)
log "Set sysctl: $msg"

#
# Collect stacks and produce SVG file
#

log "Start perf data collection for: $FG_SAMPLING_TIME_SEC sec"

sudo perf record --call-graph fp -a -g -F $FG_SAMPLING_FREQ_HZ -- sleep $FG_SAMPLING_TIME_SEC >perf.data 2>out.log
rc=$?
if [ $rc -ne 0 ]; then
	cat out.log
	failure 1 "Error, status: $rc"
fi

output=$(cat out.log | tr '\n' ' ')
log "Finshed perf data collection: $output" 

#
# Postprocessing phase
#

log "Start postprocessing"

perf script >out.perf
stackcollapse-perf.pl <out.perf >out.stacks
flamegraph.pl <out.stacks >out.svg
if [ ! -f out.svg ]; then
	failure 2 "Error, SVG file not produced, exiting"
fi

log "Finished postprocessing"

#
# Leave in volume mounted if possible
#

log "The Flame Graph SVG file is: ${FG_FILE}.svg"

if [ -d /flamegraph ]; then
	FG_FILE="/flamegraph/${FG_FILE}"
else
	FG_FILE="./${FG_FILE}"		
fi

mv -f out.svg ${FG_FILE}.svg
mv -f perf.data ${FG_FILE}.data


#
# Clean up
#

rm -f perf.data perf.data.old out.perf out.stacks out.svg out.log

log "Finished"

#
# While in a pod force no restart
#

if [ -d /flamegraph ]; then
		log "Sleeping forever, job done"
		sleep inf
fi
