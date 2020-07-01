#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] [ raw-country-code-file ]"

if [ -z "$WM_HOME" ] ; then
	LOG ERROR "WM_HOME not defined"
	exit 1
fi
WM_BIN=$WM_HOME/bin

FILE=

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
		FILE=$1
		shift
		break
		;;
	esac
done

if [ $# -ne 0 ] ; then
	LOG ERROR "exra arguments $*"
	echo "$U_MSG" 1>&2
	exit 1
fi

$WM_BIN/csv2tsv $FILE	|
awk -F'\t' 'NR == 1 {
	for(i = 1; i <= NF; i++)
		ftab[$i] = i
	pr_hdr = 1
}
NR > 1 {
	if(pr_hdr){
		pr_hdr = 0
		printf("%s\t%s\t%s\n", "country", "cc2", "cc3")
	}
	printf("%s", $(ftab["Country"]))
	printf("\t%s", $(ftab["Alpha-2 code"]) != "" ? $(ftab["Alpha-2 code"]) : ".")
	printf("\t%s", $(ftab["Alpha-3 code"]) != "" ? $(ftab["Alpha-3 code"]) : ".")
	printf("\n")
}'
