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
 if test -d /run/shm
 then TMPDIR=/run/shm
 else TMPDIR=/tmp
 fi
 TMPDIR=$TMPDIR/ambros
 mkdir -p $TMPDIR || { echo cannot create tempdir $TMPDIR ; exit 4 ; }
fi

# used by daemons for status reports
STATUSDIR=$TMPDIR/status
mkdir -p $STATUSDIR || { echo cannot create statusdir $STATUSDIR ; exit 4 ; }

# could be part of temp dir, but may be independent (longer lasting)
LOGDIR=/tmp/ambros/log
mkdir -p $LOGDIR || { echo cannot create logdir $LOGDIR ; exit 4 ; }
# logfile generator, argument is log name specification
logfile () {
 local lfile
 lfile=$LOGDIR/$1-`date +%W`.log
 echo "# $lfile  `date '+%c, week %W'`" >> $lfile
 echo $lfile
}
# logging to file=arg1 and to stderr with identification=arg2
logit () {
 local fn id
 fn=$1
 id=$2
 shift 2
 echo `date +%w%H%M` $id : $@ >> $fn
 echo : $id : $@ >&2
}

# directory for text sources
SOURCEDIR=textsources
# suffix for file names
SOURCEFILESUFFIX='.txt'

# configfiles
CHANNELCONFIG=channel.cfg
SOURCECONFIG=source.cfg

# statusfiles
CHANNELSTATUS=status.dat
SOURCESTATUS=status.dat

# initial values for source status file
MININDEX=100
MAXINDEX=99999

# signal to terminate daemons (argument for kill)
SIGDAEMONTERMINATE=HUP
# signal to make daemons restart initialization
SIGDAEMONRESTART=INT
# signal to make daemons re-read files for urgent messages
SIGDAEMONXXX=INT

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

# function for hashing source texts
hashfunction () {
 cksum $1 | { read cfc _
 echo $cfc
 }
}
