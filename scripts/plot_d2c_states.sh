#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] -c cfg-file [ -fmt F ] [ data-file ]"

if [ -z "$CVA_HOME" ] ; then
	LOG ERROR "CVA_HOME not defined"
	exit 1
fi

if [ -z "$DM_HOME" ] ; then
	LOG ERROR "DM_HOME not defined"
	exit 1
fi
DM_SCRIPTS=$DM_HOME/scripts

if [ -z "$WM_HOME" ] ; then
	LOG ERROR "WM_HOME not defined"
	exit 1
fi
WM_SCRIPTS=$WM_HOME/scripts
WM_BIN=$WM_HOME/bin

TMP_PFILE=/tmp/pfile.$$
TMP_PFILE_2=/tmp/pfile_2.$$
TMP_MFILE=/tmp/mfile.$$
TMP_JC_FILE=/tmp/cfg.jgon.$$

CV_SCRIPTS=$CVA_HOME/scripts
CV_GEO=$CVA_HOME/geo
US_STATES_MAP=$CV_GEO/cb_2017_us_state_500k

CFILE=
FMT=
FILE=

while [ $# -gt 0 ] ; do
	case $1 in
	-help)
		echo "$U_MSG"
		exit 0
		;;
	-c)
		shift
		if [ $# -eq 0 ] ; then
			LOG ERROR "-c requires cfg-file argument"
			echo "$U_MSG" 1>&2
			exit 1
		fi
		CFILE=$1
		shift
		;;
	-fmt)
		shift
		if [ $# -eq 0 ] ; then
			LOG ERROR "-fmt requires format argument"
			echo "$U_MSG" 1>&2
			exit 1
		fi
		FMT=$1
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

if [ -z "$CFILE" ] ; then
	LOG ERROR "missing -c cfg-file argument"
	echo "$U_MSG" 1>&2
	exit 1
fi

sqlite3 $US_STATES_MAP.db <<_EOF_ > $TMP_PFILE
.headers on
.mode tabs
SELECT rnum, STUSPS as state
FROM shapes
ORDER BY state ;
_EOF_

awk -F'\t' 'BEGIN {
	min_cases = 0
	pr_hdr = 1
	f_dc2 = 1
}
{
	if($6 < 100)
		next
	d2c = $6 == 0 ? 0 : 100.0*$7/$6
	if(f_d2c){
		f_d2c = 0
		min_d2c = max_d2c = d2c
	}else if(d2c < min_d2c)
		min_d2c = d2c
	else if(d2c > max_d2c)
		max_d2c = d2c
	if(pr_hdr){
		pr_hdr = 0
		printf("date\tstate\td2c\tconfirmed\tdeath\n")
	}
	printf("%s\t%s\t%.1f\t%d\t%d\n", $1, $3, d2c, $6, $7)
}' $FILE						 		|
$WM_SCRIPTS/add_columns.sh -b $TMP_PFILE -mk state			|
$WM_SCRIPTS/interp_prop.sh -c $CFILE -bk d2c -nk fill -meta $TMP_MFILE	|
$WM_SCRIPTS/format_color.sh -k fill					|
awk -F'\t' 'NR == 1 {
	for(i = 1; i <= NF; i++)
		ftab[$i] = i
	n_ftab = NF;
	n_ftab++
	ftab[n_ftab] = "title"
	printf("%s\t%s\n", $0, "title")
}
NR > 1 {
 	printf("%s\t%s: date=%s<br/>confirmed=%d<br/>deaths=%d<br/>deaths/confirmed=%.1f%%\n", $0, $(ftab["state"]), $(ftab["date"]), $(ftab["confirmed"]), $(ftab["death"]), $(ftab["d2c"]))
}' > $TMP_PFILE_2

if [ ! -z "$FMT" ] ; then
	if [ "$FMT" == "wrap" ] ; then
		cat $CFILE $TMP_MFILE | $DM_SCRIPTS/cfg_to_json.sh > $TMP_JC_FILE
		SC="-sc $TMP_JC_FILE"
	else
		SC=
	fi
	FMT="-fmt $FMT"
else
	cat $CFILE $TMP_MFILE | $DM_SCRIPTS/cfg_to_json.sh > $TMP_JC_FILE
	SC="-sc $TMP_JC_FILE"
fi
$WM_SCRIPTS/extract_cols.sh -hdr drop -c rnum $TMP_PFILE_2	|
$WM_BIN/shp_to_geojson $SC -pf $TMP_PFILE_2 -pk rnum $FMT -sf $US_STATES_MAP

rm -f $TMP_PFILE $TMP_PFILE_2 $TMP_MFILE $TMP_JC_FILE
