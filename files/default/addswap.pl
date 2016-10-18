#!/usr/bin/perl

###################################################################
#
# (C) COPYRIGHT International Business Machines Corp. 1985, 1989
# All Rights Reserved
# Licensed Materials - Property of IBM
#
# This is an IBM Internal Tool delevoped to aid in understanding
# and examining Siebel Applications.  There is No official support.
# Use at your own risk. Developed for Siebel 7.7
###################################################################

local $ppsiz=0;
local $frepp=0;
local $freemegs=0;
local $curswp=0;
local $newsiz=0;



$VER = 1.1;
###################################################################
# HISTORY
# Vers:   Date:     Description
# v1.1    11/09/15  Original tracking
###################################################################



#----------------------------------------------------------------
#--  OPTION HANDLING  -------------------------------------------
#----------------------------------------------------------------
sub do_opts {
  my $man = 0, $help = 0;

  use Getopt::Long;
  $retval=GetOptions(
            "s=s"       =>\$tgtswp,
            "dbg"       =>\$dbg,
            'help|?'    =>\$help,
            'man'       =>\$man
            ) ;

  # handles unknown options. (ARGV isnt empty!)
  if ( $ARGV[0] ) {
    print "Unprocessed by Getopt::Long\n";
    foreach (@ARGV) { print "$_\n"; }
    pod2usage(-message => "Unprocessed by Getopt::Long",
              -exitval => 2,
              -verbose => 0,
              -output  => \*STDERR);
  }

  #- Parse options and print usage if there is a syntax error,
  #- or if usage was explicitly requested.
  pod2usage(1)             if $help;
  pod2usage(-verbose => 2) if $man;

# #- If no arguments were given, then allow STDIN to be used only
# #- if it's not connected to a terminal (otherwise print usage)
#   pod2usage("$0: No files given.")  if ((@ARGV == 0) && (-t STDIN));

  return $retval;
}

&do_opts or die "do_opts failed\n" ;

if (! defined($tgtswp) ) { 
  print(" Usage: $0 -s <swap_size in MB> -m <Mach Mem in MB>\n");
  exit(-1);
}

###########################################3
#Main
###########################################3
#



sub get_numbers {
  $cmd="lsvg rootvg" ;
  open (LSVG, "$cmd |" ) or die ("Cannot open cmd: \'$cmd\' \n") ;
  while ( <LSVG> ) {
    ($f1,$f2,$f3,$f4,$f5,$ppsiz,$f7)=split if ( /VG STATE:/ ) ;
    ($f1,$f2,$f3,$f4,$f5,$frepp,$freemegs,$f8)=split if ( /MAX LVs:/ ) ;
  }
  $freemegs =~s/\(//;

  $curswp=`lsps -s | fgrep MB | awk '{print \$1}' | sed -e '/MB/s///'`;
  $newsiz=($tgtswp-$curswp);
  print("ROOTVG: PPSIZ: $ppsiz FREEPP: $frepp FREEMEGS: $freemegs\n");
  print("TGTSWAP: $tgtswp NEWSWAP Needed: $newsiz\n");
}

&get_numbers;

$ret=0;
if ($tgtswp > $curswp) {
  $newsiz=($tgtswp-$curswp);
  print("new size: $newsiz\n");
  if ($newsiz > $freemegs) {
   print("Not enough space in rootvg for additional swap\n");
   $ret=2;;
   exit($ret);
  }
  # make the page space command
  #
  $partitions=($newsiz/$ppsiz);
  $hdisk=`lspv | fgrep rootvg | awk '{print \$1}'`;
  $cmd="mkps -s${partitions} -n -a rootvg ${hdisk}\n";

  #DO THE ADD SWAP COMMAND
  printf($cmd); 
	!system($cmd) or die("$cmd failed to create swap\n");

  #RECHECK
  &get_numbers;
  if ($tgtswp > $curswp) {
    print("Added swap space, but after adding, we still dont have enough\n");
    exit(4);
  }
} else {
  print("Current Swap is sufficient: $curswp\n");
}
exit 0;

