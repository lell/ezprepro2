# Set the following variable to the full path to the directory containing UKB bgen files (these have filenames ukb_imp_chr*_v3.bgen). Include the trailing forward slash.
BGEN=

# Set the following variable to the full path to a sample file describing one of the autosomal bgen files in $BGEN (this can be constructed using https://www.cog-genomics.org/plink/2.0/formats#sample and a file listing the sample IDs of UKB).
SAMPLE=

# Set the following variable to the full path to a smaple file describing the X and XY bgen files in $BGEN, such that $(SAMPLE_SEX)_chrX.sample is the sample file for the X chromosome bgen file, and $(SAMPLE_SEX)_chrXY.sample is the sample file for the XY chromosome (pseudoautosomal) bgen file.
SAMPLE_SEX=

# Set the following variable to the full path to the FAM file describing the UKB samples.
FAM=

# Set the following variable to the full path to the UKB Sample-QC file described here: https://biobank.ctsu.ox.ac.uk/crystal/refer.cgi?id=531 there are two versions of the file, use the version that has PC1 in column 24.
SQC=

# Set the following variable to the full path of a file containing the RSIDs of the markers that are on the UKB chip (i.e., non-imputed RSIDs)
CHIP=

# Set the following variable to 1GB less than the maximum memory allowed per PBS job (provide in MB)
MAXMEM=
