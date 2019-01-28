#!/usr/bin/perl -w

use strict;
use warnings;
use LineOfCodeC;
use Data::Dumper;

my $filename                = "@ARGV";
my $locobj                    = LineOfCodeC->new;
my $codecnt;
my $code;
my @output;

$codecnt = $locobj->count($filename);

push(@output, $filename);
push(@output, $codecnt->{'code'}||'0');
push(@output, $codecnt->{'codecomment'}||'0');
push(@output, $codecnt->{'comment'}||'0');
push(@output, $codecnt->{'blank'}||'0');
print "@output\n";

print Dumper $codecnt;

1;
