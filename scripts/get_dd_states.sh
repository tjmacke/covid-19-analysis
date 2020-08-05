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

awk -F'\t' 'BEGIN {
	date = "'"$DATE"'"
}
NR > 1 {
	if($2 != l_2){
		if(l_2 != ""){
			print_dd(dates, deaths, (date != "" ? date : l_1), l_2)
			delete deaths
			delete dates
			n_dates = 0
		}
	}
	l_1 = $1
	l_2 = $2
	n_dates++
	dates[$1] = n_dates
	deaths[n_dates] = $7
}
END {
	if(l_2 != ""){
		print_dd(dates, deaths, (date != "" ? date : l_1), l_2)
		delete deaths
		delete_dates
		n_dates = 0
	}
}
function print_dd(dates, deaths, date, state,   i, dd) {
	i = dates[date]
	if(i == 1)
		dd = deaths[1]
	else
		dd = deaths[i] - deaths[i-1]
	t_dd += dd
	printf("%s\t%s\t%d\n", date, state, dd)
	return 0
}' $FILE		|
sort -t $'\t' -k 3rn,3	|
awk -F'\t' '{
	date = $1
	state[NR] = $2
	dd[NR] = $3
	cum[NR] = NR > 1 ? cum[NR-1] + $3 : $3
}
END {
	printf("rank\tdate\tstate\tdeaths\tcumDeaths\tpct\n")
	pct = cum[NR] == 0 ? 0 : 100.0*cum[i]/cum[NR]
	printf(".\t%s\tALL\t%d\t.\t%.1f\n", $1, cum[NR], 100.0)
	for(i = 1; i <= NR; i++){
		pct = cum[NR] == 0 ? 0 : 100.0*cum[i]/cum[NR]
		printf("%d\t%s\t%s\t%d\t%d\t%.1f", i, date, state[i], dd[i], cum[i], pct)
		printf("\n")
	}
}'
