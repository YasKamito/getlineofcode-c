# t/02_new.t
use strict;
use warnings;
use Test::More;
use LineOfCodeC;

my $obj = LineOfCodeC->new;

subtest 'nothing' => sub {
    my $str = "";
    my $got = $obj->is_blank($str);
    is $got, 1;
};

subtest 'blank' => sub {
    my $str = "    ";
    my $got = $obj->is_blank($str);
    is $got, 1;
};

subtest 'tab' => sub {
    my $str = "\t\t\t";
    my $got = $obj->is_blank($str);
    is $got, 1;
};

subtest 'string' => sub {
    my $str = "abcdr";
    my $got = $obj->is_blank($str);
    is $got, 0;
};

subtest 'string on line end' => sub {
    my $str = "   abcdr";
    my $got = $obj->is_blank($str);
    is $got, 0;
};

subtest 'string on line head' => sub {
    my $str = "abcdr   ";
    my $got = $obj->is_blank($str);
    is $got, 0;
};

subtest 'number' => sub {
    my $str = "12345";
    my $got = $obj->is_blank($str);
    is $got, 0;
};

done_testing;
