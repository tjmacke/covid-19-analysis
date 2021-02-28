#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] [ -d date ] [ -v { deaths* | confirmed } ] [ cv-states-files ]"

F_CONFIRMED=6
F_DEATHS=7

DATE=
VALUE=deaths
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
	-v)
		shift
		if [ $# -eq 0 ] ; then
			LOG ERROR "-v requires value argument"
			echo "$U_MSG" 1>&2
			exit 1
		fi
		VALUE=$1
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

if [ "$VALUE" == "deaths" ] ; then
	F_VALUE=$F_DEATHS
elif [ "$VALUE" == "confirmed" ] ; then
	F_VALUE=$F_CONFIRMED
else
	LOG ERROR "unknown value \"$VALUE\""
	echo "$U_MSG" 1>&2
	exit 1
fi

awk -F'\t' 'BEGIN {
	value = "'"$VALUE"'"
	f_value = "'"$F_VALUE"'" + 0
	date = "'"$DATE"'"
}
NR > 1 {
	if($2 != l_2){
		if(l_2 != ""){
			print_dv(dates, values, (date != "" ? date : l_1), l_2)
			delete values
			delete dates
			n_dates = 0
		}
	}
	l_1 = $1
	l_2 = $2
	n_dates++
	dates[$1] = n_dates
	values[n_dates] = $f_value
}
END {
	if(l_2 != ""){
		print_dv(dates, values, (date != "" ? date : l_1), l_2)
		delete values
		delete_dates
		n_dates = 0
	}
}
function print_dv(dates, values, date, state,   i, dv) {
	i = dates[date]
	if(i == 1)
		dv = values[1]
	else
		dv = values[i] - values[i-1]
	t_dv += dv
	printf("%s\t%s\t%d\n", date, state, dv)
	return 0
}' $FILE		|
sort -t $'\t' -k 3rn,3	|
awk -F'\t' 'BEGIN {
	value = "'"$VALUE"'"
}
{
	date = $1
	state[NR] = $2
	dv[NR] = $3
	cum[NR] = NR > 1 ? cum[NR-1] + $3 : $3
}
END {
	printf("rank\tdate\tstate\t%s\tcum%s%s\tpct\n", value, toupper(substr(value, 1, 1)), substr(value, 2))
	pct = cum[NR] == 0 ? 0 : 100.0*cum[i]/cum[NR]
	printf(".\t%s\tALL\t%d\t.\t%.1f\n", $1, cum[NR], 100.0)
	for(i = 1; i <= NR; i++){
		pct = cum[NR] == 0 ? 0 : 100.0*cum[i]/cum[NR]
		printf("%d\t%s\t%s\t%d\t%d\t%.1f", i, date, state[i], dv[i], cum[i], pct)
		printf("\n")
	}
}'
