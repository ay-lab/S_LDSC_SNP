#!/bin/bash

usage(){
cat << EOF

Options:
   	-C  ConfigFile		Name of the configuration file storing the parameters.
EOF
}

while getopts "C:" opt;
do
	case "$opt" in
		C) ConfigFile=$OPTARG;;
		\?) usage
			echo "error: unrecognized option -$OPTARG";
			exit 1
			;;
	esac
done

echo -e "\n\n ================ Parsing input configuration file ================= \n\n"

# separator used in the config file
IFS="="
while read -r name value
do
	param=$name
	paramval=${value//\"/}
	if [[ -n $param ]]; then
		if [[ $param != \#* ]]; then
			# if there are multiple parameter values (separated by # - old values are kept)
			# then the following operation selects the current one
			paramval=$(echo "$paramval" | awk -F['#\t'] '{print $1}' | tr -d '[:space:]');
			echo -e "Content of $param is $paramval"
			if [ $param == "DataDir" ]; then
				DATADIR=$paramval
			fi
			if [ $param == "InpGWASFile" ]; then
				InpGWASFile=$paramval
			fi
			if [ $param == "GWASsamplesize" ]; then
				GWASsamplesize=$paramval
			fi			
			if [ $param == "GWASSumStatsFile" ]; then
				GWASSumStatsFile=$paramval
			fi						
			if [ $param == "LDSCCodeDir" ]; then
				LDSCCodeDir=$paramval
			fi
			if [ $param == "OutDir" ]; then
				BaseOutDir=$paramval
			fi
			if [ $param == "GWASTraitName" ]; then
				GWASTraitName=$paramval
			fi
			if [ $param == "A1IncAllele" ]; then
				A1IncAllele=$paramval
			fi
			if [ $param == "VariantType" ]; then
				VariantType=$paramval
			fi
			if [ $param == "QTLFile" ]; then
				QTLFile=$paramval
			fi
			if [ $param == "chrcol" ]; then
				chrcol=$paramval
			fi
			if [ $param == "poscol" ]; then
				poscol=$paramval
			fi
		fi
	fi
done < $ConfigFile


## identify the directory containing this script
currworkdir=`pwd`
echo 'currworkdir : '$currworkdir

currscriptdir=`dirname $0`
cd $currscriptdir
echo 'currscriptdir : '$currscriptdir

## create the base output directory
mkdir -p $BaseOutDir

## create the output directory
## with respect to the prefix string provided
if [[ $VariantType != "" ]]; then
	OutDir=$BaseOutDir'/'$VariantType	
else
	OutDir=$BaseOutDir
fi
mkdir -p $OutDir

PythonExec=`which python`
echo 'PythonExec : '$PythonExec

RScriptExec=`which Rscript`
echo 'RScriptExec : '$RScriptExec

GENOTYPEDIR=$DATADIR'/1000G_EUR_Phase3_plink'
GENOTYPEPREFIX='1000G.EUR.QC'
AnnotDir=$OutDir'/Annotation'
mkdir -p $AnnotDir

##================================
## step 1: download the reference LD score data
## Downloading reference LD score datasets, SNPs, etc. from the web repository of the developer group.
## From the link: https://alkesgroup.broadinstitute.org/LDSCORE/
## as suggested in the GitHub pages
## https://github.com/bulik/ldsc
## and
## https://github.com/kkdey/GSSG
##================================

mkdir -p $DATADIR
cd $DATADIR

inpfile='1000G_Phase3_baselineLD_v2.1_ldscores.tgz'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_baselineLD_v2.1_ldscores.tgz
	tar -xzvf $inpfile
fi

inpfile='1000G_Phase3_cell_type_groups.tgz'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_cell_type_groups.tgz
fi

inpfile='1000G_Phase3_frq.tgz'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_frq.tgz
	tar -xzvf 1000G_Phase3_frq.tgz
fi

inpfile='1000G_Phase3_weights_hm3_no_MHC.tgz'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_weights_hm3_no_MHC.tgz
	tar -xzvf 1000G_Phase3_weights_hm3_no_MHC.tgz
fi

inpfile='w_hm3.snplist'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/w_hm3.snplist.bz2
	bunzip2 w_hm3.snplist.bz2
fi

inpfile='1000G_Phase3_plinkfiles.tgz'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_plinkfiles.tgz
	tar -xzvf 1000G_Phase3_plinkfiles.tgz
	mv 1000G_Phase3_plinkfiles 1000G_EUR_Phase3_plink
fi

inpfile='hapmap3_snps.tgz'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/hapmap3_snps.tgz
	tar -xzvf hapmap3_snps.tgz
fi

inpfile='1000G_Phase3_ldscores.tgz'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_ldscores.tgz
	tar -xzvf 1000G_Phase3_ldscores.tgz
fi

inpfile='1000G_Phase3_EAS_baselineLD_v2.1_ldscores.tgz'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_EAS_baselineLD_v2.1_ldscores.tgz
fi

inpfile='1000G_Phase3_EAS_weights_hm3_no_MHC.tgz'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_EAS_weights_hm3_no_MHC.tgz
fi

inpfile='1000G_Phase3_EAS_plinkfiles.tgz'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_EAS_plinkfiles.tgz
fi

inpfile='1000G_Phase3_EAS_weights_hm3_no_MHC.tgz'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_EAS_weights_hm3_no_MHC.tgz
fi

inpfile='list.txt'
if [[ ! -f $inpfile ]]; then
	wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/list.txt
fi

## directory to download a reference GWAS dataset from S-LDSC package
RefGWASDir=$DATADIR'/Ref_GWAS_Data_Test'
mkdir -p $RefGWASDir
cd $RefGWASDir

inpfile='GIANT_BMI_Speliotes2010_publicrelease_HapMapCeuFreq.txt'
if [[ ! -f $inpfile ]]; then
	wget http://portals.broadinstitute.org/collaboration/giant/images/b/b7/GIANT_BMI_Speliotes2010_publicrelease_HapMapCeuFreq.txt.gz
	gunzip GIANT_BMI_Speliotes2010_publicrelease_HapMapCeuFreq.txt.gz
fi

## return to the current script directory
cd $currscriptdir


##================================
## step 2: Convert the GWAS summary statistics to the S-LDSC compatible .sumstats format
## we assume that input GWAS summary statistics is provided in hg19 reference genome
## required for computing LDSC
## check https://github.com/bulik/ldsc/wiki/Summary-Statistics-File-Format
##================================

## if the GWASSumStatsFile is not provided 
## then compute the sumstats formatted GWAS summary file
if [[ $GWASSumStatsFile == "" || ! -f $GWASSumStatsFile ]]; then

	## code to convert summary statistics into .sumstats format
	## provided in LDSC GitHub package
	CodeExec=$LDSCCodeDir'/munge_sumstats.py'

	## reference SNPList downloaded from the LDSC repository (step 1)
	SNPListFile=$DATADIR'/w_hm3.snplist'

	## directory which will store the converted .sumstats file
	SumStatsDir=$BaseOutDir'/input_GWAS_sumstats'
	mkdir -p $SumStatsDir
	GWASSumstatsoutprefix=$SumStatsDir'/'$GWASTraitName

	if [[ ! -f $GWASSumstatsoutprefix'.sumstats.gz' ]]; then	
		if [[ $A1IncAllele == 1 ]]; then
			if [[ $GWASsamplesize != "" ]]; then
				## sample size is not present in the GWAS input file
				## to be provided explicitly
				${PythonExec} ${CodeExec} --sumstats ${InpGWASFile} --merge-alleles ${SNPListFile} --out ${GWASSumstatsoutprefix} --a1-inc --N ${GWASsamplesize}
			else
				${PythonExec} ${CodeExec} --sumstats ${InpGWASFile} --merge-alleles ${SNPListFile} --out ${GWASSumstatsoutprefix} --a1-inc
			fi
		else
			if [[ $GWASsamplesize != "" ]]; then
				## sample size is not present in the GWAS input file
				## to be provided explicitly
				${PythonExec} ${CodeExec} --sumstats ${InpGWASFile} --merge-alleles ${SNPListFile} --out ${GWASSumstatsoutprefix} --N ${GWASsamplesize}
			else
				${PythonExec} ${CodeExec} --sumstats ${InpGWASFile} --merge-alleles ${SNPListFile} --out ${GWASSumstatsoutprefix}
			fi
		fi
	fi

	GWASSumStatsFile=$GWASSumstatsoutprefix'.sumstats.gz'

fi

##================================
## step 3: use the input eQTL / variant file to define the annotations
## which will be used as the input to LDSC script
##================================
cd $currscriptdir
echo 'before making QTL annotations - current working directory : '`pwd`

## directory containing the 1000G genotype in PLINK format
## downloaded from the LDSC repository
## .bim file contains CM field
$RScriptExec ${currscriptdir}/Make_input_QTL_Annotations.R $GENOTYPEDIR $GENOTYPEPREFIX $QTLFile $VariantType $chrcol $poscol $AnnotDir 

##================================
## step 4: use the input eQTL / variant derived annotations from step 3
## to compute the LD score
##================================
for chrnum in {1..22}; do
	if [[ ! -f ${AnnotDir}'/out.'${chrnum}'.l2.ldscore.gz' ]]; then
		$PythonExec ${LDSCCodeDir}/ldsc.py --l2 --bfile ${GENOTYPEDIR}/${GENOTYPEPREFIX}.${chrnum} --ld-wind-cm 1 --annot ${AnnotDir}/out.${chrnum}.annot.gz --out ${AnnotDir}/out.${chrnum} --print-snps ${DATADIR}/list.txt 
	fi
done

##================================
## step 5: estimate the heritability using the LD score
## reference: baseline LD score from different annotations
## provided in the LDSC package
##================================

finaloutprefix=$OutDir'/'$GWASTraitName'_'$VariantType

$PythonExec ${LDSCCodeDir}/ldsc.py --h2 ${GWASSumStatsFile} --ref-ld-chr ${AnnotDir}/out.,${DATADIR}/1000G_Phase3_baselineLD_v2.1_ldscores/baselineLD. --w-ld-chr ${DATADIR}/1000G_Phase3_weights_hm3_no_MHC/weights.hm3_noMHC. --overlap-annot --frqfile-chr ${DATADIR}/1000G_Phase3_frq/1000G.EUR.QC. --out ${finaloutprefix} --print-coefficients


##===========
## now go back to the original working directory
##===========
cd $currworkdir
echo 'Thank you !! S-LDSC is executed.'

