#!/usr/bin/perl -w
use strict;

while(<STDIN>) {
    if (/^header(\s+)(.+?)(\s+)(.+?)(\s)(=~|!~)(\s+)(.*[\x80-\xFF]+.*)$/) {
        $_ = "header$1$2$3$4:utf8$5$6$7$8\n";
    }
    elsif (/^body\s+.+?\s+.*[\x80-\xFF]+.*$/) {
	s/^body/nbody/;
    }
    print $_;
}
