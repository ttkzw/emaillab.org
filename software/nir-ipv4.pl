#!/usr/bin/perl -W
#   nir-ipv4.pl
# required file is:
#   http://ftp.apnic.net/stats/apnic/delegated-apnic-latest

use strict;

# requested cc
my $rcc = 'KR';

# requested type
my $rtype = 'ipv4';

my @list;

while (<STDIN>) {
    chomp();
    next if (/^#/);
    my ($registry,$cc,$type,$start,$value,$date,$status) = split(/\|/);
    next unless ($type eq $rtype && $cc eq $rcc);
    my $num = ipaddr2number($start);
    my $count = $value >> 8;
    for (my $i = 0; $i < $count; $i++) {
        push (@list,$num + $i);
    }
}

my @slist = sort{$a <=> $b}(@list);
my $stnum = shift(@slist);
my $endnum = $stnum;
foreach my $num (@slist) {
    if ($num > $endnum + 1) {
        printrange($stnum,$endnum);
        $stnum = $num;
    }
    $endnum = $num;
}
printrange($stnum,$endnum);
exit 0;

sub ipaddr2number {
    my $decimal = shift;
    my @dec = split(/\./,$decimal);
    my $num = 0;
    for (my $i = 0; $i < 2; $i++) {
        $num += $dec[$i];
        $num <<= 8;
    }
    $num += $dec[2];
    return $num;
}

sub number2ipaddr {
    my $num = shift;
    my @dec;
    for (my $i = 2; $i >= 0; $i--) {
        $dec[$i] = $num % 256;
        $num >>= 8;
    }
    $dec[3] = 0;
    return join('.',@dec);
}

sub printrange {
    my $startnum = shift;
    my $endnum = shift;
    my $start = number2ipaddr($startnum);
    my $end = number2ipaddr($endnum);
    $end =~ s/\.0$/.255/;
    print $start . '-' . $end . "\n";
}

