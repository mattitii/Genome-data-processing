# Genome data processing

To get running information for the bash scripts\
`script.sh -h`

## Region coverage calculation
This pipeline reports seqeuencing depth and coverage for selected genes extracted from gff annotation file. 
The workflow is divided into three steps described below.\

>_*External programs*_\
bedtools https://bedtools.readthedocs.io/en/latest/ (version tested bedtools 2.29.0)\
samtools http://samtools.sourceforge.net/ (version tested samtools 1.13)

### *STEP 1*
-------------
**Requires bedtools**\
First, a user defined set of genes (see e.g. `data/loci_SET5.txt`) and annotations per gene (e.g. CDS) will be extracted, 
and overlapping elements will be merged to a single entry.\

For example\
`loci_extractor_v0.3.sh GRCh37_latest_genomic.gff example_data/loci_SET5.txt CDS 2 example_output`

### *STEP 2*
-------------
**Requires bedtools & samtools**\
Using the region file from the step 1 we can now calculate the per site depth and region coverage (user defined minimum depth, base quality & mapping quality) using the script `region_coverage_calculator_v0.1.sh`

For example\
`region_coverage_calculator_v0.1.sh <your bamfile> example_output_extension2_collapsed.bed 7 30 20`

### *STEP 3*
-------------
If you have ran the analysis for multiple samples with the same set of loci, the collection of results into a single file can be done using the 
`collect_tables_v0.1.sh` script.

For example\
`collect_tables_v0.1.sh tab_delimited_table_files_to_merge.list 1 8 12 12 "column1|column2|etc." /tmp combined_set_coverages_output
`

## How to cite
If you use this code in your work, please cite
**TBA**\
\
**Do not forget to cite the dependent external programs**
