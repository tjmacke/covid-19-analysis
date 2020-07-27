#! /bin/bash
#
. ~/etc/funcs.sh

# sort right
LC_ALL=C

U_MSG="usage: $0 [ -help ] [ -nopull] (no args)"

if [ -z "$CVA_HOME" ] ; then
	LOG ERROR "CVA_HOME not defined"
	exit 1
fi
CVA_SCRIPTS=$CVA_HOME/scripts

# This is where I put the git data repo; adjust as needed
if [ -z "$CVD_HOME" ] ; then
	LOG ERROR "CVD_HOME not defined"
	exit 1
fi

PULL="yes"
while [ $# -gt 0 ] ; do
	case $1 in
	-help)
		echo "$U_MSG"
		exit 0
		;;
	-nopull)
		PULL=
		shift
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

if [ "$PULL" == "yes" ] ; then
	pushd $CVD_HOME > /dev/null
	git pull -q
	popd > /dev/null
fi

for dt in confirmed deaths recovered ; do
	# Use $WM_HOME/bin/csv2tsv to convert the d/l csv file to tsv
	$CVA_SCRIPTS/fmt_cv_world_data.sh $dt > /tmp/cv.$dt.$$

	# Use python (2) to convert the the d/l csv file to tsv
	# $CVA_SCRIPTS/fmt_cv_world_data.py $dt > /tmp/cv.$dt.$$
done

echo -e "date\tstate\tcountry\tlat\tlong\tconfirmed\tdeaths\trecovered\tsource"
awk -F'\t' '{
	if(FILENAME != l_FILENAME){
		nf = split(FILENAME, ary, ".")
		dt = ary[2]
		l_FILENAME = FILENAME
		n_dts++
		dts[n_dts] = dt
	}
	key = sprintf("%s\t%s\t%s", $1, $2, $3)
	if(!(key in keys)){
		keys[key] = 1
		n_ktab++
		ktab[n_ktab] = key
	}
	values[key, dt] = $6
	lats[key, dt] = $4 + 0
	longs[key, dt] = $5 + 0
}
END {
	for(i = 1; i <= n_ktab; i++){
		key = ktab[i]
		printf("%s", key)
		# lat, long can be inconsistent among the categories, so average
		lat = 0
		long = 0
		for(j = 1; j <= n_dts; j++){
			dt = dts[j]
			lat += lats[key, dt]
			long += longs[key, dt]
		}
		printf("\t%.6f\t%.6f", lat/n_dts, long/n_dts)
		for(j = 1; j <= n_dts; j++){
			dt = dts[j]
			v = values[key, dt]
			printf("\t%s", v != "" ? v : "-1")
		}
		printf("\tworld")
		printf("\n")
	}
}' /tmp/cv.*.$$				|
sort -t $'\t' -k 3,3 -k 2,2		|
$CVA_SCRIPTS/add_country_summary.sh

rm -f /tmp/cv.*.$$
