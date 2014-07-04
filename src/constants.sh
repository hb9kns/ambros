#!/bin/sh
# functions, strings and other constants for shell scripts

# for relation between dit unit and speed in words/min
# VVVVV=64, CODEX=60, PARIS=50
SPEEDBASE=50
# default speed [words/minute]
DEFAULTWPM=23

# timeout [sec] for fetch operations
FETCHTIMEOUT=50

# set directory for temporary files (only if no predefined value)
if test "$TMP" = ""
then
# if possible, use ramdisk (on Linux)
 if test -d /dev/shm
 then TMP=/dev/shm
 else TMP=/tmp
 fi
fi

# directory for text sources
SOURCEDIR=textsources

# configfiles
CHANNELCONFIG=config
SOURCECONFIG=config

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
 retline=`grep -i "^[ 	]*$2[ 	]" "$1"|tail -n 1`
# fail if nothing found
 test "$retline" != "" || return 1
# if no separators given, replace ' ' with ' ' ie NOP
 separators=${3:-' '}
# return second word from read line and substitute separators by SPC
 echo $retline | { read _ retval _ ; echo $retval ; } |
  sed -e "s\`[$separators]\` \`g"
}
