#!/usr/bin/perl -w
#
#  mutt_ldap_query_wc.pl
#  Version 0.10
#
#  http://www.emaillab.org/mutt/contrib/mutt_ldap_query_wc.pl
#
#  Requirement modules are
#    Net::LDAP
#    Jcode           (if you use Japanese)
#    Unicode::Map    (if you don't use Japanese)
#    Unicode::String (if you don't use Japanese)
#  You can get these modules from CPAN.
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
use Net::LDAP qw(:all);

# If you use Japanese, remove '#'
use Jcode;

# If you don't use Japanese, remove '#'
#use Unicode::Map;
#use Unicode::String qw(utf8 utf16);

#--- beginning of configuration ----------------------------------------------
# set your display character encoding
my $charset = "euc-jp";

# LDAP bind parameters
my $host = "192.168.2.3";
my $port = "389";
my $anonymous = 1;
my $binddn = "cn=query,dc=emaillab,dc=org";
my $bindpassword = "secret";
my $version = 3;
my $timeout = 10;

# LDAP search parameters
#   filter variables:
#     %e: equality
#     %s: substring
#     %i: subinitial
#     %f: subfinal
my $scope = 'sub';
my $basedn = "dc=emaillab,dc=org";
my $filter = '(&(|(cn=%s)(sn=%s)(givenName=%s)(mail=%i))(objectClass=inetOrgPerson))';
my @ref_attrs = ['mail', 'cn', 'sn', 'givenName', 'telephoneNumber'];

# output parameters
my $mail_attr = 'mail';
my @name_attr = ('cn');
#my @name_attr = ('sn', 'givenName');
my @comment_attr = ('telephoneNumber');

#--- end of configuration ----------------------------------------------------

print "Usage: $0 querystring\n" if (!$ARGV[0]);
my $query = "$ARGV[0]";
$query = conv_to_utf8 ($query) if (!isasciistr($query));
$filter =~ s/%e/$query/g;
$filter =~ s/%s/*$query*/g;
$filter =~ s/%i/$query*/g;
$filter =~ s/%f/*$query/g;
ldapquery ($filter);

exit 0;

# subroutine

sub ldapquery {
  my ($filter) = @_;
  my $message;
  my $ldap = Net::LDAP->new ($host, port => $port, timeout => $timeout, version => $version) or die "$0: Unable to connect $host\n";
  if ($anonymous) {
    $message = $ldap->bind;
  } else {
    $message = $ldap->bind ($binddn, password => $bindpassword);
  }
  $message->code && die "Unable to bind LDAP server\n";
  $message = $ldap->search (
    base => $basedn,
    scope => $scope,
    filter => $filter,
    attrs => @ref_attrs
  );
  die ("Unable to search strings\n") if ($message->code != LDAP_SUCCESS);
  my $count = $message->count;
  print "LDAP query: found $count\n";
  for (my $i = 0; $i < $count; $i++) {
    my $entry = $message->entry($i);
    my %attrhash;
    foreach my $attr ($entry->attributes) {
      my $value = $entry->get_value($attr);
      $attr =~ s/;.*$//;
      next if (exists $attrhash{$attr});
      $value = conv_from_utf8 ($value) if (!isasciistr ($value));
      $attrhash{$attr} = $value;
    }
    print_result (%attrhash);
  }
  $ldap->unbind;
  return;
}

sub print_result {
  my (%attrhash) = @_;
  my @result;
  if (exists $attrhash{$mail_attr}) {
    push (@result, $attrhash{$mail_attr});
  } else {
    push (@result, '');
  }
  my @name;
  for (my $i = 0; $i <= $#name_attr; $i++) {
    push (@name, $attrhash{$name_attr[$i]}) if (exists $attrhash{$name_attr[$i]});
  }
  push (@result, join (' ',@name));
  my @comment;
  for (my $i = 0; $i <= $#comment_attr; $i++) {
    push (@comment, $attrhash{$comment_attr[$i]}) if (exists $attrhash{$comment_attr[$i]});
  }
  push (@result, join (' ',@comment));
  my $output = join ("\t",@result) . "\n";
  print $output;
}

sub isasciistr {
  my ($src) = @_;
  return ($src =~ /[\x80-\xFF]/) ? 0 : 1;
}

#-----------------------------------------------------------------------------
# remove '#' if you like conv_to_utf8 subroutine.
# Japanese
sub conv_to_utf8 {
  my ($src) = @_;
  my $jconv;
  if ($charset =~ /euc-jp/i) {
    $jconv = Jcode->new ($src, 'euc');
  } elsif ($charset =~ /shift_jis/i) {
    $jconv = Jcode->new ($src, 'sjis');
  } elsif ($charset =~ /iso-2022-jp/i) {
    $jconv = Jcode->new ($src, 'jis');
  } else {
    $jconv = Jcode->new ($src, 'utf8');
  }
  my $dest = $jconv->utf8;
  return $dest;
}

# except Japanese
# Unicode::Map and Unicode::String
#sub conv_to_utf8 {
#  my ($src) = @_;
#  my $charmap = new Unicode::Map($charset);
#  my $dest = utf16 ($charmap->to_unicode ($src))->utf8;
#  return $dest;
#}

# ASCII or UTF-8
#sub conv_to_utf8 {
#  my ($src) = @_;
#  return $src;
#}

#-----------------------------------------------------------------------------
# remove '#' if you like conv_from_utf8 subroutine.
# Japanese
sub conv_from_utf8 {
  my ($src) = @_;
  my $dest = $src;
  my $jconv = Jcode->new ($src,'utf8');
  if ($charset =~ /euc-jp/i) {
    $dest = $jconv->euc;
  } elsif ($charset =~ /shift_jis/i) {
    $dest = $jconv->sjis;
  } elsif ($charset =~ /iso-2022-jp/i) {
    $dest = $jconv->jis;
  }
  return $dest;
}

# except Japanese
# Unicode::Map and Unicode::String
#sub conv_from_utf8 {
#  my ($src) = @_;
#  my $charmap = new Unicode::Map($charset);
#  my $dest = $charmap->from_unicode (utf8($src)->utf16);
#  return $dest;
#}

# ASCII or UTF-8
#sub conv_from_utf8 {
#  my ($src) = @_;
#  return $src;
#}
