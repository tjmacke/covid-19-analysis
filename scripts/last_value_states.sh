#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0  [ -help ] [ cv-state-data-file ]"

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

awk -F'\t' '{
	if($3 != l_3){
		if(l_3 != "")
			print l_0
	}
	l_3 = $3
	l_0 = $0
}
END {
	if(l_3 != "")
		print l_0
}' $FILE
