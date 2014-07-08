#!/bin/sh
# functions, strings and other constants for shell scripts

# for relation between dit unit and speed in words/min
# VVVVV=64, CODEX=60, PARIS=50
SPEEDBASE=50
# default speed [words/minute]
DEFAULTWPM=23
# default priority (ROUTINE)
DEFAULTPRIORITY=42

# timeout [sec] for fetch operations
FETCHTIMEOUT=50

# maximal source polling interval: a bit more than one day
MAXPOLLING=99999
# file for communication with extractor
EXTRACTORFILE=extractor.dat

# set directory for temporary files (only if no usable value)
if test ! -d "$TMPDIR" -o ! -w "$TMPDIR" -o ! -x "$TMPDIR" -o ! -r "$TMPDIR"
then
# if possible, use ramdisk (on Linux)
 if test -d /dev/shm
 then TMPDIR=/dev/shm/ambros
 else TMPDIR=/tmp/ambros
 fi
fi

# directory for text sources
SOURCEDIR=textsources

# configfiles
CHANNELCONFIG=channel.cfg
SOURCECONFIG=source.cfg

# statusfiles
CHANNELSTATUS=status.dat
SOURCESTATUS=status.dat

# initial values for source status file
SOURCEINDEXSTART=100

# function to read config value by name
# arguments: configfile name [separators]
# value in stdout, exit nonzero if error
# if separators are given, will be replaced by SPC in output
# (e.g ',;' will result in returning "a,b;c" as "a b c")
# WARNING: DO NOT USE '`' in values or separators!
configread () {
 local retline retval separators
# check if config file readable, else fail
 test -r "$1" || return 2
# get last line with name (possibly surrounded by whitespace)
# but ignore any line after separator '---'
 retline=`sed -e '/^[ 	]*---/,$d' "$1"|grep -i "^[ 	]*$2[ 	]"|tail -n 1`
# fail if nothing found
 test "$retline" != "" || return 1
# if no separators given, replace ' ' with ' ' ie NOP
 separators=${3:-' '}
# return second word from read line and substitute separators by SPC
 echo $retline | { read _ retval _ ; echo $retval ; } |
  sed -e "s\`[$separators]\` \`g"
}

# function to get current time (epoch) in seconds
nowsec () {
 date +%s
}

