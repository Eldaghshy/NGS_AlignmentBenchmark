#!/bin/bash
# High-impact benchmark for tired scientists

SAMPLES=("SRR31565142" "SRR31565143" "SRR31565144" "SRR31565169" "SRR31565170" "SRR31565171")
THREADS=6

echo "Tool,Sample,Time_Sec,Mem_KB" > benchmarks_stats.csv

# Helper to time things
run_b() {
    /usr/bin/time -f "$1,$2,%e,%M" -a -o benchmarks_stats.csv sh -c "$3"
}

# --- KALLISTO (Quant Env) ---
eval "$(conda shell.bash hook)"
conda activate quant
for s in "${SAMPLES[@]}"; do
    run_b "Kallisto" "$s" "kallisto quant -i kallisto_index/gencode_v49.idx -o kallisto_results/${s} -t $THREADS ${s}_1_paired.fq.gz ${s}_2_paired.fq.gz"
done

# --- BOWTIE2 & HISAT2 (Mapping_QC Env) ---
conda activate mapping_qc
mkdir -p bowtie_results hisat_results # making sure these exist
for s in "${SAMPLES[@]}"; do
    # Bowtie2: Index is bowtie2_index/gencode_v49_tx
    run_b "Bowtie2" "$s" "bowtie2 -p $THREADS -x bowtie2_index/gencode_v49_tx -1 ${s}_1_paired.fq.gz -2 ${s}_2_paired.fq.gz | samtools view -bS - | samtools sort -o bowtie_results/${s}_tx.bam"
    
    # HISAT2: Index is hisat2_index/hg38_genome
    run_b "HISAT2" "$s" "hisat2 -p $THREADS --dta -x hisat2_index/hg38_genome -1 ${s}_1_paired.fq.gz -2 ${s}_2_paired.fq.gz | samtools view -bS - | samtools sort -o hisat_results/${s}_gen.bam"
done