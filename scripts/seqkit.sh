#!/bin/bash

# get fastq file
fastqs=( $(find ../data/fastq/ -type f -name "*.fastq.gz" -exec readlink -f {} \;) )

for fastq in ${fastqs[@]}; do

    # get file name
    prefix=$(basename -s ".fastq.gz" $fastq)
        
    echo "processing: $prefix"
            
    # out dir
    out="../data/qc"
    mkdir -p $out
    
    # run seqkit
    seqkit fx2tab \
        $fastq \
        --name \
        --length \
        --avg-qual \
        > "$out/$prefix.tab"
        
    gzip -f "$out/$prefix.tab"

done