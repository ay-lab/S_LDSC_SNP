# S_LDSC_SNP
Adaptation of Stratified LD score regression (LDSC) 
to compute enrichment of a set of SNPs
(such as eQTLs)

Sourya Bhattacharyya

La Jolla Institute for Immunology, La Jolla, CA 92037, USA

----------------------

Implements a wrapper for the Stratified LD score regression package (https://github.com/bulik/ldsc), to estimate the enrichment of a set of QTLs (variants) with respect to a reference GWAS summary statistics.

Traditionally, LD score regression computes enrichment of a chromatin annotation, such as ChIP-seq peaks.

Here, we have implemented an interface to take input a list of SNPs (such as eQTLs, eQTLs overlapping chromatin peaks, etc.)
to compute their enrichment with respect to reference GWAS studies.

Note: Currently the package supports GWAS files with respect to the reference genome hg19 
(as mentioned in the original Stratified LD score regression package ldsc)

For GWAS files with hg38 reference genome configuration, users are requested to first use 
the liftover tool (https://genome.ucsc.edu/cgi-bin/hgLiftOver) to convert the genomic coordinates 
from hg38 to hg19.

Prerequisites
==============

1. Install these R libraries: data.table, dplyr, GenomicRanges, gridExtra
2. Download the source code of "ldsc" from GitHub (https://github.com/bulik/ldsc). The path of this source code (containing the python and bash scripts of this package) need to be provided as a configuration parameter (check the parameter LDSCCodeDir)


Running the script
==================

First edit the configuration file (configfile_SNP). Then, run the script 

*qsub_S_LDSC_SNP_Based_job.sh*

It will invoke the stratified LD score regression analysis, with respect to the corresponding configuration file.

Output
========

With respect to the specified output directory (parameter *OutDir*), 

Check the file *.results

The first line of this file (category: L2_0) contains the enrichment statistic with respect to the given annotation (like the set of variants).

Specifically, the following fields are important:

1. *Prop._SNPs*  The proportion of SNPs (out of the total number of SNPs in the 1000G data) covered in the input set of variants.
2. *Prop._h2*   The proportion of heritabilty explained by the given set of variants.
3. *Prop._h2_std_error*   Standard error of the heritabilty explained by the given set of variants.
4. *Enrichment*    The most important output, namely the *heritability enrichment* of the given set of variants. A value > 1 means that the input variants exhibit enrichment. Higher value means higher enrichment.
5. *Enrichment_std_error*   Standard error associated with the enrichment statistics.


Contact
==========

For any queries, please create an issue and we'll respond. Otherwise, please e-mail

Sourya Bhattacharyya: sourya@lji.org

Ferhat Ay: ferhatay@lji.org






