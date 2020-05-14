#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] (no args)"

if [ -z "$CVD_HOME" ] ; then
	LOG ERROR "CVD_HOME is not defiend"
	exit 1
fi

if [ -z "$CVA_HOME" ] ; then
	LOG ERROR "CVA_HOME is not defined"
	exit 1
fi

if [ -z "$WM_HOME" ] ; then
	LOG ERROR "WM_HOME is not defined"
	exit 1
fi
WM_BIN=$WM_HOME/bin

# This is where I do the covid-19 analysis
CVA_GEO=$CVA_HOME/geo
WORLD_MAP=TM_WORLD_BORDERS-0.3

# This is where I put the git repo; adjust as needed
CV_DATA=$CVD_HOME/csse_covid_19_data
CV_TSERIES=$CV_DATA/csse_covid_19_time_series
UID_TABLE=UID_ISO_FIPS_LookUp_Table

while [ $# -gt 0 ] ; do
	case $1 in
	-help)
		echo "$U_MSG"
		exit 0
		;;
	-*)
		LOG ERROR "unknown option $1"
		echo "$U_MSG" 1>&2
		exit 1
		;;
	*)
		LOG ERROR "extra arguments $*"
		echo "$U_MSG" 1>&2
		exit 1
		;;
	esac
done

pushd $CVA_GEO > /dev/null
$WM_BIN/csv2tsv $CV_DATA/$UID_TABLE.csv > $UID_TABLE.tsv
rm -f $WORLD_MAP.db
$WM_BIN/dbase_to_sqlite -t shapes -pk +rnum -kth . -ktl $UID_TABLE.tsv $WORLD_MAP.dbf | sqlite3 $WORLD_MAP.db
popd > /dev/null
