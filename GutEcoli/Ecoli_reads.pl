#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename dirname);

my @file=glob "/home/zhangwen/project/2022Time/WGS_Data/Time/*_R1.fq.nohuman";

foreach my $fq1 (@file) {
		my $fq2=substr ($fq1,0,length($fq1)-14)."_R2.fq.nohuman";
		my $name=basename($fq1);
		$name=substr ($name,0,length($name)-14);
		system "/home/zhangwen/bin/bowtie2-2.4.4-linux-x86_64/bowtie2  -x Ecoli_genome.fasta -1 $fq1 -2 $fq2 -S $name.sam --al-conc $name.Ecoli.fq\n";
}