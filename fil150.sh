#!/bin/bash 
export PATH=$HOME/localperl/bin/:$PATH # J'exporte perl par défaut pour le rendre à version v5.16.x
################################################################################
# This script aims to complete key BioNano OM analyses using command line.     #
# ScriptName: runBNG                                                           #
# Written by Andy Yuan (yuxuan.yuan@research.uwa.edu.au)                       #
# Modified by Ginel Dorleon                     #
# Last modified date: October 2017                                              #
# Note:                                                                        #
#       1)Please download the latest BNG tools and scripts into your system    #
#               Tools: http://www.bnxinstall.com/RefalignerAssembler           #
#               Scripts: http://www.bnxinstall.com/Scripts                     #
#       2)This script needs python (v2.7.5 or above) and perl (v5.10.x,        #
#       v5.14.x or v5.16.x). If your want to use it, please set python and     #
#       perl properly in your system.                                          #
################################################################################




##bnxstats
bs_msg_d="\nDescription: Check stats of a given bnx file (N_molecules, length, label density, SNR, intensity)."
bs_msg="\nUsage: `basename $0` bnxstats [-h] [-b <bnx>]\n";
bs_msg="$bs_msg	-h	display this help and exit.\n";
bs_msg="$bs_msg	-b	the bnx file.\n";
bs_msg="$bs_msg	-p	a name for the table extracted from the bnx file.\n";
bs_msg="$bs_msg	-o	output directory.\n";



##==================== Select "bnxstats flag =========================
##Print help if only select bnxstats
if [[ $1 == "bnxstats" ]] && [[ $# -eq 1 ]]; then 
	echo -e "$bs_msg_d";
	echo -e "$bs_msg";
	exit 0
fi

##Select bnxstats flag
if [[ $1 == "bnxstats" ]] && [[ $# -gt 1 ]]; then
	arg1=$1
	shift
	bs_options=':h:b:p:o:';
	while getopts "$bs_options" opt; do
		case "$opt" in
			h) echo -e "$bs_msg_d"; echo -e "$bs_msg"; exit 0;;
			b) bnx=${OPTARG};;
			p) name=${OPTARG};;
			o) outDir=${OPTARG};;
			\?) echo;echo -e "Oops! Unknown option -$OPTARG">&2; echo "Please check '`basename $0` bnxstats' and continue..."; echo; exit 0;;
			:) echo;echo -e "Missing option argument for -$OPTARG">&2; echo; exit 1;;
		esac
	done
	shift "$((OPTIND - 1))"
	
	if [[ -z "$bnx" ]] || [[ -z "$name" ]] || [[ -z "$outDir" ]]; then 
		echo 
		echo 'Some compulsory option is not given please check as following:'
		echo -e "$bs_msg" 1>&2; exit 1
	fi

	bnx=`readlink -f "$bnx"`
	if [[ ! -s "$bnx" ]] || [[ ! -r "$bnx" ]]; then 
		echo 
		echo "Oops! It seems the bnx file: '${bnx}' is not existent or readable. Please check!"
		echo; exit 1
	fi
	
	check=`grep -c "# BNX File Version:" "$bnx"`
	if [[ "$check" -eq 0 ]]; then 
		echo 
		echo "Oops! It seems the input file is not a bnx file. Please check!" 
		echo; exit 1
	fi
	
	last_chr="${outDir: -1}"
	
	if [[ "$last_chr" == "/" ]]; then
		outDir="${outDir%?}"
	fi

	if [[ "$outDir" == "." ]];then
		outDir="$PWD"
	elif [[ ${outDir: -2} == ".." ]];then
		outDir="$PWD/$outDir"
	fi

	if [[ ! -d "$outDir" ]] || [[ ! -w "$outDir" ]]; then 
		echo
		echo "Oops! It seems the output directory: '${outDir}' is not existent or writable. Please check!"
		echo; exit 1
	fi
	for i in `grep -v "^#" "$bnx" | awk '{if(NR%4==1) print $1}'`; do
		if [[ $i != 0 ]]; then 
			echo 
			echo "Oops! It seems the bnx file: '${bnx}' is not complete. Please check!"
			echo; exit 1
		fi
	done

	rm -rf "$outDir"/"$name".txt 

	printf "Length""\t""AvgIntensity""\t""SNR""\t""NumberofLabels""\n" >> "$outDir"/"$(basename ${bnx})_$name".txt
	grep -v "^#" "$bnx" | awk 'BEGIN{OFS="\t"}{if(NR%4==1) print $3,$4,$5,$6}'  >> "$outDir"/"$(basename ${bnx})_$name".txt

	n_mol=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $0}' | wc -l`
	cL=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) sum+=$3}END{print sum/1000000}'`
	avgL=`grep -v "^#" "$bnx" | awk -v n=$n_mol '{if (NR%4==1) sum+=$3}END{print sum/n/1000}'`
	minL=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $3}' | sort -n | head -n 1` 
	maxL=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $3}' | sort -rn | head -n 1`
	
	half=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) sum+=$3}END{print sum/2}'`
	n=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $3}' | sort -n | awk -v hv=$half '{sum+=$1} {if(sum<=hv) print NR}' | tail -1`
	if [[ `awk "BEGIN{print $n_mol%2}"` == 0 ]]; then 
		s1=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $3}' | sort -n | awk -v n=$n '{if(NR==n) print $1}'`
		s2=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $3}' | sort -n | awk -v n=$n '{if(NR==n+1) print $1}'`
		n50=`awk "BEGIN{print ($s1+$s2)/2}"`
	else
		n50=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $3}' | sort -n | awk -v n=$n '{if(NR==n+1) print $1}'`
	fi

	stdL=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $3}' | awk '{x[NR]=$1; s+=$1; n++} END {a=s/n; for (i in x) {ss+=(x[i]-a)^2} sd=sqrt(ss/n); print sd}'`
	den=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) sum+=$6}END{print sum}'`
	
	minSNR=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $5}' | sort -n | head -n 1`
	maxSNR=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $5}' | sort -rn | head -n 1`
	avgSNR=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $5}' | awk '{sum+=$1; n++} END {print sum/n}'`

	maxten=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $4}' | sort -n | head -n 1`
	minten=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $4}' | sort -rn | head -n 1`
	avgten=`grep -v "^#" "$bnx" | awk '{if (NR%4==1) print $4}' | awk '{sum+=$1; n++} END {print sum/n}'`

	echo "========================================== Filteredstats starts ============================================="
	echo "## Start date: `date`"
	echo "## Checked bnx file: ${bnx}"
	echo "## Name for the saved table: $(basename ${bnx})_${name}.txt"
	echo "## Output directory: ${outDir}"
	echo
	
printf "Filtred Data(150kb)""\t""Number of Molecules""\t""Total Lenght Mb""\t""N50 kb""\t""Avg Intensity""\t""Lab Density/100kb""\t""Average SNR""\n">$outDir/CSV/Header150kb.csv
 (echo "$(basename ${bnx})	${n_mol}	${cL}	`awk "BEGIN{ print ${n50}/1000}"`	${avgL}	`awk "BEGIN{print ${den}/${cL}/10}"`	${avgSNR}">>$outDir/CSV/Filtr150kb.csv)


# percent calculator

 printf "Total Lenght Mb""\n"> $outDir/CSV/HFilter150.csv
 (echo "${cL}">> $outDir/CSV/PFilter150.csv) 
 
 cat $outDir/CSV/HFilter150.csv $outDir/CSV/PFilter150.csv > $outDir/CSV/NFilter150.csv
 rm -rf $outDir/CSV/HFilter150.csv $outDir/CSV/PFilter150.csv 
 
	echo
	echo  "## End date: `date`"
	echo "========================================================================================================="
	echo 
	echo

fi

