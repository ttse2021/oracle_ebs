#!/usr/bin/perl -w

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
# HISTORY
# Vers:   Date:     Description
# v1.1	  11/18/15   Original tracking
###################################################################


 
use strict;
use Getopt::Std;
 
# declare the perl command line flags/options we want to allow
my %options=();
getopts("6:7:h", \%options);
 

my $min61full;
my $min71full;
my $min61;
my $min71;
my $value;
my $ver;
my $techlvl;
my $svcpack;
my $tlsp;

# Main
# test for the existence of the options on the command line.
# in a normal program you'd do more than just print these.
if ( ! (defined $options{6} && defined $options{7}) ) {
  print("Usage: $0 -6 <min61_oslevel> -7 <min71_oslevel>\n");
  exit 1
}

$min61full=$options{6};
$min71full=$options{7};

$min71=((substr($min71full,5,2)*100)+(substr($min71full,8,2)));
$min61=((substr($min61full,5,2)*100)+(substr($min61full,8,2)));

#get current value
$value=`oslevel -s`; chomp($value);
$ver    =substr($value,0,4);
$techlvl=substr($value,5,2);
$svcpack=substr($value,8,2);
print("VER: $ver TL: $techlvl SP: $svcpack\n");
$tlsp=($techlvl*100)+$svcpack;

#is version correct?
#
if (! (($ver == "6100") || ($ver == "7100") || ($ver == "7200")) ) {
  print("Incorrect Version: Must be 6100 or 7100 or 7200\n");
  exit 16
}

if (($ver == "7100") || ($ver == "7200")) {
  if ($ver == "7100") {
    if ($tlsp < $min71 ) {
      print("Error: TLSP: $tlsp  MIN: $min71\n");
      exit 64;
    }
  }
}

if ($ver == "6100") {
  if ($tlsp < $min61 ) {
    print("Error: TLSP: $tlsp  MIN: $min61\n");
    exit 32;
  }
}
exit 0
