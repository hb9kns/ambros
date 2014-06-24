#!/bin/sh
# functions, strings and other constants for shell scripts

# header names
AMBROSPBLPRI=PRIORITY
AMBROSPBLIDX=INDEX
AMBROSPBLDCY=DECAY
AMBROSPBLDUR=DURATION
AMBROSPBLWPM=WPM
AMBROSPBLGEN=GENESIS
AMBROSPBLSRC=SOURCE

# name of congiguration file in channel directory
AMBROSCHANNELCONFIG=.channel.cfg

# function to read config value by name
# arguments: configfile name
# value in stdout, exit nonzero if error
configread () {
 local retline retval
# check if config file readable, else fail
 test -r "$1" || return 2
# get last line with name (possibly surrounded by whitespace)
 retline=`grep -i "^[ 	]*$2[ 	]" "$1"|tail -n 1`
# fail if nothing found
 test "$retline" != "" || return 1
# return second word from read line
 echo $retline | { read _ retval _ ; echo $retval ; }
}
