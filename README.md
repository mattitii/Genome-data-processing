# Genome data processing

To get running information for the bash scripts do\
`script.sh -h`

## 1. Region coverage calculation
This pipeline reports sequencing depth and coverage for selected genes extracted from gff annotation file. 
The workflow is divided into three steps described below.

>_*External programs*_\
bedtools https://bedtools.readthedocs.io/en/latest/ (version tested bedtools 2.29.0)\
samtools http://samtools.sourceforge.net/ (version tested samtools 1.13)

### *STEP 1*
-------------
**Requires bedtools**\
First, a user defined set of genes (see e.g. `data/loci_SET5.txt`) and annotations per gene (e.g. CDS) will be extracted from the provided gff file.
Overlapping elements will be merged to a single entry.\
\
Usage:\
`loci_extractor_v0.3.sh <gff annotation file> 
<a list of candidate gene IDs, one ID per line>
<type of annotation to include e.g. CDS or exon>
<number of bases to extend around start and end points of each element>
<output prefix>`\
\
For example:\
`loci_extractor_v0.3.sh GRCh37_latest_genomic.gff example_data/loci_SET5.txt CDS 2 example_output`

The gff can be downloaded from
https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh37_latest/refseq_identifiers/GRCh37_latest_genomic.gff.gz
\
The script will produce two output files:
1. `<input gff file name>_gene_annotations.list`\
This file contains a list of "gene" annotations corresponding to the input list of gene names. This file can be used to review the success of loci fetching
2. `<input gff file name>_<element name>_extension<number of bases to end extend>_collapsed.bed`\
This file contains the details of the defined elements for locus of interest. Overlapping elements will be merged.

### *STEP 2*
-------------
**Requires bedtools & samtools**\
Using the region file generated in the step 1, we can now calculate the per site depth and region coverage (user defined minimum depth, base quality & mapping quality) using the script `region_coverage_calculator_v0.1.sh`\
\
Usage:\
`region_coverage_calculator_v0.1.sh <your bam file> <bed file containing coordinates of interest> <per site depth filter threshold> <base quality minimum value> <mapping quality minimum value>`\
\
For example:\
`region_coverage_calculator_v0.1.sh bamfile.bam example_output_extension2_collapsed.bed 7 30 20`\
\
Two output files will be generated per bamfile:
1. `<bamfile name>.q<base quality min value>.Q<mapping quality minimum value>.<region file name>.site.depth`\
This file contains depths for each site described in the region file
3. `<bamfile name>.q<base quality min value>.Q<mapping quality minimum value>.<region file name>.depth<depth minimum value>.region.cov`\
This file contains coverage counts for each separate element in the region .bed file

### *STEP 3*
-------------
If you have ran the analysis for multiple samples with the same set of loci, the collection of results into a single file can be done using the 
`collect_tables_v0.1.sh` script.\
\
Usage:` collect_tables_v0.1.sh <list of files to combine> <common columns start e.g. 1> <common columns end e.g. 8> <columns to combine start> <columns to combine end> <a list of shared column names of a form col1|col2|etc.> <full path to your temporary directory> <output prefix>`\
\
For example:\
`collect_tables_v0.1.sh tab_delimited_table_files_to_merge.list 1 8 12 12 "column1|column2|etc." /tmp combined_coverages_output`\
\
This script will generate a combined pipe separated file containing the defined columns. The combined columns will be named based on the original input file names.


## How to cite
If you use this code in your work, please cite
**TBA**\
\
**Do not forget to cite the dependent external programs**
