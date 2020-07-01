#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] -y year [ state-pop-csv-file ]"

if [ -z "$WM_HOME" ] ; then
	LOG ERROR "WM_HOME not defined"
	exit 1
fi
WM_BIN=$WM_HOME/bin
WM_ETC=$WM_HOME/etc

ST_DATA=$WM_ETC/statefp.tsv

YEAR=
FILE=

while [ $# -gt 0 ] ; do
	case $1 in
	-help)
		echo "$U_MSG"
		exit 1
		;;
	-y)
		shift
		if [ $# -eq 0 ] ; then
			LOG ERROR "-y requires year argument"
			echo "$U_MSG" 1>&2
			exit 1
		fi
		YEAR=$1
		shift
		;;
	-*)
		LOG ERROR "unknown option $1"
		echo "$U_MSG" 1>&2
		exit 1
		;;
	*)
		FILE=$1
		shift
		break
		;;
	esac
done

if [ $# -ne 0 ] ; then
	LOG ERROR "extra arguments $*"
	echo "$U_MSG" 1>&2
	exit 1
fi

if [ -z "$YEAR" ] ; then
	LOG ERROR "missing -y year argument"
	echo "$U_MSG" 1>&2
	exit 1
fi

$WM_BIN/csv2tsv $FILE	|
awk -F'\t' '$2 != ""'	|
awk -F'\t' 'BEGIN {
	year = "'"$YEAR"'"
	st_data = "'"$ST_DATA"'"
	for(n_line = n_st2 = 0; (getline < st_data) > 0; ){
		n_line++
		if(n_line > 1){
			n_st2++
			st2[$3] = $2
		}
	}
	close(st_data)
	pr_hdr = 1
}
NR == 1 {
}
NR > 1 {

	if(pr_hdr){
		pr_hdr = 0
		printf("%s\t%s\t%s\t%s\n", "state", "st2", "year", "population")
	}
	printf("%s", $1)
	printf("\t%s", st2[$1])
	printf("\t%s", year)
	gsub(/,/, "", $2)
	printf("\t%s", $2)
	printf("\n")
}'
