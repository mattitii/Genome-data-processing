#!/bin/bash

set -o errexit
set -o nounset

################## SCRIPT INFORMATION ##################

if [ "$1" == "-h" ]; then
  echo -e "\n########################################################"
  echo -e "################## SCRIPT INFORMATION ##################"
  echo -e "########################################################"
  echo -e "\nThis script collects data from multiple column-based text files (no headers assumed) and combines a slice of columns into one file"
  echo -e "Prior to combing the script takes a slice of columns and checks that they have identical values relative to a template file which is the first file in the input list of files"
  echo -e "\nVersion collect_tables_v0.1.sh by Tiina M. Mattila 08-10-2021"
  echo -n -e "\nUsage: `basename $0` <list of files to combine> <common columns start e.g. 1> <common columns end e.g. 8> "
  echo -e "<columns to combine start> <columns to combine end> <a list of shared column names of a form col1|col2|> <full path to your temporary directory> <output prefix>"
  echo -e "\n########################################################"
  echo -e "################ SCRIPT INFORMATION END ################"
  echo -e "########################################################\n"
  exit 0
fi

##################### INPUT VARIABLES ###################

# Input variables
TABLE_LIST=$1 # A list of table files
COLS_CHECK_START=$2 # Shared columns start
COLS_CHECK_END=$3 # Shared columns end
COL_PASTE_START=$4 # A start column to combine from multiple files (using paste)
COL_PASTE_END=$5 # Columns to combine end
COMMON_NAMES=$6 # List of shared column names, for example "chrom|start|end|all _original _.gff_start|all_original_.gff_end|all_original_strand|all_original_frame|all_original_attributes"
TMP_DIRECTORY=$7 # Path to your temporary file path
OUTPUT_NAME=$8 # Output prefix for the merged results table

########################## MAIN #########################

## Check data matching

# Take the first datafile as a test template
file_1=`head -n 1 ${TABLE_LIST}`
echo "Using the file ${file_1} as a template"

# Write shared columns into a temporary file
echo -e ${COMMON_NAMES} > ${TMP_DIRECTORY}/shared.tmp
awk -F "\t" -v CSTART=${COLS_CHECK_START} -v CEND=${COLS_CHECK_END} '{ for (i=CSTART; i<=CEND;i++) printf("%s%s", $i,(i==CEND) ? "\n" : OFS="|") }' ${file_1} \
>> ${TMP_DIRECTORY}/shared.tmp

# Test if the values in defined columns match line-by-line
for datafile in `sed 1d ${TABLE_LIST}`; do
  MATCH_TEST=`diff \
  <(awk -F "\t" -v CSTART=${COLS_CHECK_START} -v CEND=${COLS_CHECK_END} '{for(i=CSTART; i<=CEND;i++) printf $i" "; print ""}' ${file_1}) \
  <(awk -F "\t" -v CSTART=${COLS_CHECK_START} -v CEND=${COLS_CHECK_END} '{for(i=CSTART; i<=CEND;i++) printf $i" "; print ""}' ${datafile})`
  [ -z "${MATCH_TEST}" ] && echo "Files ${datafile} & ${file_1} matching at the shared column slice" || { echo "WARNING! File ${datafile} not matching the template file ${file_1} at the shared column slice. Check your input files"; exit 0; }
done

# Collect data from the columns of interest
temp_files=""

for file in `cat ${TABLE_LIST}` ; do
  for rep in $(seq ${COL_PASTE_START} ${COL_PASTE_END}); do
    if [[ ${rep} < ${COL_PASTE_END} ]]
    then
      echo -e -n "${file}" "|"
    else
      echo -e "${file}"
    fi
  done > ${TMP_DIRECTORY}/${file}.tmp
  awk -F "\t" -v CSTART=${COL_PASTE_START} -v CEND=${COL_PASTE_END} '{ for (i=CSTART; i<=CEND;i++) printf("%s%s", $i,(i==CEND) ? "\n" : OFS="|") }' ${file} >> ${TMP_DIRECTORY}/${file}.tmp
  temp_files+="${TMP_DIRECTORY}/${file}.tmp "
done

# Paste extracted columns from each file
echo "Files to be pasted:" ${temp_files}
paste -d "|" ${TMP_DIRECTORY}/shared.tmp ${temp_files} > ${OUTPUT_NAME}.combined.txt

# Remove temporary files
rm ${TMP_DIRECTORY}/shared.tmp ${temp_files}

########################## END ##########################