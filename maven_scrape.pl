#!/usr/bin/perl

=pod

=head1 NAME

maven_scrape.pl - Script to retrieve POM files from Maven Central.

=head1 SYNOPSIS

    % maven_scrape.pl [--directory <dir_name>] [--print_only] [--sleep <integer>] <JSON_file>

=head1 DESCRIPTION

This script will go through the JSON search results from Maven Central and download files
from Maven Central.

=head1 AUTHOR

Jeremiah Lee <jeremiah_AT_sourceninja_DOT_com>

=cut

use warnings;
use strict;

use JSON;
use Getopt::Long;
use File::Path qw/mkpath/;

my($print_only, $sleep);
my $BASE_DIRECTORY;

GetOptions(
           'directory=s'  => \$BASE_DIRECTORY,
           'print_only|d' => \$print_only,
           'sleep=i'      => \$sleep,
);

unless( $BASE_DIRECTORY ) {
  print STDERR "You must provide an output directory!\n";
  exit 1;
}

my $json_string;

{
  local $/;
  undef $/;

  $json_string = <>;
}

my $json_ref = decode_json $json_string;

die "Did not get valid JSON!" unless $json_ref;

foreach my $package (@{$json_ref->{response}{docs}}) {
  my $url = construct_url($package);
  if( ($sleep and $sleep > 0) and not $print_only ) {
      sleep $sleep;
  }

  #trap any error when making the directory
  eval { mkpath $url->{path}; };

  print $url->{wget}, "\n";
  system $url->{wget} unless $print_only;
}


sub construct_url {
  my $package_info = shift;

  my $path = $package_info->{g};
  $path =~ s{[.]}{/}g;

  my $artifact = $package_info->{a};
  my $version  = $package_info->{latestVersion};

  my $filename = $artifact . '-' . $version . $package_info->{ec}[0];

  { path => "$BASE_DIRECTORY/$path", wget => "wget -O '$BASE_DIRECTORY/$path/$filename' -q 'http://search.maven.org/remotecontent?filepath=${path}/${artifact}/${version}/${filename}'" }
}
