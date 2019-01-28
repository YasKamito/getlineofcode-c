use strict;
use warnings;
use Test::More;
use LineOfCodeC;

my $obj = LineOfCodeC->new;

subtest 'code1, true ' => sub {
    my $str = "void hashaddrdump(nodeptr *p){   /* testeste */";
    my $name = "";
    my ($got, $func_count, $func_name, $func_nest_count, $func_loc, $func_max_nest_count) = $obj->get_function_info($str, 0, $name, 0, 0, 0);
    is $got, 1;
    is $func_count, 1;
    is $func_name, "void hashaddrdump(nodeptr *p)";
    is $func_nest_count, 1;
    is $func_loc, 0;
    is $func_max_nest_count, 1;
};

subtest 'code2, true ' => sub {
    my $str = "void hashaddrdump(nodeptr *p){   /* testeste */";
    my $name = "void hashaddrdump(nodeptr *p)";
    my ($got, $func_count, $func_name, $func_nest_count, $func_loc, $func_max_nest_count) = $obj->get_function_info($str, 1, $name, 1, 0, 0);
    is $got, 2;
    is $func_count, 1;
    is $func_name, "void hashaddrdump(nodeptr *p)";
    is $func_nest_count, 2;
    is $func_loc, 1;
    is $func_max_nest_count, 2;
};

subtest 'code3, true ' => sub {
    my $str = "void hashaddrdump(nodeptr *p)}   /* testeste */";
    my $name = "void hashaddrdump(nodeptr *p)";
    my ($got, $func_count, $func_name, $func_nest_count, $func_loc, $func_max_nest_count) = $obj->get_function_info($str, 1, $name, 2, 0, 2);
    is $got, 2;
    is $func_count, 1;
    is $func_name, "void hashaddrdump(nodeptr *p)";
    is $func_nest_count, 1;
    is $func_loc, 1;
    is $func_max_nest_count, 2;
};

subtest 'code4, true ' => sub {
    my $str = "void hashaddrdump(nodeptr *p)}   /* testeste */";
    my $name = "void hashaddrdump(nodeptr *p)";
    my ($got, $func_count, $func_name, $func_nest_count, $func_loc, $func_max_nest_count) = $obj->get_function_info($str, 1, $name, 1, 0, 2);
    is $got, 3;
    is $func_count, 1;
    is $func_name, "void hashaddrdump(nodeptr *p)";
    is $func_nest_count, 0;
    is $func_loc, 1;
    is $func_max_nest_count, 2;
};

subtest 'code5, true ' => sub {
    my $str = "void hashaddrdump(nodeptr *p)";
    my $name = "testtest";
    my ($got, $func_count, $func_name, $func_nest_count, $func_loc, $func_max_nest_count) = $obj->get_function_info($str, 1, $name, 0, 0, 2);
    is $got, 0;
    is $func_count, 1;
    is $func_name, "testtestvoid hashaddrdump(nodeptr *p)";
    is $func_nest_count, 0;
    is $func_loc, 0;
    is $func_max_nest_count, 2;
};

#subtest 'code2, false ' => sub {
#    # 左波括弧カウンタが0であるため false
#    my $str = "void hashaddrdump(nodeptr *p){   /* testeste */";
#    my ($got, $func_nest_count) = $obj->is_right_bracket($str, 0);
#    is $got, 0;
#    is $func_nest_count, 0;
#};
#
#subtest 'code3, false ' => sub {
#    # 左波括弧カウンタが3で、右波括弧が含まれるため true
#    my $str = "void hashaddrdump(nodeptr *p)}   /* testeste */";
#    my ($got, $func_nest_count) = $obj->is_right_bracket($str, 3);
#    is $got, 1;
#    is $func_nest_count, 2;
#};
#
#subtest 'code4, false ' => sub {
#    # 左波括弧カウンタが1、かつ右波括弧が存在しないため false
#    my $str = "void hashaddrdump(nodeptr *p)";
#    my ($got, $func_nest_count) = $obj->is_right_bracket($str, 1);
#    is $got, 0;
#    is $func_nest_count, 1;
#};
#
#subtest 'code5, ture ' => sub {
#    # 左波括弧カウンタが1、かつ左波括弧が存在するため true
#    my $str = "}";
#    my ($got, $func_nest_count) = $obj->is_right_bracket($str, 1);
#    is $got, 1;
#    is $func_nest_count, 0;
#};

done_testing;
