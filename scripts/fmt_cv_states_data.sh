#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] [ daily-states-file ]"

if [ -z "$WM_HOME" ] ; then
	LOG ERROR "WMHOME not defined"
	exit 1
fi
WM_ETC=$WM_HOME/etc
ST_INFO=$WM_ETC/statefp.tsv

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
sort -t $'\t' -k 1,1 -k 2,2	|
awk -F'\t' 'BEGIN {
	st_info = "'"$ST_INFO"'"
	for(n_line = n_stab = 0; (getline < st_info) > 0; ){
		n_line++
		if(n_line > 1){
			n_stab++
			st_idx[$2] = n_stab
			st_ridx[n_stab] = $2
			stab[n_stab] = ""
		}
	}
	close(st_info)
}
{
	if($1 != l_1){
		if(l_1 != ""){
			for(i = 1; i <= n_stab; i++){
				if(stab[i] != ""){
					printf("%s\n", stab[i])
				}else{
					printf("%s\t%s\t%s\t%s\t%s", l_1, st_ridx[i], "United States", ".", ".")
					printf("\t%d\t%s\t%d", 0, 0, 0)
					printf("\t%s\t%s", "states", "US")
					printf("\n")
				}
				stab[i] = ""
			}
		}
	}
	l_1 = $1
	l_2 = $2
	stab[st_idx[$2]] = $0
}
END {
	if(l_1 != ""){
		for(i = 1; i <= n_stab; i++){
			if(stab[i] != ""){
				printf("%s\n", stab[i])
			}else{
				printf("%s\t%s\t%s\t%s\t%s", l_1, st_ridx[i], "United States", ".", ".")
				printf("\t%d\t%s\t%d", 0, 0, 0)
				printf("\t%s\t%s", "states", "US")
				printf("\n")
			}
			stab[i] = ""
		}
	}
}'	|
sort -t $'\t' -k 2,2 -k 1,1
