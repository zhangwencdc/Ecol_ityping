#!/usr/bin/perl

=head1 Name

=head1 Description

=head1

  Author: zhangwen, zhangwen@icdc.cn
  Version: 1.0, Date: 2022-07-22
Escherichia 血清型鉴定流程  支持Windows环境下运行 
v3:交互式输入 
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


my $date = &getTime();#获取当前系统时间的Hash

my $ymd = $date->{date};#获取yyyymmdd这样的日期 

my $year=$date->{year};#获取年

my $month=$date->{month};#获取月

my $day=$date->{day};#获取日
print "Analysis running\nTime:$year/$month/$day \nWaiting for the run finished(2~3 minitues).\n And please Check the report file in your directory (Input_MLST_report.txt) after the run finish\n";

my ($tag,$outdir,$data);
if(!defined $tag){$tag="Input";}
if(!defined $outdir){$outdir=dirname($genome);}
if(!defined $data){$data=$Bin;}



my $file=$genome;#genome.fa
my $mlst=$data."/H_type.fas";#mlst.fa
#my $profile=$data."/Achtman_7gene_profile.txt";#mlst.profie
my $out=$outdir."/".$tag."_Serotype_report.txt";



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
print OUT "Serotype Report\n Time:$year/$month/$day\nH serotype:"; my %type;
while(1){
	my $line=<FILE>;
	unless($line){last;}
	chomp $line;
	my @a=split",",$line;
	unless($a[1] >0){next;}
	my @gene=split"_",$a[0];
		my $type=pop @gene;
		$type{$type}++;

	
}
close FILE;
my @type=keys %type;
print OUT "@type\n";

print "H serotype: @type\n";


my $mlst=$data."/O_type.fsa";#mlst.fa
#my $profile=$data."/Pasteur_8gene_profile.txt";#mlst.profie

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
my %gene;
print OUT "O serotype:"; my %type;
while(1){
	my $line=<FILE>;
	unless($line){last;}
	chomp $line;
	my @a=split",",$line;
	unless($a[1] >0){next;}
	my @gene=split"_",$a[0];
		my $type=pop @gene;
		$type{$type}++;

	
}
close FILE;
my @type=keys %type;
print OUT "@type\n";

print "O serotype: @type\n";


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

   #time()函数返回从1970年1月1日起累计秒数

    my $time = shift || time();

   
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);

   
    $mon ++;

    $sec  = ($sec<10)?"0$sec":$sec;#秒数[0,59]

    $min  = ($min<10)?"0$min":$min;#分数[0,59]

    $hour = ($hour<10)?"0$hour":$hour;#小时数[0,23]

    $mday = ($mday<10)?"0$mday":$mday;#这个月的第几天[1,31]

    $mon  = ($mon<9)?"0".($mon):$mon;#月数[0,11],要将$mon加1之后，才能符合实际情况。

    $year+=1900;#从1900年算起的年数

    #$wday从星期六算起，代表是在这周中的第几天[0-6]

    #$yday从一月一日算起，代表是在这年中的第几天[0,364]

  # $isdst只是一个flag

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