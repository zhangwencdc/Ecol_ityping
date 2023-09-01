#!/usr/bin/perl

=head1 Name

=head1 Description

=head1

  Author: zhangwen, zhangwen@icdc.cn
  Version: 1.0, Date: 2022-07-22
Escherichia 血清型/MLST/毒力型别鉴定流程  支持Linux环境下运行 
v3:交互式输入 
v4：多株菌输入
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
my ($input,$outdir,$HELP,$data,$key);
GetOptions(
                "I:s"=>\$input,  # Inputdir *.fasta *.fas
                "O:s"=>\$outdir,     ###outdir
				"D|DB|data|Data:s"=>\$data, #DB dir 
				"Key|K|Tag:s"=>\$key,
                "help"=>\$HELP
);
die `pod2text $0` if ($HELP || !defined $input);
if(!defined $outdir){$outdir="./";}

open(OUT,">$outdir/Ecoli_typing_result.csv");
my $date = &getTime();#获取当前系统时间的Hash

my $ymd = $date->{date};#获取yyyymmdd这样的日期 

my $year=$date->{year};#获取年

my $month=$date->{month};#获取月

my $day=$date->{day};#获取日
#print "Analysis running\nTime:$year/$month/$day \nWaiting for the run finished(2~3 minitues).\n And please Check the report file in your directory (*_report.html) after the run finish\n";

if(!defined $data){$data=$Bin;}
my $blat="blat";#blat路径

my @input1=glob "$input/*.fasta";
my @input2=glob "$input/*.fas";
my @input=(@input1,@input2);
print OUT "Strain,MLST type based on Pasteur 8 gene,MLST_8_info,MLST_Achtman_7gene,Achtman_7gene_infor,Serotyping H,Serotyping O,Pathogen\n";
foreach my $input (@input) {
my $key=basename($input);
#PasteurMLST分型
#print OUT "\#Ecoli Typing Report\n **Time:$year/$month/$day**\n\#\#1 MLST typing method\n\#\#\#(1)MLST based on Pasteur 8 gene\n";
print OUT "$key,";
system "$blat $input  $data/Escherichia_MLST_Data/Pasteur_8gene.fas $key.Pasteur.blat\n";
my $profile=$data."/Escherichia_MLST_Data/Pasteur_8gene_profile.txt";#mlst.profie
open(F,$profile);
my %type;my %complex;
my $line=<F>;
unless(substr($line,length($line)-1,1)=~/[0-9a-zA-Z]/){$line=substr($line,0,length($line)-1);}
my @gene=split"\t",$line;my $complex=pop @gene;
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
	if($a[$gene_num+1]=~/[0-9a-zA-Z]/){$complex{$st}=$a[$gene_num+1];}
	
}
close F;

open(Blat,"$key.Pasteur.blat");my %gene;
while(1){
	my $line=<Blat>;
	unless($line){last;}
	chomp $line;
	my @a=split"\t",$line;
	unless($a[0]==$a[10]){next;}#严格匹配
	unless($a[6]==0 && $a[7]==0){next;}#严格匹配
#	print "$line\n";
	my @b=split"_",$a[9];
	$gene{$b[0]}=$b[1];
}
close Blat;
#system "rm -rf $key.Achtman.blat\n";

my $p=$gene{$gene[1]};
foreach  (2..$gene_num) {
	$p=$p."_".$gene{$gene[$_]};
	#print OUT "$_,$gene[$_],$gene{$gene[$_]}\n";
}
print "$p\n";
my $st=$type{$p};
if($st=~/[0-9]/){print OUT "$st ";if(exists $complex{$st}){print OUT "Complex:$complex{$st}";} print OUT ",$p,";}else{print OUT "NA,$p,";}
#print "Pasteur 8 Locus MLST type: $st,$complex{$st}\n";

#print OUT "\#\#\#(2)MLST based on Achtman 7gene\n";
system "$blat $input  $data/Escherichia_MLST_Data/Achtman_7gene.fas $key.Achtman.blat\n";
my $profile=$data."/Escherichia_MLST_Data/Achtman_7gene_profile.txt";#mlst.profie
open(F,$profile);
my %type;my %complex;
my $line=<F>;
unless(substr($line,length($line)-1,1)=~/[0-9a-zA-Z]/){$line=substr($line,0,length($line)-1);}
my @gene=split"\t",$line;my $complex=pop @gene;
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
	if($a[$gene_num+1]=~/[0-9a-zA-Z]/){$complex{$st}=$a[$gene_num+1];}
	
}
close F;

open(Blat,"$key.Achtman.blat");my %gene;
while(1){
	my $line=<Blat>;
	unless($line){last;}
	chomp $line;
	my @a=split"\t",$line;
	unless($a[0]==$a[10]){next;}#严格匹配
	unless($a[6]==0 && $a[7]==0){next;}#严格匹配
#	print "$line\n";
	my @b=split"_",$a[9];
	$gene{$b[0]}=$b[1];
}
close Blat;
#system "rm -rf $key.Achtman.blat\n";

my $p=$gene{$gene[1]};
foreach  (2..$gene_num) {
	$p=$p."_".$gene{$gene[$_]};
	#print OUT "$_,$gene[$_],$gene{$gene[$_]}\n";
}
#print "$p\n";
my $st=$type{$p};
if($st=~/[0-9]/){print OUT "$st";if(exists $complex{$st}){print OUT "Complex:$complex{$st}";}print OUT ",$p,";}else{print OUT "NA,$p,";}
#print "Achtman 7 Locus MLST type: $st,$complex{$st}\n";

#Serotype分型
#print OUT "\#\#2\tSerotyping\n";
system "$blat $input $data/H_type.fsa $key.H.blat\n";my $h=0;
open(Blat,"$key.H.blat");
while(1){
	my $line=<Blat>;
	unless($line){last;}
	chomp $line;
	my @a=split"\t",$line;	
	if($h==0 && $a[0]>=($a[10]-1)){
	my @b=split"_",$a[9];
	my $type=pop @b;
	$h=$type."?";} #在无严格匹配时，允许一个错配
	unless($a[0]==$a[10]){next;}#严格匹配
	#unless($a[6]==0 && $a[7]==0){next;}#严格匹配
#	print "$line\n";
	my @b=split"_",$a[9];
	my $type=pop @b;
	$h=$type;
}
close Blat;
#print "H type:$h\n";
print OUT "$h,";

system "$blat $input $data/O_type.fsa $key.O.blat\n";my $o=0;
open(Blat,"$key.O.blat");
while(1){
	my $line=<Blat>;
	unless($line){last;}
	chomp $line;
	my @a=split"\t",$line;
	if($o==0 && $a[0]>=($a[10]-1)){
	my @b=split"_",$a[9];
	my $type=pop @b;
	$o=$type."?";} #在无严格匹配时，允许一个错配
	unless($a[0]==$a[10]){next;}#严格匹配
	#unless($a[6]==0 && $a[7]==0){next;}#严格匹配
#	print "$line\n";
	my @b=split"_",$a[9];
	my $type=pop @b;
	$o=$type;
}
close Blat;
#print "O type:$o\n";
print OUT "$o,";
#毒力分型
system "$blat $input $data/Ecoli_type.fasta $key.patho.blat\n";
open(Blat,"$key.patho.blat");my %pa;
while(1){
	my $line=<Blat>;
	unless($line){last;}
	chomp $line;
	my @a=split"\t",$line;	
	unless($a[0]=~/[0-9]/){next;}
	unless($a[0]>=1000 || $a[0]>=0.8*$a[10]){next;} ##Align>80%
	my @b=split"_",$a[9];
	my $type=pop @b;
	unless($type=~/[a-zA-Z]/){next;}
	print OUT "$a[9] ";
	$pa{$type}++
}
	print OUT "\n";
close Blat;
my @key=keys %pa;
#print OUT "\#\#3\t Pathogen type\n";
my $keyn=@key;
if($keyn>0){
	foreach my $k (@key) {
		print  "$key,@key detected\n";#print "$k detected\n";
	}
}else{
	print "$key,No EPEC/EHEC/EIEC/ETEC/EAEC marker detected\n";
	#print "No EPEC/EHEC/EIEC/ETEC/EAEC marker detected";
}


}
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