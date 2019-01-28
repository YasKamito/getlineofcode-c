use strict;
use warnings;
use Test::More;
use LineOfCodeC;

my $obj = LineOfCodeC->new;

subtest 'code1, true ' => sub {
    # 左波括弧カウンタが1で、文字列内に左波括弧が含まれるため true
    my $str = "void hashaddrdump(nodeptr *p){";
    my ($got, $func_nest_count, $func_max_nest_count) = $obj->is_left_bracket($str, 1, 0);
    is $got, 1;
    is $func_nest_count, 2;
    is $func_max_nest_count, 2;
};

subtest 'code2, false ' => sub {
    # 左波括弧カウンタが0であるため false
    my $str = "void hashaddrdump(nodeptr *p){   /* testeste */";
    my ($got, $func_nest_count, $func_max_nest_count) = $obj->is_left_bracket($str, 0, 0);
    is $got, 0;
    is $func_nest_count, 0;
    is $func_max_nest_count, 0;
};

subtest 'code3, false ' => sub {
    # 左波括弧カウンタが0であるため false
    my $str = "void hashaddrdump(nodeptr *p){   /* testeste */";
    my ($got, $func_nest_count, $func_max_nest_count) = $obj->is_left_bracket($str, 3, 3);
    is $got, 1;
    is $func_nest_count, 4;
    is $func_max_nest_count, 4;
};

subtest 'code4, false ' => sub {
    # 左波括弧カウンタが1、かつ左波括弧が存在しないため false
    my $str = "void hashaddrdump(nodeptr *p)";
    my ($got, $func_nest_count, $func_max_nest_count) = $obj->is_left_bracket($str, 1, 0);
    is $got, 0;
    is $func_nest_count, 1;
    is $func_max_nest_count, 0;
};

subtest 'code5, false ' => sub {
    # 左波括弧カウンタが1、かつ左波括弧が存在するため true
    my $str = "{";
    my ($got, $func_nest_count, $func_max_nest_count) = $obj->is_left_bracket($str, 1, 3);
    is $got, 1;
    is $func_nest_count, 2;
    is $func_max_nest_count, 3;
};

done_testing;
