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

echo -e "date\tstate\tcountry\tlat\tlong\tcontirmed\tdeaths\trecovered\tsource\tcc2"

awk -F'\t' 'NR == 1 {
	for(i = 1; i <= NF; i++)
		ftab[$i] = i
}
NR > 1 {
	printf("%s-%s-%s", substr($(tab["date"]), 1, 4), substr($(tab["date"]), 5, 2), substr($(tab["date"]), 7, 2))
	printf("\t%s\t%s", $(ftab["state"]), "United States")
	printf("\t%s\t%s", ".", ".")
	printf("\t%d\t%d\t%d", $(ftab["positive"]), $(ftab["death"]), $(ftab["recovered"]))
	printf("\tstates\tUS")
	printf("\n")
}' $FILE	|
sort -t $'\t' -k 2,2 -k 1,1
