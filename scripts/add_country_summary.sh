#! /bin/bash
#
. ~/etc/funcs.sh

U_MSG="usage: $0 [ -help ] [ cv-world-data ]"

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
	LOG ERROR "extra argumets $*"
	echo "$U_MSG" 1>&2
	exit 1
fi

awk -F'\t' 'BEGIN {
	countries["Australia"] = 1
	countries["Canada"] = 1
	countries["China"] = 1
}
{
	if(country == ""){
		if($3 in countries){
			country = $3
			cnt = 1
			dcr = $1 "\t" $3 "\t" $2
			dcr_tab[dcr] = $0
		}else
			printf("%s\n", $0)
	}else if($3 == country){
		cnt++
		dcr = $1 "\t" $3 "\t" $2
		dcr_tab[dcr] = $0
	}else{
		n_dcr_tab = asorti(dcr_tab, dcr_idx)
		date = ""
		n_date = 0
		for(fi = i = 1; i <= cnt; i++){
			line = dcr_tab[dcr_idx[i]]
			n_ary = split(line, ary, "\t")
			if(ary[1] != date){
				if(n_date > 0){
					li = fi + n_date - 1
					upd_summary(country, date, dcr_tab, dcr_idx, fi, li)
					fi += n_date
					n_date = 0;
				}
			}
			date = ary[1]
			n_date++
		}
		if(n_date > 0){
			li = fi + n_date - 1
			upd_summary(country, date, dcr_tab, dcr_idx, fi, li)
			fi += n_date
			n_date = 0;
		}
		delete dcr_tab
		n_dcr_tab = 0
		country = ""
		cnt = 0
	}
}
function upd_summary(country, date, dcr_tab, dcr_idx, f_idx, l_idx,   dot_idx, lat, long, conf, death, rec, i, n_ary, ary, dot_line) {

	dot_idx = 0
	lat = long = conf = death = rec = 0
	for(i = f_idx; i <= l_idx; i++){
		n_ary = split(dcr_tab[dcr_idx[i]], ary, "\t")
		if(ary[2] == "."){
			dot_idx = i
			continue
		}
		lat += ary[4]
		long += ary[5]
		if(ary[6] != -1)
			conf += ary[6]
		if(ary[7] != -1)
			death += ary[7]
		if(ary[8] != -1)
			rec += ary[8]
	}
	if(dot_idx == 0){
		lat /= l_idx - f_idx + 1
		long /= l_idx - f_idx + 1
		dot_line = date "\t.\t" country sprintf("\t%.6f\t%.6f", lat, long) sprintf("\t%d\t%d\t%d", conf, death, rec) "\tworld"
	}else{
		n_ary = split(dcr_tab[dcr_idx[dot_idx]], ary, "\t")
		dot_line = ary[1] "\t.\t" ary[3] "\t" ary[4] "\t" ary[5]
		dot_line = dot_line "\t" (ary[6] == -1 ? conf : ary[6])
		dot_line = dot_line "\t" (ary[7] == -1 ? death : ary[7])
		dot_line = dot_line "\t" (ary[8] == -1 ? rec : ary[8])
		dot_line = dot_line "\tworld"
	}
	printf("%s\n", dot_line)
	for(i = f_idx; i <= l_idx; i++){
		if(i == dot_idx)
			continue
		printf("%s\n", dcr_tab[dcr_idx[i]])
	}
	return ""
}' $FILE
