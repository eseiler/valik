#!/bin/bash
cd dream
set -Eeuo pipefail

#----------- Simulate chromosomes of various lengths -----------

SEED=${1}

error_rate=0.025
read_length=150
read_dir=reads_$read_length
mkdir -p $read_dir
read_count=10

i=1
for length in 1023 2300 3030
do
    echo "Simulating chromosome with length $length"
    chr_out="chr"$i".fasta"
    mason_genome -l $length -o $chr_out -s $SEED &>/dev/null

    sed -i "s/^>.*$/>chr$i/g" $chr_out
    let i=i+1

    #----------- Sample reads from reference sequence -----------
    echo "Generating $read_count reads of length $read_length with error rate $error_rate"
    generate_local_matches \
        --output $read_dir \
        --max-error-rate $error_rate \
        --num-matches $read_count \
        --min-match-length $read_length \
        --max-match-length $read_length \
        --verbose-ids \
        --reverse \
        --ref-len $length \
        --seed $SEED \
        $chr_out
done

cat chr*.fasta > ref.fasta
rm chr*.fasta

cat $read_dir/chr*.fastq > query.fastq
rm -r $read_dir
