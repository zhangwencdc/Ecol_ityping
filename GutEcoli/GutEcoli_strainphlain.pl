#!/usr/bin/perl
use strict;
use warnings;

#启动conda环境
#conda activate biobakery

#输入文件
my $file=$ARGV[0];
open(F,$file);
my %name;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split"\t",$l;
	$name{$a[0]}=$l;
}
close F;

#Stainphlain

my $ecoli="/home/zhangwen/Data/Metaphlan/marker_db/Escherichia_coli.markers.fa";
my @name=sort keys %name;
system "mkdir sams bowtie2 profiles consensus_markers\n";
foreach my $name (@name) {
	my $l=$name{$name};
	my @a=split"\t",$l;
	my $fq1=$a[1];my $fq2=$a[2];
	
	system " metaphlan $fq1,$fq2 --input fastq -s sams/$name.sam.bz2 --bowtie2out bowtie2/$name.bowtie2.bz2 -o profiles/$name.profile.tsv \n";
	system "sample2markers.py -i sams/$name.sam.bz2 -o consensus_markers -n 8\n";
}
system "strainphlan -m $ecoli -s consensus_markers/*.pkl -o ./ -n 8 -c Escherichia_coli --mutation_rates\n";