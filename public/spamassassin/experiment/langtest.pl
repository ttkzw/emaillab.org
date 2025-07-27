#!/usr/bin/perl -w
# langtest.pl
# 2006-04-02 TAKIZAWA Takashi <taki@cyber.email.ne.jp>
# Usage: langtest.pl [CHARSET] < message.txt

use strict;
use lib '.';
#use Mail::SpamAssassin::Util::Charset;
use Charset;

my $charset = $ARGV[0];
my $decoded;
undef $/;
my $data = <STDIN>;
$/ = "\n";
#$charset = detect_charset($charset,$_);
($charset,$decoded) = normalize_charset($charset,$data);
my $lang = get_language($charset,$decoded);
$charset = $charset ? $charset : "not found";
$lang = $lang ? $lang : "not found";
print "charset=$charset\n";
print "language=$lang\n";
#print "$decoded\n";
exit;


