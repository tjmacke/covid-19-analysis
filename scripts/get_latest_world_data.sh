#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] (no args)"

if [ -z "$CVA_HOME" ] ; then
	LOG ERROR "CVA_HOME not defined"
	exit 1
fi

if [ -z "$CVD_HOME" ] ; then
	LOG ERROR "CVD_HOME not defined"
	exit 1
fi

CVA_SCRIPTS=$CVA_HOME/scripts

# This is where I put the git repo; adjust as needed

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
		LOG ERROR "extra argumets $*"
		echo "$U_MSG" 1>&2
		exit 1
		;;
	esac
done

pushd $CVD_HOME > /dev/null
git pull -q
popd > /dev/null

for dt in confirmed deaths recovered ; do
	# Use $WM_HOME/bin/csv2tsv to convert the d/l csv file to tsv
	$CVA_SCRIPTS/fmt_cv_world_data.sh $dt > /tmp/cv.$dt.$$
	# Use python (2) to convert the the d/l csv file to tsv
	# $CVA_SCRIPTS/fmt_cv_world_data.py $dt > /tmp/cv.$dt.$$
done

awk -F'\t' '{
	if(FILENAME != l_FILENAME){
		nf = split(FILENAME, ary, ".")
		dt = ary[2]
		l_FILENAME = FILENAME
		n_dts++
		dts[n_dts] = dt
	}
	key = sprintf("%s\t%s\t%s\t%s\t%s", $1, $2, $3, $4, $5)
	if(!(key in keys)){
		keys[key] = 1
		n_ktab++
		ktab[n_ktab] = key
	}
	values[key, dt] = $6
}
END {
	for(i = 1; i <= n_ktab; i++){
		key = ktab[i]
		printf("%s", key)
		for(j = 1; j <= n_dts; j++){
			dt = dts[j]
			v = values[key, dt]
			printf("\t%s", v != "" ? v : "-1")
		}
		printf("\n")
	}
}' /tmp/cv.*.$$	|
sort -t $'\t' -k 3,3 -k 2,2

rm -f /tmp/cv.*.$$
