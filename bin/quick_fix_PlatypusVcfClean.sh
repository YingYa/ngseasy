#!/bin/bash


#################################################################################
# usage
#################################################################################

function usage {
    echo "
Program: VcfClean
Version 1.0-r001
Author: Stephen Newhouse (stephen.j.newhouse@gmail.com)

usage:   VcfClean -v <VCF> -f <Variant Caller>

options:  -v  STRING  VCF file : [ vcf or vcf.gz]
          -f  STRING  Variant Caller : [platypus]
          -h  NULL    show this message
"
}

#################################################################################
# get options
#################################################################################

while  getopts "hv:f:" opt
do
    case ${opt} in
    h)
    usage #print help
    exit 0
    ;;
    v)
    VCF_INPUT=${OPTARG}
    ;;
    f)
    VCF_FORMAT=${OPTARG}
    ;;
    esac
done

VCF_FORMAT="platypus"
VCF="/media/Data/ngs_projects/GCAT_Data/NA12878/vcf/platypus_180715/small.vcf"

#################################################################################
## make compatible with other tools and mathc GATK/Freebayes annotaions
#################################################################################



if [[ ${VCF_FORMAT} == "platypus" ]]
    then
    if [[ gzip ]]
        then
        VCF=`basename ${VCF} .gz`
        zcat ${VCF}.gz | \
        sed s/TC\=/DP\=/g | sed s/ID=\TC\,/ID=\DP\,/g | \
        sed s/FR\=/AF\=/g | sed s/ID=\FR\,/ID=\AF\,/g | \
        sed s/GL\=/PL\=/g | sed s/ID\=GL\,/ID\=PL\,/g | \
        sed s/"GT:GL:GOF:GQ:NR:NV"/"GT:PL:GOF:GQ:DP:NV"/g | bgzip -c > ${VCF}.fix.vcf.gz && \
        tabix ${VCF}.fix.vcf.gz
    elif [[ not gzip ]]
        then
        VCF=`basename ${VCF} .vcf`
        cat ${VCF}.vcf | \
        sed s/TC\=/DP\=/g | sed s/ID=\TC\,/ID=\DP\,/g | \
        sed s/FR\=/AF\=/g | sed s/ID=\FR\,/ID=\AF\,/g | \
        sed s/GL\=/PL\=/g | sed s/ID\=GL\,/ID\=PL\,/g | \
        sed s/"GT:GL:GOF:GQ:NR:NV"/"GT:PL:GOF:GQ:DP:NV"/g |  bgzip -c > ${VCF}.fix.vcf.gz && \
        tabix ${VCF}.fix.vcf.gz
    else
        echo "what format is this? bgzip or not to bgzip?"
    fi
else
    echo "ok only..."
fi

## TO FIX:- Get GATK/Freebayes equivalents and check GEMINI requirements
# GL:GOF PL == GL
##FORMAT=<ID=NV,Number=.,Type=Integer,Description="Number of reads containing variant in this sample">
##FORMAT=<ID=NR,Number=.,Type=Integer,Description="Number of reads covering variant location in this sample">
##INFO=<ID=TCR,Number=1,Type=Integer,Description="Total reverse strand coverage at this locus">
##INFO=<ID=TCF,Number=1,Type=Integer,Description="Total forward strand coverage at this locus">
##INFO=<ID=TC,Number=1,Type=Integer,Description="Total coverage at this locus">
##INFO=<ID=NR,Number=.,Type=Integer,Description="Total number of reverse reads containing this variant">
##INFO=<ID=FR,Number=.,Type=Float,Description="Estimated population frequency of variant">
