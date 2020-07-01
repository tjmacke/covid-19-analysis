#! /bin/bash
#
. ~/etc/funcs.sh

if [ -z "$WM_HOME" ] ; then
	LOG ERROR "WM_HOME not defined"
	exit 1
fi

WM_BIN=$WM_HOME/bin

U_MSG="usage: $0 [ -help ] [ pop-data-file ]"

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

$WM_BIN/csv2tsv $FILE	|
	tail -n +3 	|

	awk -F'\t' 'NR == 1 {
		for(i = 1; i <= NF; i++)
			fnames[i] = $i
		pr_hdr = 1
	}
	NR > 1 {
		if(pr_hdr){
			pr_hdr = 0
			printf("country\tcc3\tyear\tpopulation\n")
		}
		l_yr = ""
		for(i = 5; i <= NF; i++){
			if($i != ""){
				pop = $i
				l_yr = fnames[i]
			}		
		}
		if(l_yr != "") 
			printf("%s\t%s\t%s\t%s\n", $1, $2, l_yr, pop)
	}'
