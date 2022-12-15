#!/usr/bin/env Rscript

##===================
## script to create annotations for LDSC 
## with respect to input set of variants
##===================
library(data.table)
library(dplyr)
options(scipen = 10)
options(datatable.fread.datatable=FALSE)

args <- commandArgs(TRUE)
GENOTYPEDIR <- as.character(args[1])
GENOTYPEPREFIX <- as.character(args[2])
QTLFile <- as.character(args[3])
VariantType <- as.character(args[4])
chrcol <- as.integer(args[5])
poscol <- as.integer(args[6])
AnnotDir <- as.character(args[7])

system(paste("mkdir -p", AnnotDir))

QTLData <- data.table::fread(QTLFile, header=T)
QTLData <- unique(QTLData[, c(chrcol, poscol)])
cat(sprintf("\n\n Input QTL file : %s -- number of unique entries : %s ", QTLFile, nrow(QTLData)))

chrlist <- as.vector(unique(QTLData[,1]))
for (i in 1:length(chrlist)) {
	currchr <- chrlist[i]
	chrnum <- gsub("chr", "", currchr)
	cat(sprintf("\n Processing chromosome : %s number : %s ", currchr, chrnum))
	bimfile <- paste0(GENOTYPEDIR, '/', GENOTYPEPREFIX, '.', chrnum, '.bim')
	if (file.exists(bimfile) == FALSE) {
		next
	}
	outfile <- paste0(AnnotDir, '/out.', chrnum, '.annot')	
	if (file.exists(paste0(outfile, ".gz"))) {
		next
	}

	QTLData_currchr <- QTLData[which(QTLData[,1] == currchr), ]
	cat(sprintf("\n Number of QTLs for this chromosome : %s ", nrow(QTLData_currchr)))
	## remove the "chr" string
	QTLData_currchr[,1] <- as.integer(gsub("chr", "", QTLData_currchr[,1]))
	## define eQTL annotation
	QTLData_currchr$NEWFIELD <- rep(1, nrow(QTLData_currchr))
	colnames(QTLData_currchr) <- c('CHR', 'BP', VariantType)

	bimdata <- data.table::fread(bimfile, header=F)
	bimdata <- bimdata[, c(1,4,2,3)]
	colnames(bimdata) <- c('CHR', 'BP', 'SNP', 'CM')

	## annotation data frame
	AnnotDF <- dplyr::left_join(bimdata, QTLData_currchr)
	idx <- which(is.na(AnnotDF[, ncol(AnnotDF)]))
	if (length(idx) > 0) {
		AnnotDF[idx, ncol(AnnotDF)] <- 0
		cat(sprintf("\n NA (non-matching bim file entries) : %s ", length(idx)))		
	}

	## write the output annotations	
	write.table(AnnotDF, outfile, row.names=F, col.names=T, sep="\t", quote=F, append=F)
	system(paste("gzip", outfile))
}


