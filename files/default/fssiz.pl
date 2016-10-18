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

###################################################################
# fssiz.pl - Test the size of the file system
#  returns: 16 - File system not found or 2 many found
#  returns:  8 - comparison is bigger than filesystem
#  returns:  4 - comparison is   equal to  filesystem
#  returns:  1 - comparison is  less than  filesystem
###################################################################

###########################################################################
# HISTORY
# Vers:      # Date:     Description
# =======    # =======   ===========================================
$VV=1.01;  # 6/22/07   Initial version
###################################################################
$VER = $VV;



#----------------------------------------------------------------
#--  OPTION HANDLING  -------------------------------------------
#----------------------------------------------------------------
sub do_opts {
  my $man = 0, $help = 0;

  use Getopt::Long;
  $retval=GetOptions( 
            "f=s"         =>\$infile,
            "n"           =>\$noprt,
            "free"        =>\$compfree,
            "fs=s"        =>\$fsystem,
            "size=s"      =>\$thisize,
            "dbg"         =>\$dbg,
            "version"     =>\$version,
            'help|?'      =>\$help,
            'man'         =>\$man
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

&do_opts or pod2usage(1) or die "do_opts failed\n" ;

if (! defined($fsystem) ) { pod2usage(1); }
if (! defined($thisize) ) { pod2usage(1); }

#----------------------------------------------------------------
#----------------------------------------------------------------
# Main Program
#----------------------------------------------------------------
#----------------------------------------------------------------

$totcnt=0;

sub get_dfdata {

  $DFCMD=$_[0];
  if ($DFCMD eq '') { $DFCMD="df -kt |"; }

  open (DF,"$DFCMD") or die "Cannot open $DFCMD\n" ;
  while ( <DF> ) {
   chomp;
   ($lv,$sizb,$usedb,$freeb,$percent,$mtpt)=split;

   next if ( $lv =~ /Filesystem/ ) ;
   next if ( $lv =~ /\/proc/ ) ;
   next if ( $lv =~ /\/cdrom/ ) ;
   next if ( $lv =~ /\/dev\/fd/ ) ;
   next if ( $lv =~ /\/etc\/mnttab/ ) ;
   next if ( ! ($mtpt eq $fsystem) ) ;
   next if ( /^\s*$/ ) ;

   $totcnt++;
   
   if ( $lv =~ /:/ ) {
      ($host,$rest)=split(/:/,$lv,2);
      $lv ="<$host>";
   }
   
   push(@dforder,$mtpt);

   $fs{$mtpt} = {
       logv   => $lv,
       size   => $sizb,
       used   => $usedb,
       free   => $freeb,
       mntp   => $mtpt,
        },
  }
  close(DF);
}

sub trim {
    my($width, $string) = @_;
    my $strlen=length($string);

    if ($strlen > $width) {
        return("~" . substr($string, ($strlen-($width-1)), $width-1));
    }
    else {
        return($string);
    }
}

sub prtit   {
  my $tmprec,$key;
  my $cmpsiz;

  if ( $totcnt != 1 ) {
    print("The number of matches does not equal 1\n");   
    exit(16);
  }

  @sortlist=@dforder;
  if (defined($hashorder)) {
    @sortlist=(keys %fs);
  }
  foreach $key (@sortlist ) {
    $tmprec=$fs{$key};
    $lv=$tmprec->{logv};
    if (! defined($fullpath)) {
      $lv =~s/\/dev\///;
    }
    $sz=($tmprec->{size}/1024);
    $us=($tmprec->{used}/1024);
    $fr=($tmprec->{free}/1024);

    $cmpsiz=$sz;
    $cmptxt="FS Size";
    if (defined($compfree) ) { $cmpsiz=$fr; $cmptxt="Avail Size"; }

    if ($lv !~ /\<.*\>/ ) { 
	$totsz += $sz; $totus += $us; $totfr += $fr;
    }

    $mt=$tmprec->{mntp};
    if ( $thisize  < $cmpsiz ) { $res=1; $restxt="Smaller than";}
    if ( $thisize == $cmpsiz ) { $res=4; $restxt="SameSize as";}
    if ( $thisize  > $cmpsiz ) { $res=8; $restxt="Bigger than"; }

    if ( ! defined($noprt)) {
      printf("\tFS: %s Free: %d Used %d TargetSize: %d %s %s: %d Res: %d\n",
        $mt,$fr,$us,$thisize,$restxt,${cmptxt},${cmpsiz},$res);

    }
    exit($res);
  }
}

$thisize=$thisize*1024; #change gigs to megs
$daytime=`date '+%A, %B %e, %Y  %R'`; chomp($daytime);
$hostname=`uname -n`; chomp($hostname);
$fulline="$hostname as of $daytime";
if (defined($infile)) { &get_dfdata("$infile"); }
                 else { &get_dfdata(); }
if ( defined($ismounted) ) {
  if ( defined($fs{$ismounted}) ) {
    if ( defined($dbg) ) { print("Mounted: $ismounted\n"); }
    print("1\n");
    exit(1);
  } else {
    if ( defined($dbg) ) { print("Not Currently Mounted: $ismounted\n"); }
    print("0\n");
    exit(0);
  }
} else {
  &prtit;
}
