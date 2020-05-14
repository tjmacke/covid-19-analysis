#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] { confirmed | deaths | recovered }"

if [ -z "$CVD_HOME" ] ; then
	LOG ERROR "CVD_HOME not defined"
	exit 1
fi

if [ -z "$WM_HOME" ] ; then
	LOG ERROR "WM_HOME not defined"
	exit 1
fi
WM_BIN=$WM_HOME/bin

CV_DATA=$CVD_HOME/csse_covid_19_data
CV_TSERIES=$CV_DATA/csse_covid_19_time_series

DT=

while [ $# -gt 0 ] ; do
	case $1 in
	-help)
		echo "$U_MSG"
		exit 0
		;;
	-*)
		LOG ERROR "unknonwn option $1"
		echo "$U_MSG" 1>&2
		exit 1
		;;
	*)
		DT=$1
		shift
		break
		;;
	esac
done

if [ $# -ne 0 ] ; then
	LOG ERROR "extra argumets $*"
	echo "$U_MSG" 1>&2
	exit 1
fi

if [ -z "$DT" ] ; then
	LOG ERROR "missing data-type argument"
	echo "$U_MSG" 1>&2
	exit 1
elif [ "$DT" != "confirmed" ] && [ "$DT" != "deaths" ] && [ "$DT" != "recovered" ] ; then
	LOG ERROR "unknown data-type $DT, must confirmed, deaths or recovered"
	exit 1
fi

fname=
$WM_BIN/csv2tsv $CV_TSERIES/time_series_covid19_${DT}_global.csv	|
awk -F'\t' 'NR == 1 {
	for(i = 1; i <= NF; i++)
		hdr[i] = $i
}
NR > 1 {
	for(i = 5; i <= NF; i++)
		printf("%s\t%s\t%s\t%s\t%s\t%d\n", fix_date(hdr[i]), $1 != "" ? $1 : ".", $2, $3, $4, $i)
}
function fix_date(date,   n_ary, ary) {

	n_ary = split(date, ary, "/")
	return sprintf("20%02d-%02d-%02d", ary[3], ary[1], ary[2])
}'
