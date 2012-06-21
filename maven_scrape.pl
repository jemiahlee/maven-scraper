#!/usr/bin/perl

use warnings;
use strict;

use JSON;
use File::Path qw/mkpath/;

my $json_string;

{
  local $/;
  undef $/;

  $json_string = <>;
}

my $json_ref = decode_json $json_string;

die "Did not get valid JSON!" unless $json_ref;

foreach my $package (@{$json_ref->{response}{docs}}[0..2]) {
  my $url = construct_url($package);
  sleep 2;

  #trap any error when making the directory
  eval { mkpath $url->{path}; };

  print $url->{wget}, "\n";
  system $url->{wget};
}


sub construct_url {
  my $package_info = shift;

  my $path = $package_info->{g};
  $path =~ s{[.]}{/}g;

  my $artifact = $package_info->{a};
  my $version  = $package_info->{latestVersion};

  my $filename = $artifact . '-' . $version . $package_info->{ec}[0];

  { path => $path, wget => "wget -O '$path/$filename' -q http://search.maven.org/remotecontent?filepath=${path}/${artifact}/${version}/${filename}" }
}

