#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] -d date [ geo-prog-file ]"

DATE=
FILE=

while [ $# -gt 0 ] ; do
	case $1 in
	-help)
		echo "$U_MSG"
		exit 0
		;;
	-d)
		shift
		if [ $# -eq 0 ] ; then
			LOG ERROR "-d requries date argument"
			echo "$U_MSG" 1>&2
			exit 1
		fi
		DATE="$1"
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

if [ -z "$DATE" ] ; then
	LOG ERROR "missing -d date argument"
	echo "$U_MSG" 1>&2
	exit 1
fi

awk -F'\t' 'BEGIN {
	date = "'"$DATE"'"
}
NR == 1 {
	for(i = 1; i <= NF; i++)
		cnames[i] = $i
}
NR > 1 && $1 == date {
	printf("date\tmaxDeaths\tdateDeaths\tnTpSts\ttpStsDths\ttpStsDthsPct\tSTUSPS\tstDateDths\n")
	for(i = 7; i <= NF; i++)
		printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%d\n", $1, $2, $3, $4, $5, $6, cnames[i], $i != 0 ? $3 : 0)
	exit 0
}' $FILE
