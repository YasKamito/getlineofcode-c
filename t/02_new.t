# t/02_new.t
use strict;
use warnings;
use Test::More;
use LineOfCodeC;

my $obj = LineOfCodeC->new;
isa_ok $obj, 'LineOfCodeC';

done_testing;
