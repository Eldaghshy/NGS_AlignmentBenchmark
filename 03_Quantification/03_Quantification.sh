#!/bin/bash
# Quantification Script for Graduation Project

GTF="gencode.v49.basic.annotation.gtf" # Ensure this file is in your folder
THREADS=6

# echo "Starting FeatureCounts for Bowtie2 (Transcriptome)..."
# featureCounts -p -T $THREADS -t exon -g gene_name \
#     -a $GTF \
#     -o bowtie_counts_matrix.txt \
#     bowtie_results/*.bam
# echo "Quantification complete. Matrices created: hisat_counts_matrix.txt"


echo "Starting FeatureCounts for HISAT2 (Genome)..."
# Note: HISAT2 BAMs contain spliced alignments; featureCounts handles this automatically with -p
featureCounts -p -B -C -T 6 \
    -t exon -g gene_name \
    -a 00_rawdata/03_annotation/gencode.v49.basic.annotation.gtf \
    -o hisat_counts_matrix.txt \
    05_Alignment/04_hisat_results/*.bam

echo "Quantification complete. Matrices created: hisat_counts_matrix.txt"