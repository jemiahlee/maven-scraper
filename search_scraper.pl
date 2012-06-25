#!/usr/bin/perl

=pod

=head1 NAME

search_scraper.pl - Script to run searches against Maven Central and save JSON results

=head1 SYNOPSIS

    % search_scraper.pl

=head1 DESCRIPTION

This script will query Maven Central and download .json files
from Maven Central. It will save them into a 'json' directory.

This is intended to be used with maven_scrape.pl

=head1 AUTHOR

Jeremiah Lee <jeremiah_AT_sourceninja_DOT_com>

=cut

use strict;
use warnings;
use JSON;
use Getopt::Long;

my $search_term = '.pom';
my $PER_PAGE    = 100;

GetOptions(
	       'pp|per_page|per-page=s'          => \$PER_PAGE,
	       'query|search-term|search_term=s' => \$search_term,
);

unless(-e 'json' and -d _ and -e "json/$search_term" and -d _) {
	mkdir 'json';
	mkdir "json/$search_term" or die "Could not make $search_term directory";
}

my $NUMBER_FOUND;

my $start = 0;
while( not defined $NUMBER_FOUND or $start < $NUMBER_FOUND ) {
	my $url = 'http://search.maven.org/solrsearch/select?q=' . $search_term . '&rows=' . $PER_PAGE . '&wt=json&start=' . $start;
	my $end = $start + $PER_PAGE - 1;

	my $output_file = "json/$search_term/${start}-$end.json";

	my $wget = "wget -q -O '$output_file' '$url'";

	print $wget, "\n";
	system $wget;

	if( not defined $NUMBER_FOUND ) {
		# lazy code to read in a file.
		@ARGV = ($output_file);

		# make the read below read the whole file at once.
		undef $/;
		my $json_string = <>;

		my $json = decode_json($json_string);

		unless( defined $json->{response}{numFound} ) {
			die "JSON did not return a result count!";
		}

		$NUMBER_FOUND = $json->{response}{numFound};
	}

	$start += $PER_PAGE;
	sleep 5;
}