#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] cv-states-file"

if [ -z "$CVA_HOME" ] ; then
	LOG ERROR "CVA_HOME not defined"
	exit 1
fi
CVA_SCRIPTS=$CVA_HOME/scripts

FILE=

TMP_DFILE=/tmp/dfile.$$

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

if [ -z "$FILE" ] ; then
	LOG ERROR "missing cv-states-file argument"
	echo "$U_MSG" 1>&2
	exit 
fi

awk -F'\t' 'NR > 1 {
	if($2 != l_2 && l_2 != "")
		exit 0
	print $1
	l_2 = $2
}' $FILE > $TMP_DFILE

for d in $(tail -n +10 $TMP_DFILE) ; do
	$CVA_SCRIPTS/get_dd_states.sh -d $d $FILE |
	awk -F'\t' 'BEGIN {
		pr_date = 1
	}
	NR > 2 {
		if(pr_date){
			pr_date = 0;
			pfx = sprintf("%s", $2)
		}
		sfx = sfx sprintf("\t%s", $3)
		cnt = $5
		pct = $6
		if(pct >= 50.0)
			exit 0
	}
	END {
		if(!pr_date)
			printf("%s\t%s\t%s%s\n", pfx, pct, cnt, sfx)
	}'
done

rm -f $TMP_DFILE
