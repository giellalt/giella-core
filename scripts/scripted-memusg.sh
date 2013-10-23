#!/usr/bin/env bash
# memusg -- Measure memory usage of processes
# Usage: memusg COMMAND [ARGS]...
#
# Author: Jaeho Shin <netj@sparcs.org>
# Created: 2010-08-16
#
# Source: https://gist.github.com/526585
#
# Heavily modified to be usable in a scripted and make-d environment
# To use this script to measure the memory consumption of a process
# as part of a makefile, do as follows:
#
# target:
#	process1 &
#	scripted-memusg.sh $(notdir process1) 2> maxmemusage.txt
#
# That is, make sure the process you want to measure is running in the
# background before starting the memory monitoring script.
#
# Argument: process name

set -um

# check input
[ $# -gt 0 ] || { sed -n '2,/^#$/ s/^# //p' <"$0"; exit 1; }

# TODO support more options: peak, footprint, sampling rate, etc.

# Get the PID of the target process. Insert initial space to get all PID's
# in the same "column", irrespective of PID length
pgid=`ps -c | grep $1 | sed -e 's/^/ /' | tr -s " " | cut -d" " -f2`

# detect operating system and prepare measurement
case `uname` in
    Darwin|*BSD|Linux) sizes() { /bin/ps -o rss= $1; } ;;
    *) echo "`uname`: unsupported operating system" >&2; exit 2 ;;
esac

# monitor the memory usage in the background.
peak=0
while sizes=`sizes $pgid`
do
    set -- $sizes
    sample=$((${@/#/+}))
    let peak="sample > peak ? sample : peak"
    sleep 3
done
echo "$peak" >&2
