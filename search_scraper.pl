#!/usr/bin/perl

use strict;
use warnings;

unless(-e 'json' and -d _) {
	mkdir 'json';
}

my $NUMBER_FOUND = 41_447;

my $PER_PAGE = 100;

my $start = 0;
while( $start < $NUMBER_FOUND ) {
	my $url = 'http://search.maven.org/solrsearch/select?q=.pom&rows=' . $PER_PAGE . '&wt=json&start=' . $start;
	my $end = $start + $PER_PAGE - 1;

	my $wget = "wget -q -O 'json/$start-$end.json' '$url'";

	print $wget, "\n";
	system $wget;

	$start += $PER_PAGE;
	sleep 5;
}