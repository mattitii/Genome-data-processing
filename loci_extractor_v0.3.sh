#!/bin/bash

set -o errexit
set -o nounset

################## SCRIPT INFORMATION ##################

if [ "$1" == "-h" ]; then
  echo -e "\n########################################################"
  echo -e "################## SCRIPT INFORMATION ##################"
  echo -e "########################################################"
  echo -e "\nThis script extracts user defined annotations (for example CDS) for genes of interest form gff3 annotation file,\
 merges overlapping annotations within each gene, and extends the ends of each annotation (user defined amount of bases)\n"
  echo -e "Version loci_extractor_v0.3.sh by Tiina M. Mattila 18-10-2021\n"
  echo -e "Change log:"
  echo -e "Version >=0.2 includes saving the list of genes"
  echo -e "Version >=0.3 requires external loading of bedtools\n"
  echo -e "Usage: `basename $0` <gff3 annotation file> <a list of candidate gene IDs, one ID per line> \
<type of annotation to include e.g. "CDS" or "exon"> <number of bases to extend around start and end points of each element> <output prefix>\n"
  echo -e "NOTES!"
  echo -e "1. The gene ID needs to present in the annotation description column of the annotation file in a form 'gene=<your gene>;'. \
Check this by running \n\ngrep 'gene=<your gene ID>;' <your_annotation_file>.gff\n"
  echo -e "2. Requires bedtools. Tested on bedtools v.2.29.0"
  echo -e "3. All the functions are case sensitive so make sure that the candidate genes and annotations of interest correspond to the spelling in your original annotation file"
  echo -e "4. The collapsing is done per gene. Genes with overlapping genomic coordinates will be handled as separate units"
  echo -e "\n########################################################"
  echo -e "################ SCRIPT INFORMATION END ################"
  echo -e "########################################################\n"
  exit 0
fi

##################### INPUT VARIABLES ###################

# Input variables
ANNOTATION=$1 # Annotation gff file
CAND_GENES=$2 # List of candidate genes, one gene per one row
ANNO_TYPE=$3 # Type of annotations to include
END_EXTENSION=$4 # If you want to extend the borders of the regions included by defined number of bases, add it here, otherwise use 0
OUT_PREFIX=$5 # Output prefix

########################## MAIN #########################

# Get a list of gene annotations
echo "A list of gene annotations" > ${OUT_PREFIX}_gene_annotations.list

for GENE in `cat ${CAND_GENES}`; do
  zgrep "ID=gene-${GENE};" ${ANNOTATION} | \
awk -F "\t" -v GENENAME=${GENE} '{if($3=="gene") print GENENAME, $$0}' OFS="\t" >> ${OUT_PREFIX}_gene_annotations.list
done

# Fetch all annotations that match the defined annotation type per gene
# Merge overlapping exons & collapse information from the original gff start and stop, strand, frame and attribute columns using -c and -o

for GENE in `cat ${CAND_GENES}`; do
  # Get the defined annotation and merge
  zgrep "gene=${GENE};" ${ANNOTATION} | \
awk -F "\t" -v ATYPE=${ANNO_TYPE} '{if($3==ATYPE) print $0}' | \
sort -k1,1n -k4,4n | \
bedtools merge -i - -c 4,5,7,8,9 -o collapse |
awk -F "\t" -v ENDE=${END_EXTENSION} '{print $1, $2-ENDE, $3+ENDE, $4, $5, $6, $7, $8}' OFS="\t"
done > ${OUT_PREFIX}_${ANNO_TYPE}_extension${END_EXTENSION}_collapsed.bed

########################## END ##########################
