#!/usr/bin/perl

###################################################################
# There is No official support.
# Use at your own risk. Developed for Siebel 7.7
###################################################################

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
            "f=s"       =>\$optfile,
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

$retval=255; #assume failure

###########################################3
#Main
###########################################3
#

if (! defined($optfile) ) { print("Usage $0: -f result_file\n"); }

$resultname=$optfile if ( defined($optfile) ) ;

open(LFILE,"${resultname}") or die ("Cannot open $resultname\n");
while  ( <LFILE> ) {
  # we have to find the updgrade directory
  #
  $upddir=$1,last if ( /upgrade operation are located at: (.*)/ ) ;
}
close(LFILE);

chomp($upddir);
$upddir =~s/\s+$//;

if ( ! -d $upddir ) { 
  die("Cannot find directory $upddir\n"); 
}

$preFile="$upddir/PreUpgradeResults.html";
$postFile="$upddir/UpgradeResults.html";

$resultname=$preFile;
open(LFILE,"${resultname}") or die ("Cannot open $resultname\n");
while  ( <LFILE> ) {
 $invalid++,next if ( /INVALID/ ) ;
 $valid++        if (   /VALID/ ) ;
}
close(LFILE);

$resultname=$postFile;
open(LFILE,"${resultname}") or die ("Cannot open $resultname\n");
while  ( <LFILE> ) {
 $failed++,next    if ( /Failed/ ) ;
 $success++        if ( /Successful/ ) ;
}
close(LFILE);

printf("Valid:   %d Invalid: %d\n",$valid,$invalid);
printf("Success: %d Failed:  %d\n",$success,$failed);

#success. same number of failures and starting invalids
if ( $invalid == $failed ) {
  $retval=0;
}
printf("RETVAL: %d\n",$retval);
exit($retval);
