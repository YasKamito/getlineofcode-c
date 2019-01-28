use strict;
use warnings;
use Test::More;
use LineOfCodeC;

my $obj = LineOfCodeC->new;

subtest 'code1, true ' => sub {
    # 左波括弧カウンタが1で、文字列内に右波括弧が含まれるため true
    my $str = "}elseif(nodeptr = p){";
    my ($got, $func_nest_count) = $obj->is_right_bracket($str, 2);
    is $got, 1;
    is $func_nest_count, 1;
};

subtest 'code2, false ' => sub {
    # 左波括弧カウンタが0であるため false
    my $str = "void hashaddrdump(nodeptr *p){   /* testeste */";
    my ($got, $func_nest_count) = $obj->is_right_bracket($str, 0);
    is $got, 0;
    is $func_nest_count, 0;
};

subtest 'code3, false ' => sub {
    # 左波括弧カウンタが3で、右波括弧が含まれるため true
    my $str = "void hashaddrdump(nodeptr *p)}   /* testeste */";
    my ($got, $func_nest_count) = $obj->is_right_bracket($str, 3);
    is $got, 1;
    is $func_nest_count, 2;
};

subtest 'code4, false ' => sub {
    # 左波括弧カウンタが1、かつ右波括弧が存在しないため false
    my $str = "void hashaddrdump(nodeptr *p)";
    my ($got, $func_nest_count) = $obj->is_right_bracket($str, 1);
    is $got, 0;
    is $func_nest_count, 1;
};

subtest 'code5, ture ' => sub {
    # 左波括弧カウンタが1、かつ左波括弧が存在するため true
    my $str = "}";
    my ($got, $func_nest_count) = $obj->is_right_bracket($str, 1);
    is $got, 1;
    is $func_nest_count, 0;
};

done_testing;
