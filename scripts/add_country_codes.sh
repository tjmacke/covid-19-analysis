#! /bin/bash
#
. ~/etc/funcs.sh

# sort right
LC_ALL=C

U_MSG="usage: $0 [ -help ] [ cv-world-file ]"

if [ -z "$CVA_HOME" ] ; then
	LOG ERROR "CVA_HOME not defiend"
	exit 1
fi
CVA_GEO=$CVA_HOME/geo
CC_DICT=$CVA_GEO/cc_dict.tsv

FILE=

while [ $# -ne 0 ] ; do
	case $1 in
	-help)
		echo "$U_MSG"
		exit 0
		;;
	-*)
		LOG ERROR "unkown option $1"
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

awk -F'\t' 'BEGIN {
	cc_dfile = "'"$CC_DICT"'"
	for(n_lines = n_countries = 0; (getline < cc_dfile) > 0; ){
		n_lines++
		if(n_lines > 1){
			n_countries++
			c_to_cc2[$1] = $2
			c_to_cc3[$1] = $3
		}
	}
	close(cc_dfile)
}
{
	if($3 == "US"){
		$3 = "United States"
		cc2 = "US"
	}else{
		cc2 = c_to_cc2[$3]
		if(cc2 == "")
			cc2 = "."
	}
	printf("%s", $1)
	for(i = 2; i <= NF; i++)
		printf("\t%s", $i)
	printf("\t%s\n", cc2)
}' $FILE
