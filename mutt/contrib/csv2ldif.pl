#!/usr/bin/perl -w
#  csv2ldif.pl : convert CSV, comma-separated list, to LDIF
#  Version 0.10
#
#  You can get this script from
#    http://www.emaillab.org/mutt/download.html#ldap
#
#  Required modules are
#    Jcode
#    MIME::Base64
#  You can get these modules from CPAN.
#
#  Format of CSV:
#    The first line is a comma-separated list of attribute descriptors.
#    Lines equal to or more than the second line are comma-separated lists 
#    of attribute values.
#    Note: The first column is used by distinguished name.
#          You must not include any commas in an attribute value.
#  Example of CSV:
#    cn,cn;lang-ja,mail,objectClass
#    Takashi Takizawa,Âìß· Î´»Ë,taki@cyber.email.ne.jp,inetOrgPerson
#    Takashi Lunatic Takizawa,Âìß· Î´»Ë,taki@luna.email.ne.jp,inetOrgPerson
#
#
#  Copyright (C) 2001 TAKIZAWA Takashi <taki@cyber.email.ne.jp>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111, USA.
#

use strict;
use Jcode;
use MIME::Base64 qw(encode_base64);

my $delim = ',';
my $icode = 'euc';

usage() if (!$ARGV[0]);
my $basedn = $ARGV[0];

# attribute descripters
$_ = <STDIN>;
chomp;
usage() if ($_ eq '');
my @attr = split ($delim,$_);

# attribute values
my $jconv = Jcode->new('');
while(<STDIN>){
  chomp;
  next if ($_ eq '');
  my @value = split ($delim,$jconv->set($_,$icode)->utf8);
  print "# $value[0]\n";
  print_line ('dn', "$attr[0]=$value[0],$basedn");
  for (my $i = 0; $i <= $#value; $i++) {
    print_line ($attr[$i], $value[$i]);
  }
  print "\n";
}
exit 0;

sub print_line {
  my ($attr,$value) = @_;
  if ($value =~ /[\x80-\xFF]/) {
    print "$attr" . ':: ' , encode_base64 ($value,'') . "\n";
  } else {
    print "$attr: $value\n";
  }
}

sub usage {
  print "Usage: csv2ldif.pl basedn < data.csv\n";
  exit -1;
}
