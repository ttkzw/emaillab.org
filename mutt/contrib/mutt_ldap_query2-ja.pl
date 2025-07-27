#!/usr/bin/perl -w
#
# mutt_ldap_query.pl 
# version 1.24-ja

# Copyright (C) 4/14/98 Marc de Courville <marc@courville.org>
#       but feel free to redistribute it however you like.
#
# mutt_ldap_query.pl: perl script to parse the outputs of ldapsearch
# (ldap server query tool present in ldap-3.3 distribution
# http://www.umich.edu/~rsug/ldap) in order to pass the required
# formatted data to mutt (mail client http://www.mutt.org/)
# using Brandon Long's the "External Address Query" patch
# (http://www.fiction.net/blong/programs/mutt/#query).
#
# Warren Jones <wjones@tc.fluke.com> 2-10-99
#    o Instead of just matching "sn", I try to match these fields
#      in the LDAP database: "cn", "mail", "sn" and "givenname".
#      A wildcard is used to make a prefix match.  (I borrowed
#      this query from pine.)
#
#    o Commas separating command line arguments are optional.
#      (Does mutt really start up $query_command with comma
#      separated args?)
#
#    o Streamlined the perl here and there.  In particular,
#      I used paragraph mode to read in each match in a single
#      chunk.
#
#    o Added "use strict" and made the script "-w" safe.
#
#    o Returned non-zero exit status for errors or when there
#      is no match, as specified by the mutt docs.
#
#    o Explicitly close the pipe from ldapsearch and check
#      error status.
#  
# TAKIZAWA Takashi <taki@cyber.email.ne.jp> 4-20-2001
#    o Adapted Japanese query.
#      Jcode.pm module is required.
#
#    o Added configuration variables, $AUTH and $colon.
#
# TAKIZAWA Takashi <taki@cyber.email.ne.jp> 8-5-2001
#
#    o Removed configuration variables $colon.
#
#    o Japanese support based on LDAP v3.
#      MIME::Base64 module is required.
#
#    o Japanese support based on LDAP v2.
#
# TAKIZAWA Takashi <taki@cyber.email.ne.jp> 8-14-2001
#
#    o Fix a minor bug.
#
# TAKIZAWA Takashi <taki@cyber.email.ne.jp> 9-22-2001
#
#    o Fix a minor bug.

use strict;
use Jcode;
use MIME::Base64;

# Please change the following 5 variables to match your site configuration
#
my $ldap_server = "localhost";
my $BASEDN = "dc=emaillab,dc=org";           
# authentication option for ldapsearch. See ldapsearch(1).
my $AUTH = "-x";
# type of display name
#   If you use 'cn' as display name, set 0.
#   If you use 'givenName' and 'sn' as display name, set 1.
my $displayname = 1;
# If you use Japanese (as UTF-8) on LDAP v2, set 1.
my $ldapv2 = 0;

# Fields to search in the LDAP database:
#
my @fields = qw(cn mail sn givenname);

die "Usage: $0 <name_to_query>, [[<other_name_to_query>], ...]\n"
    if ! @ARGV;

$/ = '';	# Paragraph mode for input.
my @results;

foreach my $askfor ( @ARGV ) {

  $askfor =~ s/,$//;	# Remove optional trailing comma.

  my $jc = Jcode->new($askfor);
  my $jcutf8 = $jc->utf8;

  my $query = join '', map { "($_=*$jcutf8*)" } @fields;
  my $command = "ldapsearch $AUTH -h $ldap_server -b '$BASEDN' '(|$query)'" .
                " cn sn givenName mail telephoneNumber";

  open( LDAPQUERY, "$command |" ) or die "LDAP query error: $!"; 

  while ( <LDAPQUERY> ) {
    my $email = getattrvalue ('mail',$_);
    next if ($email eq '');
    my $phone = getattrvalue ('telephoneNumber',$_);
    my $name = '';
    if ($displayname eq 1) {
      my $givenname = getattrvalue ('givenName',$_);
      my $sn = getattrvalue ('sn',$_);
      if ($givenname eq '') {
        $name = $sn;
      }
      else {
        $name = join ' ', $givenname, $sn;
      }
    }
    else {
      $name = getattrvalue ('cn',$_);
    }
    push @results, "$email\t$name\t$phone\n";
  }

  close( LDAPQUERY ) or die "ldapsearch failed: $!\n";
}

print "LDAP query: found ", scalar(@results), "\n", @results;
exit 1 if ! @results;
exit 0;

sub getattrvalue {
  my ($attrdesc,$line) = @_;
  my $attrvalue = '';
  if ($ldapv2) {
    if ($line =~ /^$attrdesc=(.*)$/im) {
      my $jc = Jcode->new ($1,'utf8');
      $attrvalue= $jc->euc;
    }
  }
  else { 
    if ($line =~ /^$attrdesc\::(.*)$/im || $line =~ /^$attrdesc;.*::(.*)$/im) {
      my $jc = Jcode->new (decode_base64 ($1),'utf8');
      $attrvalue= $jc->euc;
    }
    elsif ($line =~ /^$attrdesc:(.*)$/im) {
      $attrvalue = $1;
    }
  }
  $attrvalue =~ s/^ //;
  $attrvalue =~ s/ $//;
  return $attrvalue;
}
