#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] [ -d date ] [ cv-states-files ]"

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
			LOG ERROR "-d requires date (YYYY-MM-DD) argument"
			echo "$U_MSG" 1>&2
			exit 1
		fi
		DATE=$1
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

awk -F'\t' 'NR > 1 {
	if($2 != l_2){
		if(l_2 != ""){
			dd = deaths[n_deaths] - deaths[n_deaths-1]
			t_dd += dd
			printf("%s\t%s\t%d\n", l_1, l_2, dd)
			delete deaths
			n_deaths = 0
		}
	}
	l_1 = $1
	l_2 = $2
	n_deaths++
	deaths[n_deaths] = $7
}
END {
	if(l_2 != ""){
		dd = deaths[n_deaths] - deaths[n_deaths-1]
		t_dd += dd
		printf("%s\t%s\t%d\n", l_1, l_2, dd)
		delete deaths
		n_deaths = 0
		printf("%s\t%s\t%d\n", l_1, "total", t_dd)
	}
}' $FILE		|
sort -t $'\t' -k 3rn,3	|
awk -F'\t' 'NR == 1{
	printf("rank\tdate\tstate\tdeaths\tcumDeaths\tpct\n")
	total = $3+0
	printf(".\t%s\tALL\t%d\t.\t100.0\n", $1, total)
#	printf(".\t%s\t.\t100.0\n", $0)
}
NR > 1 {
	rank++
	cum += $3
	pct = 100.0*cum/total
	printf("%d\t%s\t%s\t%d\t%d\t%5.1f\n", rank, $1, $2, $3, cum, pct) 
}'
