#!/usr/bin/perl

###################################################################
#
#   (C) Copyright IBM Corp. 2003 All rights reserved.
#
# This is an IBM Internal Tool developed to aid in managing
# and examining Siebel Applications.  There is no official IBM
# support.  Use at your own risk. Developed for Siebel 7.7 and v8.0
#
###################################################################

###################################################################
# HISTORY
# Vers:      # Date:     Description
# =======    # =======   ==========================================
# $VV=1.01;  # 8/02/06   Initial version
  $VV=1.02;  # 3/04/16   made into self contained for CHEF
###################################################################



#----------------------------------------------------------------
#--  OPTION HANDLING  -------------------------------------------
#----------------------------------------------------------------
sub do_opts {
  my $man = 0, $help = 0;

  use Getopt::Long;
  $retval=GetOptions( 
            "text=s"   =>\$text,
            "title=s"  =>\$title,
            "char=s"   =>\$char,
            "dbg"      =>\$dbg,
            "version"  =>\$version,
            'help|?'   =>\$help,
            'man'      =>\$man
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


$title='';
$char='*';

&do_opts or pod2usage(1) or die "do_opts failed\n" ;

#########################################################################
#-----------------------------------------------------------------------#
#-------------        Supporting Subroutines   -------------------------#
#-----------------------------------------------------------------------#
#########################################################################


sub blankline{ my $line="$prefix"; &printline($line,$fillchar); }

sub printline{
  my $line=$_[0];
  my $fc=$_[1];
  while (length($line) <= $width) { $line="$line "; }
  $line="${line}${fc}";
  print("$line\n");
}

$width=70;
$dlftchar="#";
$dfltprefix="    $dlftchar";

# NOTE: && is a newline forceing characters
sub prettybox{
  my $text     =shift;
  my $title    =shift;
  my $mfill    =shift;
  my $nocrtlfs =shift;
  #{ print("1: $txt 2: $title 3:'$mfill' 4:$nocrtlfs\n"); }

  $fillchar=$dlftchar;
  if ($mfill ne ``) { $fillchar="$mfill"; }

  $prefix="    $fillchar"; 
  $line="$prefix";

  if (! defined($nocrtlfs)) {  print("\n"); }
  if ($fillchar ne ' ') {
    # Border printing
    print("$prefix"); $cnt=length("$prefix")-1;
    while ( $cnt <= $width ) { print("$fillchar"); $cnt++; } print("\n");
    &blankline;
  }

  if ($title ne '') {
    $line="$prefix $title"; &printline($line,$fillchar);
    &blankline;
  }

  $line="$prefix";
  @words=split(' ',$text);
  foreach $i ( @words ) {
    chomp($i);
    if ($i eq '&&' ) {
      #dump out line and restart buffer
      &printline($line,$fillchar);
      $line="$prefix";
      &printline($line,$fillchar);
      next;
    }
    if ( length($line) + length($i) >= $width ) {
      #dump out line and restart buffer
      &printline($line,$fillchar); $line="$prefix $i";
    } else {
      $line="$line $i"; 
    }
  }
  if ( length($line) > length($prefix)) { printline("$line",$fillchar); }


  if ($fillchar ne ' ') {
    &blankline;
    # Border printing
    print("$prefix"); $cnt=length("$prefix")-1;
    while ( $cnt <= $width ) { print("$fillchar"); $cnt++; } print("\n");
  }
  if (! defined($nocrtlfs)) {  print("\n"); }

}

#----------------------------------------------------------------
#----------------------------------------------------------------
# Main Program
#----------------------------------------------------------------
#----------------------------------------------------------------

if ( !defined($text) ) {
  pod2usage(-verbose => 2);
}


&prettybox($text,$title,$char);
print("\n");



#===========================================================
#===========================================================
#===========================================================
#EVERYTHING after __END__ is ignored by perl, below is the
#help info used by pod_usage
#===========================================================

use Pod::Usage;
__END__

=head1 NAME

prettybox.pl - formatting for nice character based box around text

=head1 SYNOPSIS

prettybox.pl [-help|?] [-man] -text "TEXT" [-title "TITLE"] [-char 'C']

 Options:
   -text            TEXT is the text you want to box up
   -title           TITLE is the title of the box
   -char            C is the character to use for the box.
   -help            brief help message
   -man             full documentation


=head1 DESCRIPTION

B<This program> takes texts, figures out how to fit the words of
the text into the box. It allows the ability to put a title line
above the main text. It also allows to change the character used
to create the box.

=cut
