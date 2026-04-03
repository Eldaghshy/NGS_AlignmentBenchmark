# NGS_AlignmentBenchmark
This is a personal project done for graduating from NGS course provided by EGCompBio. 
The repo explains the RNA-Seq pipeline done by 3 different aligners to see how they compete in terms of time & memory consumption as resources. 
Also, we see how they compete in terms of accuracy for downstream analysis as well.


1- Data Download

-It was done using SRAtool kit using prefetch to download the samples from SRA, then were converted to fastq files using fasterq-dump

-The samples were 3 Tumor & 3 Normal samples out of Lung Adenocarcinoma project (Bioproject ID: PRJNA1192953)


2- QC

-Fastqc was performed on the 6 samples, there was adaptor content when inspected which was removed using Trimmomatic and ran Fastqc again showing that the adaptor was removed.

-Sequence quality was very promising, yet the duplication rate was quite concerning but proceeded for the next steps


3-Alignment

-This step was quite interesting as I used reference cDNA from ensemble on bowtie2 first, what was interesting that the alignment rate was very low (~20-25%).

-This resulted in choosing Gencode transcript fasta file as a reference and the alignment went up to (~50-60%) in bowtie2

-The time bowtie2 consumed was quite a lot, which made it even more interesting to test more tools which were kallisto and hisat2 and the benchmark started here.

-I ran timer over each type of alignment bowtie2 & kallisto using gencode transcript fasta file as a reference while hisat2 (since it is splice aware aligner),
I used the primary assembly reference genome 

-Memory and time consumed by each aligner was calculated and as result:
a)Kallisto was very fast with high alignment and assignment rate
b)Hisat2 had a very strong alignment rate but lower assignment rate than kallisto and in terms of speed it came 2nd to kallisto
c)bowtie2 slowest, less alignment than hisat2 and no assignment 


4-Differential expression
-DESeq2 was ran over the hisat2 and kallisto counts and they was PCA generated for each showing that both had close results to each other in terms of variance between samples
