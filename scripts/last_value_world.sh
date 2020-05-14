#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] [ cv-world-data-file ]"

FILE=

while [ $# -gt 0 ] ; do
	case $1 in
	-help)
		echo "$U_MSG"
		exit 0
		;;
	-*)
		LOG ERROR "unkknown option $1"
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

# collect data from last date
# discard any data with
#	(lat, long) == (0, 0)
awk -F'\t' '{
	if($2 != l_2 || $3 != l_3){
		if(l_3 != ""){
			n_ldtab++
			ldtab[n_ldtab] = rtab[n_rtab]
			delete rtab
			n_rtab = 0
		}
	}
	l_2 = $2
	l_3 = $3
	n_rtab++
	rtab[n_rtab] = $0
}
END {
	if(l_3 != ""){
		n_ldtab++
		ldtab[n_ldtab] = rtab[n_rtab]
		delete rtab
		n_rtab = 0
	}
	for(i = 1; i <= n_ldtab; i++)
		printf("%s\n", ldtab[i])
	
}' $FILE	|
awk -F'\t' 'BEGIN {
	pr_hdr = 1
	HDR = "date\tProvince_State\tCountry_Region\tLat\tLong\tconfirmed\tdeaths\trecovered"
}
{
	if($4 == 0 && $5 == 0){
		printf("WARN: main: discard: no position: %s\n", $0) > "/dev/stderr"
		next
	}
	if($3 != l_3){
		if(l_3 != ""){
			if(pr_hdr){
				pr_hdr = 0
				printf("%s\n", HDR)
			}
			chk_region(n_rtab, rtab)
			delete rtab
			n_rtab = 0
		}
	}
	n_rtab++
	rtab[n_rtab] = $0
	l_3 = $3
}
END {
	if(l_3 != ""){
		chk_region(n_rtab, rtab)
		delete rtab
		n_rtab = 0
	}
}
function chk_region(n_rtab, rtab,   i){

	if(n_rtab > 1){
		n_ary = split(rtab[1], ary, "\t")
		if(ary[3] == "Canada"){
			# Canada has all recovred in 1 entry with $2 == "."
			# And treat -1 as 0 in summing
			lat = long = conf = death = recover = 0
			for(i = 1; i <= n_rtab; i++){
				n_ary = split(rtab[i], ary, "\t")
				lat += ary[4]
				long += ary[5]
				conf += (ary[6] >= 0 ? ary[6] : 0)
				death += (ary[7] >= 0 ? ary[7] : 0)
				recover += (ary[8] >= 0 ? ary[8] : 0)
			}
			printf("%s\t.\t%s", ary[1],ary[3])
			printf("\t%.6f\t%.6f", 1.0*lat/n_rtab, 1.0*long/n_rtab)
			printf("\t%d\t%d\t%d\n", conf, death, recover)
		}else{
			ix_dot = 0
			for(i = 1; i <= n_rtab; i++){
				n_ary = split(rtab[i], ary, "\t")
				if(ary[2] == ".")
					ix_dot = i
			}
			if(ix_dot > 0)
				printf("%s\n", rtab[ix_dot])
			else{
				# printf("INFO: chk_region: ?: %s\n", rtab[1]) > "/dev/stderr"
				lat = long = conf = death = recover = 0
				for(i = 1; i <= n_rtab; i++){
					n_ary = split(rtab[i], ary, "\t")
					lat += ary[4]
					long += ary[5]
					conf += ary[6]
					death += ary[7]
					recover += ary[8]
				}
				printf("%s\t.\t%s", ary[1],ary[3])
				printf("\t%.6f\t%.6f", 1.0*lat/n_rtab, 1.0*long/n_rtab)
				printf("\t%d\t%d\t%d\n", conf, death, recover)
			}
		}
	}else
		printf("%s\n", rtab[1])
}'
