#!/bin/sh
utc=`date -u +%y-%m-%d,%H:%MZ`
sed -e "s/%QTR%/$utc/g"
