#!/bin/bash

set -o errexit
set -o nounset

################## SCRIPT INFORMATION ##################
f [ "$1" == "-h" ]; then
  echo -e "\n########################################################"
  echo -e "################## SCRIPT INFORMATION ##################"
  echo -e "########################################################"
  echo -e "\nThis script calculates per site depth (output .site.depth)"
  echo -e "and total percent covered with at least X per site depth (output .region.cov) for loci defined in the loci bed input"  
  echo -e "\nVersion region_coverage_calculator_v0.1.sh by Tiina M. Mattila 10-09-2021"
  echo -e "\nUsage: `basename $0` <your bam file> <bed file containing coordinates of interest> \
<per site depth filter threshold> <base quality minimum value> <mapping quality minimum value>"
  echo -e "\nDependencies: samtools and bedtools, tested on versions bedtools/2.29.0 & samtools/1.13"
  echo -e "\n########################################################"
  echo -e "################ SCRIPT INFORMATION END ################"
  echo -e "########################################################\n"
  exit 0
fi

##################### INPUT VARIABLES ###################

# Input variables
BAMFILE=$1 # Your bam file
LOCI_BED=$2 # Bed formatted file containing regions of interest
DEPTH_FILT=$3 # Per site depth threshold
BQ=$4 # Base quality threshold
MQ=$5 # Mapping quality threshold

# Additional variables
BAMBASE=$(basename ${BAMFILE} .bam)
LOCI_BASE=$(basename ${LOCI_BED} .bed)

########################## MAIN #########################

# Calculte depth for each site using samtools depth
# See more information from http://www.htslib.org/doc/samtools-depth.html

# samtools depth non-default option description
# -q "Only count reads with base quality greater than or equal to INT" 
# -Q "Only count reads with mapping quality greater than or equal to INT"  
# -J "Include reads with deletions in depth computation"
# -s "For the overlapping section of a read pair, count only the bases of the first read. Note this algorithm changed in 1.13 so the results may differ slightly to older releases."
samtools depth -a -q ${BQ} -Q ${MQ} -J -s -b ${LOCI_BED} ${BAMFILE} \
> ${BAMBASE}.q${BQ}.Q${MQ}.${LOCI_BASE}.site.depth

# Apply coverage filter and convert to bed format
awk -v MIN_DEPTH=${DEPTH_FILT} '{if($3>=MIN_DEPTH) print $1, $2-1, $2, $3}' OFS="\t" ${BAMBASE}.q${BQ}.Q${MQ}.${LOCI_BASE}.site.depth \
> filt_${DEPTH_FILT}_${BAMBASE}.q${BQ}.Q${MQ}.${LOCI_BASE}.site.depth.bed

# Calculate depth for each separate annotated locus
bedtools coverage -a ${LOCI_BED} -b filt_${DEPTH_FILT}_${BAMBASE}.q${BQ}.Q${MQ}.${LOCI_BASE}.site.depth.bed \
> ${BAMBASE}.q${BQ}.Q${MQ}.${LOCI_BASE}.depth${DEPTH_FILT}.region.cov

# Delete filtered per site depth file
rm filt_${DEPTH_FILT}_${BAMBASE}.q${BQ}.Q${MQ}.${LOCI_BASE}.site.depth.bed

########################## END ##########################
