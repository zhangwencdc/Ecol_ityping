#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin $Script);



my $fq1=$ARGV[0];
my $fq2=$ARGV[1];
my $name=$ARGV[2];
my $metabat="/home/zhangwen/bin/metabat/";

#Spades
system "metaspades.py -1 $fq1 -2 $fq2 -o $name\n";
system "seqkit seq -m 1000 $name/scaffolds.fasta > $name.fasta\n";
system "rm -rf $name\n";
my $genome=$name.".fasta";
#MetaBat
system "/home/zhangwen/bin/bowtie2-2.4.4-linux-x86_64/bowtie2-build --threads 30 $genome $genome\n";
   system "/home/zhangwen/bin/bowtie2-2.4.4-linux-x86_64/bowtie2 --threads 30 -x $genome -1 $fq1 -2 $fq2 | samtools sort --threads 30 -o $name.sort.bam - \n";
 system "$metabat/jgi_summarize_bam_contig_depths --outputDepth $name.depth.txt $name.sort.bam\n";
   system "$metabat/metabat2 -i $genome -a $name.depth.txt -o $name/$name\n";

##×¢ÊÍ
system "perl $Bin/MetaBat2_Kraken.pl $name $name $name\n";