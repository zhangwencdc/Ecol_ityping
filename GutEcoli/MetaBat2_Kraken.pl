#!/usr/bin/perl
use strict;
#use warnings;

my $file=$ARGV[0]; #MetaBat2输出路径
my $sample=$ARGV[1]; #sample 名称
my $outdir=$ARGV[2];
open(SUM,">>MetaBat2.Kraken.sum");
	print SUM "Sample,Strain,Phylum,Order,Genus\n";
my @file=glob "$file/*.fa";

my $strain=0;
my $kraken2="kraken2";
my $bracken="/home/zhangwen/bin/Bracken/bracken";

foreach my $file (@file) {
	$strain++;

	my $strain_name=$sample."_Str".$strain;
	print "$file,$strain_name\n";
	open(FILE,$file);
	my $out=$strain_name.".fasta";
	open(OUT,">$outdir/$out");
	while(1){
		my $line=<FILE>;
		unless($line){print OUT "$line\n";last;}
		chomp $line;
		if(substr($line,0,1) eq ">"){
			my $contig=substr($line,1);
			print OUT ">$strain_name $contig\n";
		}else{
			print OUT "$line\n";
		}
	}
	close FILE;
	system "$kraken2 $outdir/$out -db /home/zhangwen/Data/Kraken2/minikraken2_v2_8GB_201904_UPDATE --report $outdir/$strain_name.report --out $outdir/$strain_name.out\n";
	open(F,"$outdir/$strain_name.report");my $phylum;my $order;my $genus;
	while(1){
		my $line=<F>;
		unless($line){last;}
		chomp $line;
		my @a=split"\t",$line;
		my $taxon=pop @a;
		$taxon=~s/\s//g;
		#print "$a[3]\t$a[0]\n";
		if($a[3] eq "P" && $a[0]>=50){$phylum=$taxon;}
		if($a[3] eq "O" && $a[0]>=50){$order=$taxon;}
		if($a[3] eq "G" && $a[0]>=50){$genus=$taxon;}
	}
	close F;

#	 system "$bracken -d /home/zhangwen/Data/Kraken2/minikraken2_v2_8GB_201904_UPDATE -i $outdir/$strain_name.report -o $outdir/$strain_name.genus -l G\n";
#	  system "$bracken -d /home/zhangwen/Data/Kraken2/minikraken2_v2_8GB_201904_UPDATE -i $outdir/$strain_name.report -o $outdir/$strain_name.order -l O\n";
#	  my $order;
#open(FILE,"$outdir/$strain_name.order");
#                while(1){
#                        my $line=<FILE>;
#                        unless($line){last;}
#                        chomp $line;
#                        my @a=split"\t",$line;
#                        if($a[0]=~/name/){next;}
#                        unless($a[6]>=0.9){next;} ###90%以上contig支持该分类
#                        $order=$a[0];
#                       
#                }
#                close FILE;
#
#               
#my $genus;
#open(FILE,"$outdir/$strain_name.genus");
#                while(1){
#                        my $line=<FILE>;
#                        unless($line){last;}
#                        chomp $line;
#                        my @a=split"\t",$line;
#                        if($a[0]=~/name/){next;}
#                        unless($a[6]>=0.9){next;} ###90%以上contig支持该分类
#                        $genus=$a[0];
#                       
#                }
#                close FILE;
			print  "$sample,$strain,$phylum,$order,$genus\n";
				print SUM "$sample,$strain_name,$phylum,$order,$genus\n";
}
