#!/usr/bin/perl

=head1 Name

=head1 Description

=head1

  Author: zhangwen, zhangwen@icdc.cn
  Version: 1.0, Date: 2022-07-22
Escherichia MLST��������  ֧��Windows���������� 
v3:����ʽ���� 
=head1 Usage:

  --I  <str>*            input
  --Data <str>               Database
  --O  <str>*           output
  --help                     output help information to screen

=head1 Example

=cut
use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Data::Dumper;
#use warnings;
use Pod::Text;
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET=1;
##get options from command line into variables and set default values
###-----------------Time record-----------------------------###

print "Please input the genome file(Fasta format)....\n";
my $genome=<STDIN>;
chomp($genome);
unless(substr($genome,0,length($genome)-1)=~/[0-9a-zA-Z]/){$genome=substr($genome,0,length($genome)-1);}
unless(-e $genome){
	print "Error Input file\nPlease re-enter the input file\n";
	$genome=<STDIN>;
	
}
unless(-e $genome){
	print "Error Input file\nPlease re-enter the input file\n";
	$genome=<STDIN>;
	
}
unless(-e $genome){
	print "Error Input file\n";
	die;
	
}


my $date = &getTime();#��ȡ��ǰϵͳʱ���Hash

my $ymd = $date->{date};#��ȡyyyymmdd���������� 

my $year=$date->{year};#��ȡ��

my $month=$date->{month};#��ȡ��

my $day=$date->{day};#��ȡ��
print "Analysis running\nTime:$year/$month/$day \nWaiting for the run finished(2~3 minitues).\n And please Check the report file in your directory (Input_MLST_report.txt) after the run finish\n";

my ($tag,$outdir,$data);
if(!defined $tag){$tag="Input";}
if(!defined $outdir){$outdir=dirname($genome);}
if(!defined $data){$data=$Bin."/Escherichia_MLST_Data";}



my $file=$genome;#genome.fa
my $mlst=$data."/Achtman_7gene.fas";#mlst.fa
my $profile=$data."/Achtman_7gene_profile.txt";#mlst.profie
my $out=$outdir."/".$tag."_MLST_report.txt";

open(F,$profile);
my %type;
my $line=<F>;
unless(substr($line,length($line)-1,1)=~/[0-9a-zA-Z]/){$line=substr($line,0,length($line)-1);}
my @gene=split"\t",$line; my $complex=pop @gene;
my $gene_num=@gene;
$gene_num=$gene_num-1;

while(1){
	my $line=<F>;
	unless($line){last;}
	chomp $line;
	my @a=split"\t",$line;
	my $st=$a[1];
	foreach  (2..$gene_num) {
		$st=$st."_".$a[$_];
	}
	$type{$st}=$a[0];
	
}
close F;

open(F,$mlst);
my %mlst;my $name;my $seq="";
while(1){
	my $line=<F>;
	unless($line){if($name=~/[0-9a-zA-Z]/){$mlst{$name}=$seq;}last;}
	chomp $line;
	unless(substr($line,length($line)-1,1)=~/[0-9a-zA-Z]/){$line=substr($line,0,length($line)-1);}
	if(substr($line,0,1) eq ">"){
		if($name=~/[0-9a-zA-Z]/){$mlst{$name}=$seq;}
		$name=substr($line,1);$seq="";
	}else{
		$seq=$seq.$line;
	}
}
close F;

my @mlst=keys %mlst;
open STDOUT,">$outdir/test";
foreach my $mlst (@mlst) {
	my $type;
	open STDOUT,">>$outdir/test";
	print "$mlst,";
	system "$Bin/seqkit.exe grep -s -p $mlst{$mlst} -C $file \n";
	print "\n";
	#close STDOUT;
}



open(FILE,"$outdir/test");
open(OUT,">$out");my %gene;
print OUT "MLST Report\n Time:$year/$month/$day\n1 Achtman 7gene\n";
while(1){
	my $line=<FILE>;
	unless($line){last;}
	chomp $line;
	my @a=split",",$line;
	unless($a[1] >0){next;}
	my @gene=split"_",$a[0];
	my $g=@gene;
	if($g==2){
	$gene{$gene[0]}=$gene[1];print OUT "$gene[0]:$gene[1]\n";}elsif($g==3){my $tmp=$gene[0]."_".$gene[1];$gene{$tmp}=$gene[2];print OUT "$tmp:$gene[2]\n";}
	
}
close FILE;

my $p=$gene{$gene[1]};
foreach  (2..$gene_num) {
	$p=$p."_".$gene{$gene[$_]};
	#print OUT "$_,$gene[$_],$gene{$gene[$_]}\n";
}
my $st=$type{$p};
if($st=~/[0-9]/){print OUT "Achtman 7 Locus MLST type: $st\n";}else{print OUT "No necessary infor\n";}
print "Achtman 7 Locus MLST type: $st\n";

#print OUT "2 MLST_21_loci\n";
my $mlst=$data."/Pasteur_8gene.fas";#mlst.fa
my $profile=$data."/Pasteur_8gene_profile.txt";#mlst.profie


open(F,$profile);
my %type;
my $line=<F>;
unless(substr($line,length($line)-1,1)=~/[0-9a-zA-Z]/){$line=substr($line,0,length($line)-1);}
my @gene=split"\t",$line;
my $gene_num=@gene;
$gene_num=$gene_num-1;
print "Analysis for Gene Num: $gene_num\n";
while(1){
	my $line=<F>;
	unless($line){last;}
	chomp $line;
	my @a=split"\t",$line;
	my $st=$a[1];
	foreach  (2..$gene_num) {
		$st=$st."_".$a[$_];
	}
	$type{$st}=$a[0];
	
}
close F;

open(F,$mlst);
my %mlst;my $name;my $seq="";
while(1){
	my $line=<F>;
	unless($line){if($name=~/[0-9a-zA-Z]/){$mlst{$name}=$seq;}last;}
	chomp $line;
	unless(substr($line,length($line)-1,1)=~/[0-9a-zA-Z]/){$line=substr($line,0,length($line)-1);}
	if(substr($line,0,1) eq ">"){
		if($name=~/[0-9a-zA-Z]/){$mlst{$name}=$seq;}
		$name=substr($line,1);$seq="";
	}else{
		$seq=$seq.$line;
	}
}
close F;

my @mlst=keys %mlst;
open STDOUT,">$outdir/test";
foreach my $mlst (@mlst) {
	my $type;
	open STDOUT,">>$outdir/test";
	print "$mlst,";
	system "$Bin/seqkit.exe grep -s -p $mlst{$mlst} -C $file \n";
	print "\n";
	#close STDOUT;
}



open(FILE,"$outdir/test");
open(OUT,">>$out");my %gene;
print OUT "\n2 Pasteur 8gene MLST method\n";
while(1){
	my $line=<FILE>;
	unless($line){last;}
	chomp $line;
	my @a=split",",$line;
	unless($a[1] >0){next;}
	my @gene=split"_",$a[0];
	my $g=@gene;
	if($g==2){
	$gene{$gene[0]}=$gene[1];print OUT "$gene[0]:$gene[1]\n";}elsif($g==3){my $tmp=$gene[0]."_".$gene[1];$gene{$tmp}=$gene[2];print OUT "$tmp:$gene[2]\n";}
	
}
close FILE;

my $p=$gene{$gene[1]};
foreach  (2..$gene_num) {
	$p=$p."_".$gene{$gene[$_]};
	#print OUT "$_,$gene[$_],$gene{$gene[$_]}\n";
}
my $st=$type{$p};
if($st=~/[0-9]/){print OUT "Pasteur 8 Locus MLST type: $st\n";}else{print OUT "No necessary infor\n";}
close (STDOUT);
print "Pasteur 8 Locus MLST type: $st\n";


#====================================================================================================================
#  +------------------+
#  |   subprogram     |
#  +------------------+



sub sub_format_datetime #.....
{
    my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
        $wday = $yday = $isdst = 0;
    sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon, $day, $hour, $min, $sec);
}

sub getTime

{

   #time()�������ش�1970��1��1�����ۼ�����

    my $time = shift || time();

   
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);

   
    $mon ++;

    $sec  = ($sec<10)?"0$sec":$sec;#����[0,59]

    $min  = ($min<10)?"0$min":$min;#����[0,59]

    $hour = ($hour<10)?"0$hour":$hour;#Сʱ��[0,23]

    $mday = ($mday<10)?"0$mday":$mday;#����µĵڼ���[1,31]

    $mon  = ($mon<9)?"0".($mon):$mon;#����[0,11],Ҫ��$mon��1֮�󣬲��ܷ���ʵ�������

    $year+=1900;#��1900�����������

    #$wday�����������𣬴������������еĵڼ���[0-6]

    #$yday��һ��һ�����𣬴������������еĵڼ���[0,364]

  # $isdstֻ��һ��flag

    my $weekday = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat')[$wday];

    return { 'second' => $sec,

             'minute' => $min,

             'hour'   => $hour,

             'day'    => $mday,

             'month'  => $mon,

             'year'   => $year,

             'weekNo' => $wday,

             'wday'   => $weekday,

             'yday'   => $yday,

             'date'   => "$year$mon$mday"

          };

}