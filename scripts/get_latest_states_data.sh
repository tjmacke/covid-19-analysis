#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] (no args)"

if [ -z "$WM_HOME" ] ; then
	LOG ERROR "WM_HOME not define"
	exit 1
fi
WM_BIN=$WM_HOME/bin

TMP_DATA=/tmp/data.$$

URL="https://api.covidtracking.com/v1/states/daily.csv"

# get the historical US states data and convert to tsv
curl -s -S "$URL" | $WM_BIN/csv2tsv
