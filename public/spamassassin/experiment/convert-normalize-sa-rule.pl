#!/usr/bin/perl -w
use strict;

while(<STDIN>) {
    if (/^header(\s+)(.+?)(\s+)(.+?)(\s)([=!]~)(\s+)(.*[\x80-\xFF]+.*)$/) {
        my $buf = "header$1$2$3$4:utf8$5$6$7$8\n";
        my $header = $4;
        $_ = $buf if ($header !~ /:utf8$/);
    }
    elsif (/^body\s+.+?\s+.*[\x80-\xFF]+.*$/) {
	s/^body/nbody/;
    }
    print $_;
}
