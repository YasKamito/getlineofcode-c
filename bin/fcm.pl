#!/usr/bin/perl -w

use strict;
use warnings;
use LineOfCodeC;
use Data::Dumper;

my $filename                = "@ARGV";
my $locobj                    = LineOfCodeC->new;
my $codemet;
my $functions;

$codemet = $locobj->count($filename);
$functions = $codemet->{'functions'};

my @header = ( 'id', 'loc', 'nest', 'name');
print join("\t", @header) . "\n";

foreach my $func ( sort keys $functions ){
	my @body;
	push(@body, $func);
	push(@body, $functions->{$func}->{'loc'}||'0');
	push(@body, $functions->{$func}->{'nest'}||'0');
	push(@body, $functions->{$func}->{'name'}||'0');
	print join("\t", @body) . "\n";
}

1;
