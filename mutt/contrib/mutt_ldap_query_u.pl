#!/usr/bin/perl -w
#
#  mutt_ldap_query_u.pl
#  Version 0.16
#
#  You can get this script from
#    http://www.emaillab.org/mutt/downloadm17n.html#others
#
#  Required modules are
#    Net::LDAP
#    Unicode::Map
#    Unicode::String
#  You can get these modules from CPAN.
#
#
#  Copyright (C) 2001-2003 TAKIZAWA Takashi <taki@cyber.email.ne.jp>
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
use Net::LDAP qw(LDAP_SUCCESS);
use Unicode::Map;
use Unicode::String qw(utf8 utf16);

#--- beginning of configuration ----------------------------------------------
# set your display character encoding
my $charset = "UTF-8";

# LDAP bind parameters
my $host = "localhost";
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
my $filter = '(&(|(cn=%s)(sn=%s)(givenName=%s)(o=%s)(mail=%i))(objectClass=inetOrgPerson))';
my @ref_attrs = ['mail', 'cn', 'sn', 'givenName', 'o', 'telephoneNumber'];

# output parameters
my $mail_attr = 'mail';
my @name_attr = ('cn');
#my @name_attr = ('sn', 'givenName');
my @comment_attr = ('o','telephoneNumber');

#--- end of configuration ----------------------------------------------------

if (!$ARGV[0]) {
  print "Usage: mutt_ldap_query_u.pl querystring [basedn]\n";
  exit -1;
}
my $query = "$ARGV[0]";
$basedn = $ARGV[1] if ($ARGV[1]);
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

sub conv_to_utf8 {
  my ($src) = @_;
  return $src if ($charset =~ /utf-8/i);
  my $charmap = new Unicode::Map($charset);
  my $dest = utf16 ($charmap->to_unicode ($src))->utf8;
  return $dest;
}

sub conv_from_utf8 {
  my ($src) = @_;
  return $src if ($charset =~ /utf-8/i);
  my $charmap = new Unicode::Map($charset);
  my $dest = $charmap->from_unicode (utf8($src)->utf16);
  return $dest;
}

