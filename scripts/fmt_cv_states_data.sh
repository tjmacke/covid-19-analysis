#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] [ daily-states-file ]"

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
	LOG ERROR "extra arguments $*"
	echo "$U_MSG" 1>&2
	exit 1
fi

awk -F'\t' 'NR == 1 {
	for(i = 1; i <= NF; i++)
		ftab[$i] = i
}
NR > 1 {
	printf("%s-%s-%s", substr($(tab["date"]), 1, 4), substr($(tab["date"]), 5, 2), substr($(tab["date"]), 7, 2))
	printf("\t%s\t%s", ".", $(ftab["state"]))
	printf("\t%s\t%s", ".", ".")
	printf("\t%d\t%d\t%d", $(ftab["positive"]), $(ftab["death"]), $(ftab["recovered"]))
	printf("\n")
}' $FILE	|
sort -t $'\t' -k 3,3 -k 1,1
