#!/usr/bin/perl

## CountRE motifs at the soft-clip junction site
## Author: Dhawal Jain (Park lab, HMS)

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
  'm=s'              => \$motif,
  'e=s'              => \$enzyme,
  'q=s'              => \$min_mapq,
  'c=s'              => \$CLIP,
  'w=s'              => \$WOBBLE,
  'help'             => \$help,
  'h'                => \$help,
) or die "Incorrect input! Use -h for usage.\n";
sub help{
  my $j = shift;
  if ($j) {
   print "\nUsage: perl 4DNREcount.pl -bam [FILE_PATH] -m [STRING] -e [STRING] -c [INT] -q [INT] -w [LOGICAL] \n\n";
   print "This script counts an RE motifs at the clipped sites\n\n";
   print "Options (required*):\n";
   print "   -bam              Input bam file\n";
   print "                       (Input can be piped, else reading bam file will require samtools in the path variable)";
   print "\n";
   print "Options (optional):\n";
   print "   -m                RE-motif to be seached\n";
   print "                       The program accepts Perl style regular expression pattern for motif search.\n";
   print "                       i.e. for combination of enzymes, say MboI+HinfI one can search patterns like GATCA[ATGC]{1}TC|GA[ATGC]{1}TGATC|CT[GATC]{1}AT etc.\n";
   print "\n";
   print "   -e                If -m parameter is not specifid, user can choose from one of the commonly used RE\n";
   print "                       Avaialble options are [Dpn1II/ MboI/ HindIII/ NcoI/ 'MboI+HinfI']\n";
   print "\n";
   print "   -q                Minimum mapping quality for the reference alignment. This value is used to determine repeat anchored mates in the genome (default:0) \n";
   print "\n";
   print "   -c                Minimum softclipped read length for mapping the reads to the TE assembly (default:5)\n";
   print "\n";
   print "   -w                Allow wobble matching of RE motif (default:T)\n";
   print "                       This option allows matching of RE motif around the vicinity of the clip position such that ligation junction may\n";
   print "                       may not be exactly the clipped coordinate. \n";
   print "                       NOTE: The option assumes that the ligation junction is exactly at the center for the ligation motif \n";
   print "                       NOTE: If the user is using multiple RE combination, then the option should be reset to default !! \n";
   print "\n";
   print "   -help|-h          Display usage information.\n";
   print "\n";
   print "Default outputs:\n";
   print "    Writes count summary \n\n\n";
   exit 0;
  }
}
help($help);

###-------------------------------------------------------------------------------------------------------------------------------
# I/O
###-------------------------------------------------------------------------------------------------------------------------------
my %redb;
$redb{"AluI"} = "AGCT|TCGA";
$redb{"NotI"} = "GCGGCCGGCCGC|CGCCGGCCGGCG";
$redb{"MboI"} = "GATCGATC|CTAGCTAG";
$redb{"DpnII"} = "GATCGATC|CTAGCTAG";
$redb{"HindIII"} = "AAGCTAGCTT|TTCGATCGAA";
$redb{"NcoI"} = "CCATGCATGG|GGTACGTACC";
$redb{"MboI+HinfI"} = "GATCGATC|CTAGCTAG|GA[ATGC]{1}TA[ATGC]{1}TC|GATCA[ATGC]{1}TC|GA[ATGC]{1}TGATC|CT[GATC]{1}AT[AGTC]{1}AG|CT[ATGC]{1}ACTAG|CTAGT[ATGC]{1}AG";
$redb{"HinfI+MboI"} = "GATCGATC|CTAGCTAG|GA[ATGC]{1}TA[ATGC]{1}TC|GATCA[ATGC]{1}TC|GA[ATGC]{1}TGATC|CT[GATC]{1}AT[AGTC]{1}AG|CT[ATGC]{1}ACTAG|CTAGT[ATGC]{1}AG";
my $watch_run=0;
my $run_time=0;
my $lines = 0;
my %summary;

## 1) parse file
if($bam eq ""){
	print "**** Input bam file is missing. Exiting\n\n";
  help(1);
}

if($enzyme eq "" and $motif eq ""){
  print "\n***";
  print "Both of the following is missing. Exiting.\n";
  print " Motif (Perl style regular expression) is not provided.\n";
  print " Name of the enzyme used in the Hi-C experiment is not provided.\n\n";
  help(1);  
}

if($motif eq "" and $enzyme ne ""){
  $motif = $redb{$enzyme} if($redb{$enzyme});
}

$lines = bam_read($bam);


## 2) write report
$summary{unmapped}{uncheck} = 0 if(!$summary{unmapped}{uncheck});
$summary{lowqual}{uncheck} = 0 if(!$summary{lowqual}{uncheck});
$summary{shortclip}{uncheck} = 0 if(!$summary{shortclip}{uncheck});
$summary{1}{RE} = 0 if(!$summary{1}{RE});
$summary{1}{noRE} = 0 if(!$summary{1}{noRE});
$summary{1}{isClip} = 0 if(!$summary{1}{isClip});
$summary{2}{RE} = 0 if(!$summary{2}{RE});
$summary{2}{noRE} = 0 if(!$summary{2}{noRE});
$summary{2}{isClip} = 0 if(!$summary{2}{isClip});

my $total = $summary{unmapped}{uncheck} + $summary{lowqual}{uncheck} + $summary{shortclip}{uncheck} + $summary{1}{RE} +$summary{1}{noRE} + $summary{2}{RE} + $summary{1}{noRE};
$watch_run = time();
$run_time = $watch_run - our $start_run;
my $perc = 0;
if($summary{1}{isClip}>0 and $summary{2}{isClip}>0){
  $perc= round( ($summary{1}{RE}+$summary{2}{RE})*100/ ($summary{1}{isClip}+$summary{2}{isClip}) ,2);
}

=head
print "\n";
print "##-----------------------------------------------------------------\n";
print "##  Report\n";
print "##-----------------------------------------------------------------\n";
print "Input file: $bam\n";
print "Time: $run_time seconds\n";
print "motif: $motif\n";
=cut
print "clipped-mates with RE motif: $perc %\n";
=head
print "\n\n";

print "## Details:--------------------------------------------------------\n";
print "Total reported mates: $total\n";
if($total >0){
  $perc = round( ($summary{1}{RE}+$summary{1}{noRE})*100/$total,2);
  print "1st mate (mapped): ",($summary{1}{RE}+$summary{1}{noRE}), " ($perc %)\n";
  $perc = round( ($summary{2}{RE}+$summary{2}{noRE})*100/$total,2);
  print "2nd mate (mapped): ",($summary{2}{RE}+$summary{2}{noRE}), " ($perc %)\n";
  $perc = round( $summary{unmapped}{uncheck}*100/$total,2);
  print "unmapped mates: ",$summary{unmapped}{uncheck}, " ($perc %)\n";
  $perc = round( $summary{lowqual}{uncheck}*100/$total,2);
  print "low mapping quality mates (-q $min_mapq): ",$summary{lowqual}{uncheck}, " ($perc %)\n";
  $perc = round( $summary{shortclip}{uncheck}*100/$total,2);
  print "short clipped mates (-c $CLIP): ",$summary{shortclip}{uncheck}, " ($perc %)\n";
}
print "\n";
print "Clipped Mates with RE site at the clip-junction\n";
print "Total clipped mates: ", ($summary{1}{isClip}+$summary{2}{isClip}),"\n"; 
if($summary{1}{isClip}>0){
  $perc = round( $summary{1}{RE}*100/$summary{1}{isClip},2);
  print "1st mate: ", $summary{1}{RE}, " ($perc %)\n";
}
if($summary{2}{isClip}>0){
  $perc = round( $summary{2}{RE}*100/$summary{2}{isClip},2);
  print "2nd mate: ", $summary{2}{RE}, " ($perc %)\n";
}
if($summary{1}{isClip}>0 and $summary{2}{isClip}>0){
  $perc = round( ($summary{1}{RE}+$summary{2}{RE})*100/ ($summary{1}{isClip}+$summary{2}{isClip}) ,2);
  print "Both (1st+2nd): ",($summary{1}{RE}+$summary{2}{RE}), " ($perc %)\n";
}
print "\n\n";
=cut
exit 0;




###-------------------------------------------------------------------------------------------------------------------------------
# Subroutines
###-------------------------------------------------------------------------------------------------------------------------------
sub bam_read{
  my ($file) = shift;
  if($file=~ m/.bam/){
     open IN,"samtools view -@ 8 $file|" or next "Can't open file $file";
  }else{
     print "input is pipe/sam\t";
     open IN,"$file" or next "Can't open file $file"; 
  }
  
  my $line = 0;
  while(<IN>) {
    next if(/^(\#)/); 
    next if(/^(\@)/); 
    chomp;
    s/\r//;  
    $line++;
    my ($flag) =  $_ =~ /^.*?\t(\d*)/;
    next if($flag>=256);
    my @sam = split(/\t/);
    if(scalar @sam <11){
      print " ERROR reading the input sam/bam file. Exiting!! \n";
      exit 1;
    }

    if($sam[1] & 0x40){
      motifPresenceGain($sam[9],$sam[5],$sam[4],1) ;
    }elsif($sam[1] & 0x80){
      motifPresenceGain($sam[9],$sam[5],$sam[4],2) ;
    }
  }
  close(IN);
  return($line);
}
sub motifPresenceGain {
  my ($seq,$cigar,$mapq,$rd) = @_;
  
  ## unmapped mates
  if($cigar eq "*"){  
  	$summary{unmapped}{uncheck}++;
  }elsif($mapq < $min_mapq){
  	$summary{lowqual}{uncheck}++;
  }

  my ($a) = $cigar=~ /^(\d+)S\S+/;
  my ($b) = $cigar=~ /\D(\d+)S$/;
  $a=0 if(!defined($a) || $a eq"");  ## left hand side
  $b=0 if(!defined($b) || $b eq"");  ## right hand side   
  
  if($a < $CLIP and $b < $CLIP){
    $summary{shortclip}{uncheck}++; 
  } 
  
  my $isREa = 0;
  my $isREb = 0;
  if($a>=$CLIP){
  	$isREa = checkREatClip($seq,$motif,$a)
  }
  if($b>=$CLIP){
   $isREb = checkREatClip($seq,$motif,(length($seq)-$b));
  }
  if($a>=$CLIP or $b>=$CLIP){
    $summary{$rd}{isClip}++;
  }
  if($isREa==1 or $isREb==1 ){
  	$summary{$rd}{RE}++;
  }else{
  	$summary{$rd}{noRE}++;
  }
}
sub checkREatClip{
  my ($seq,$motif,$cl) = @_;
  my $isRE = 0;
  
  if($motif eq "" or !defined $motif){
    print " Motif not defined!! exiting! \n";
    exit 1;
  }else{
    while ($seq =~ /$motif/g){
      if(($cl-1)>= $-[0] and $cl<= $+[0] and $isRE ==0) {
        if($WOBBLE eq "T"){
          $isRE = 1;
        }else{
          my $HALFMOTIFLEN = round(($+[0] - $-[0])/2,0);
          $isRE = 1 if ($cl == ($-[0] + $HALFMOTIFLEN));
        }
      }
    }
  }
  return($isRE);
}
sub round {
  my ($n, $places) = @_;
  my $abs = abs $n;
  my $val = substr($abs + ('0.' . '0' x $places . '5'),
                   0,
                   length(int($abs)) +
                     (($places > 0) ? $places + 1 : 0)
                  );
  ($n < 0) ? "-" . $val : $val;
}
