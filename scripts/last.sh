#!/bin/bash

# get fastq file
fastqs=( $(find ../data/fastq/ -type f -name "*.fastq.gz" -exec readlink -f {} \;) )

for fastq in ${fastqs[@]}; do

    # get file name
    prefix=$(basename -s ".fastq.gz" $fastq)
    
    # get reference
    fasta=( $(find ../data/reference -type f -name "*${prefix:0:2}*.fasta") )
    
    echo "processing: $prefix using $fasta reference"
            
    # out dir
    out="../data/bam"
    mkdir -p $out
    
    index="$out/index/${prefix:0:2}"
    mkdir -p $(dirname $index)
    
    # make index
    lastdb -P6 -uNEAR $index $fasta
    
    # determine substitution and gap rates
    last-train -P6 -Q0 -D1e4 $index $fastq \
        > $out/$prefix.par

    # aligning DNA sequences
    lastal -P6 -Q0 --split-n -p $out/$prefix.par $index $fastq \
        > $out/$prefix.maf

    # convert to sam
    maf-convert -j1e6 sam -d $out/$prefix.maf \
        > $out/$prefix.sam

    # sort bam
    samtools view -u -F 256 \
        $out/$prefix.sam \
        | samtools sort \
        -o $out/$prefix.bam
    
    # remove sam, par, and maf
    rm $out/$prefix.sam
    rm $out/$prefix.maf
    rm $out/$prefix.par
    
    # index bam
    samtools index $out/$prefix.bam

done