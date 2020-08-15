#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] [ -map ] cv-states-file"

if [ -z "$CVA_HOME" ] ; then
	LOG ERROR "CVA_HOME not defined"
	exit 1
fi
CVA_SCRIPTS=$CVA_HOME/scripts

MAP=
FILE=

TMP_DFILE=/tmp/dfile.$$

while [ $# -gt 0 ] ; do
	case $1 in
	-help)
		echo "$U_MSG"
		exit 0
		;;
	-map)
		MAP="yes"
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
		map = "'"$MAP"'" == "yes"
	}
	NR == 2 {
		t_deaths = $4
	}
	NR > 2 {
		date = $2
		cnt = $5
		pct = $6
		if(map){
#			s_list = s_list sprintf("\t%s|%s", $3, $4)
			st_cnt[$3] = $4
		}else{
			if(cnt > 0)
				s_list = s_list sprintf("\t%s", $3)
			if(pct >= 50.0)
				exit 0
		}
	}
	END {
		if(map){
			n_st = asorti(st_cnt, st_idx)
			printf("%s\t%s", date, t_deaths)
			for(i = 1; i <= n_st; i++)
				printf("\t%s|%d", st_idx[i], st_cnt[st_idx[i]])
			printf("\n")
		}else
			printf("%s\t%s\t%.1f%s\n", date, t_deaths, (pct == 0 ? 100.0 : pct), s_list)
	}'
done	|
if [ "$MAP" == "yes" ] ; then
	awk -F'\t' 'BEGIN {
		max_d = -1
	}
	{
		d = $2 + 0
		if(d > max_d){
			max_d = d
			max_d_date = $1
		}
		n_lines++
		lines[n_lines] = $0
	}
	END {
		n_ary = split(lines[1], ary, "\t")
		printf("date\tmaxDeath\tcurTDeath")
		for(i = 3; i <= n_ary; i++)
			printf("\t%s", substr(ary[i], 1, 2))
		printf("\n")
		for(i = 1; i <= n_lines; i++){
			n_ary = split(lines[i], ary, "\t")
			printf("%s\t%d\t%d", ary[1], max_d, ary[2])
			for(j = 3; j <= n_ary; j++){
#				printf("\t%.4f", 1.0*substr(ary[j], 4)/max_d)
				printf("\t%s", substr(ary[j], 4))
			}
			printf("\n")
		}
	}'
else
	cat
fi

rm -f $TMP_DFILE
