#!/bin/bash
cd AbdelRahman\ Stuff/01_Education/EGCompBio/02_NGS/6_Gradproj/ # Load Working directory
mamba activate mapping_qc
samples=(SRR31565142 SRR31565143 SRR31565144 SRR31565169 SRR31565170 SRR31565171)



for sample in "${samples[@]}";do
    echo "Processing $sample..."
    prefetch "$sample"
    fasterq-dump "$sample" --split-files --threads 6
done
mkdir before_trim after_trim multiqc_before multiqc_after
fastqc *.fastq -o before_trim

mutliqc before_trim -o multiqc_before

for f1 in *_1.fastq; do
    f2=${f1%_1.fastq}_2.fastq
    sample=${f1%_1.fastq}
    
    trimmomatic PE "$f1" "$f2" \
    "${sample}_1_paired.fq.gz" "${sample}_1_unpaired.fq.gz" \
    "${sample}_2_paired.fq.gz" "${sample}_2_unpaired.fq.gz" \
    ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36
done

fastqc *_paired.fq.gz -o after_trim

mutliqc after_trim -o multiqc_after


