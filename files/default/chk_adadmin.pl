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


###########################################3
#Main
###########################################3
#

if (! defined($optfile) ) { print("Usage $0: -f result_file\n"); }

$resultname=$optfile if ( defined($optfile) ) ;

my %success_expect = (
  "Completed: file adappsgs.pls"            => 159,
  "AD_DEFERRED_JOBS table dropped"          => 1,
);


##############################################
# This is about the out.adadmin.rsp output file
#
open(LFILE,"${resultname}") or die ("Cannot open $resultname\n");
while  ( <LFILE> ) {
  $actual{$1}++,next if (/(Completed: file adappsgs.pls)/ );
  $actual{$1}++,next if (/(AD_DEFERRED_JOBS table dropped)/ );
  $realogfile=$_,next if ( /ADUtilityName.log/ ) ;
}
print("\tChecking file: $resultname ... \n");
foreach $line (keys %success_expect ) {
  if ( ! defined($actual{$line}) )         { 
    die ("$line is not found within actual\n"); }
  if ( ! defined($success_expect{$line}) ) { 
    die ("$line is not found within success_expect\n"); }
  if ( $actual{$line} != $success_expect{$line} )  {
    die ("$line, A: $actual{$line} E: $success_expect{$line}: $Counts are wrong. Failed\n");
  }
}
close(LFILE);

##############################################
# This is about the ADUtilityName.log file
#
my %success2_expect = (
  "procedure successfully completed" => 36,
  "AD Administration is complete"    => 1,
);

$resultname=$realogfile;
chomp($resultname);
print("\n\tChecking file: $resultname ... \n");
open(LFILE,"${resultname}") or die ("Cannot open $resultname\n");
while  ( <LFILE> ) {
  $actual2{$1}++,next if (/(procedure successfully completed)/ );
  $actual2{$1}++,next if (/(AD Administration is complete)/ );
}
foreach $line (keys %success2_expect ) {
  if ( ! defined($actual2{$line}) )         { 
    die ("$line is not found within actual2\n"); }
  if ( ! defined($success2_expect{$line}) ) { 
    die ("$line is not found within success_expect\n"); }
  if ( $actual2{$line} != $success2_expect{$line} )  {
    die ("$line, A: $actual2{$line} E: $success2_expect{$line}: $Counts are wrong. Failed\n");
  }
}
close(LFILE);




exit 0;
