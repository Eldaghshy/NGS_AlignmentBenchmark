###########################################
# 1- Reading count data & loading libraries
###########################################
library("tximport")
library("rhdf5")
library("dplyr")
library("ggplot2")
library("DESeq2")
library("PCAtools")
library("stringr")
library("rtracklayer")
setwd("AbdelRahman Stuff/01_Education/EGCompBio/02_NGS/6_GradProj/")

# Define your sample IDs (must match your folder names exactly)
samples = c("SRR31565142", "SRR31565143", "SRR31565144", 
             "SRR31565169", "SRR31565170", "SRR31565171")

# Create a metadata table
info = data.frame(
  sample = samples,
  condition = rep(c("Tumor", "Normal"),3),
  row.names = samples
)

# Load your GTF file
gtf_data = import("00_rawdata/03_annotation/gencode.v49.basic.annotation.gtf")

# Convert to data frame and extract transcript-to-gene mapping
tx2gene = as.data.frame(gtf_data) %>%
  filter(type == "transcript") %>%
  select(transcript_id, gene_name) 

# Take a look to make sure it's correct
head(tx2gene)
# Path to all abundance files
files = file.path("05_Alignment/03_kallisto_results", samples, "abundance.tsv")
names(files) = samples

# Re-run tximport but aggregate to Gene level
# Import and aggregate transcripts to gene level
txi_kallisto = tximport(files, type = "kallisto", tx2gene = tx2gene, ignoreAfterBar = TRUE)
kallisto_counts = as.data.frame(txi_kallisto$counts)
kallisto_counts$Geneid = rownames(kallisto_counts)

# This creates your count matrix
kallisto_counts = txi_kallisto$counts
load_fc = function(filename) {
  #Read the file, skipping the first line (metadata)
  df = read.table(filename, header = TRUE, skip = 1, check.names = FALSE)
  
  # Keep only Geneid and the sample columns (Columns 7 and onwards)
   #Then rename the columns to just the Sample IDs
   counts = df[, c(1, 7:ncol(df))]
   colnames(counts)[2:ncol(counts)] = str_extract(colnames(counts)[2:ncol(counts)], "SRR[0-9]+")
  
 return(counts)
}

hisat_counts = load_fc("05_Alignment/04_hisat_results/counts/hisat_counts_matrix.txt")
rownames(hisat_counts) = hisat_counts$Geneid
hisat_counts$Geneid = NULL
dds_hisat <- DESeqDataSetFromMatrix(countData = hisat_counts, colData =  info, design = ~ condition)
dds_hisat <- DESeq(dds_hisat)
res_hisat <- results(dds_hisat)


dds_kallisto <- DESeqDataSetFromTximport(txi_kallisto, info , ~condition)
dds_kallisto <- DESeq(dds_kallisto)
res_kallisto <- results(dds_kallisto)

vsd_h <- vst(dds_hisat, blind=FALSE)
vsd_k <- vst(dds_kallisto, blind=FALSE)

plotPCA(vsd_h, intgroup="condition") # Save as HISAT_PCA.png
plotPCA(vsd_k, intgroup="condition") # Save as Kallisto_PCA.png
###################################
# 4- Alignment resource consumption
###################################
bench_data = read.csv("benchmarks_stats.csv")
bench_data = bench_data %>% mutate("Time_min" = Time_Sec/60) %>% mutate("Memory_GB" = Mem_KB / (1024)^2)

# Quick plot to see who won the speed race
ggplot(bench_data, aes(x = Tool, y = Time_min, fill = Tool)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Alignment Speed Comparison", y = "Minutes")


ggplot(bench_data, aes(x = Tool, y = Memory_GB, fill = Tool)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Alignment Memory Consumption", y = "Memory in GB")

# We notice that Kallisto takes least time, hisat2 coming after it and 
