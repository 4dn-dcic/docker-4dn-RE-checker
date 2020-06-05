#!/usr/bin/perl

## CountRE motifs around bridge sites
## Author: Soo Lee (duplexa@gmail.com, Park lab, HMS), Dhawal Jain (Park lab, HMS)

use warnings FATAL => "all";
use strict;
use POSIX;
use Getopt::Long;
use Data::Dumper;
use constant { true => 1, false => 0 };
#use utf8;
#use open qw(:std :utf8);
BEGIN { our $start_run = time(); }

###-------------------------------------------------------------------------------------------------------------------------------
# inputs etc
###-------------------------------------------------------------------------------------------------------------------------------
my $bam = "";
my $motif = ""; 
my $enzyme = "";
my $min_mapq = 0;
my $CLIP = 5; 
my $WOBBLE="T"; 
my $help = 0;
Getopt::Long::GetOptions(
  'bam=s'            => \$bam,
  'e=s'              => \$enzyme,
  'help'             => \$help,
  'h'                => \$help,
) or die "Incorrect input! Use -h for usage.\n";
sub help{
  my $j = shift;
  if ($j) {
   print "\nUsage: perl $0 -bam [FILE_PATH] -e [STRING] \n\n";
   print "This script counts an RE motifs at the clipped sites\n\n";
   print "Options (required*):\n";
   print "   -bam              Input bam file\n";
   print "                       (Input can be piped, else reading bam file will require samtools in the path variable)";
   print "\n";
   print "Options (optional):\n";
   print "   -e                If -m parameter is not specifid, user can choose from one of the commonly used RE\n";
   print "                       Avaialble options are [AluI]\n";
   print "\n";
   print "   -help|-h          Display usage information.\n";
   print "\n";
   print "Default outputs:\n";
   print "    Writes count summary \n\n\n";
   exit 0;
  }
}
help($help);


if($enzyme eq ""){
  print "\n***";
  print " Name of the enzyme used in the ChIA-PET experiment is not provided.\n\n";
  help(1);  
}

my %enz_motif = {"AluI" => "AGCT"};
my $adapter_patterns = "AGTCAGATAAGATATCGCGT|ACGCGATATCTTATCTGACT";  # bridge sequence
my $enz_pattern = $enz_motif{$enzyme};

my $total_count = 0;
my %count = {$enz_pattern => 0};

open BAM, $bam or die "Can't open input bam file.\n\n";
while(<BAM>){
    chomp;
    my ($seq) = (split/\t/)[9];
    if($seq =~ /$adapter_patterns/) {
        next if length($`) < length($enz_pattern)/2;
        next if length($') < length($enz_pattern)/2;
        my $flank = substr($`, -length($enz_pattern)/2, length($enz_pattern)/2) . substr($', 0, length($enz_pattern)/2);
        $count{$flank}++;
        $total_count++;
    }
}
close BAM;

for my $flank (keys %count){
   print "$flank : $count{$flank}\n";
}

#print("total = $total_count\n");
#print("motif = $count{$enz_pattern}\n");
#printf("percent motif = %.2f\n", $count{$enz_pattern}/$total_count * 100);
printf("%.2f\n", $count{$enz_pattern}/$total_count * 100);
