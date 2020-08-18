#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] [ -p pct ] [ -map ] cv-states-file"

if [ -z "$CVA_HOME" ] ; then
	LOG ERROR "CVA_HOME not defined"
	exit 1
fi
CVA_SCRIPTS=$CVA_HOME/scripts

if [ -z "$WM_HOME" ] ; then
	LGO ERROR "WM_HOME not defined"
	exit 1
fi
WM_ETC=$WM_HOME/etc
ST_INFO=$WM_ETC/statefp.tsv

PCT=50.0
MAP=
FILE=

TMP_DFILE=/tmp/dfile.$$

while [ $# -gt 0 ] ; do
	case $1 in
	-help)
		echo "$U_MSG"
		exit 0
		;;
	-p)
		shift
		if [ $# -eq 0 ] ; then
			LOG ERROR "-p requires pct argument"
			echo "$U_MSG" 1>&2
			exit 1
		fi
		PCT="$1"
		shift
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
		pct = "'"$PCT"'" + 0
		map = "'"$MAP"'" == "yes"
	}
	NR == 2 {
		t_deaths = $4
	}
	NR > 2 {
		date = $2
		cnt = $5
		if(pct == 100){
			l_pct = 100
			s_list = s_list sprintf("\t%s", $3)
			if(map)
				s_list = s_list sprintf("|%s", $4)
		}else if(cnt > 0){
			s_list = s_list sprintf("\t%s", $3)
			if(map)
				s_list = s_list sprintf("|%s", $4)
			if($6 >= pct){
				l_pct = $6
				exit 0
			}
		}
	}
	END {
		printf("%s\t%s\t%.1f%s\n", date, t_deaths, (l_pct == 0 ? 100.0 : l_pct), s_list)
	}'
done	|
if [ "$MAP" == "yes" ] ; then
	awk -F'\t' 'BEGIN {
		st_info = "'"$ST_INFO"'"
		for(n_st_lines = n_stab = 0; (getline < st_info) > 0; ){
			n_st_lines++
			if(n_st_lines > 1){
				n_stab++
				st_idx[$2] = n_stab
				stab[n_stab] = $2
			}
		}
		close(st_info)
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
		printf("date\tmaxDeath\tcurTDeath\ttStsPct")
		for(i = 1; i <= n_stab; i++)
			printf("\t%s", stab[i])
		printf("\n")

		for(i = 1; i <= n_lines; i++){
			n_ary = split(lines[i], ary, "\t")
			printf("%s\t%d\t%d\t%s", ary[1], max_d, ary[2], ary[3])
			for(j = 3; j <= n_ary; j++)
				topStates[substr(ary[j], 1, 2)] = substr(ary[j], 4)
			for(j = 1; j <= n_stab; j++){
				if(stab[j] in topStates)
					printf("\t%s", topStates[stab[j]])
				else
					printf("\t.")
			}
			printf("\n")
		}
	}'
else
	cat
fi

rm -f $TMP_DFILE
