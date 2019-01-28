use strict;
use warnings;
use Test::More;
use LineOfCodeC;

my $obj = LineOfCodeC->new;

subtest 'code1, false ' => sub {
    # 既に左波括弧カウンタが1以上であるため false
    my $str = "void hashaddrdump(nodeptr *p){";
    my $func = "test";
    my ($got, $func_name, $func_nest_count) = $obj->is_start_of_function($str, $func, 2);
    is $got, 0;
    is $func_nest_count, 2;
    is $func_name, "test";
};

subtest 'code2, true ' => sub {
    # 左波括弧カウンタが0、かつ左波括弧が行末にあるため true
    my $str = "void hashaddrdump(nodeptr *p){   /* testeste */";
    my $func = "test";
    my ($got, $func_name, $func_nest_count) = $obj->is_start_of_function($str, $func, 0);
    is $got, 1;
    is $func_nest_count, 1;
    is $func_name, "testvoid hashaddrdump(nodeptr *p)";
};

subtest 'code3, false ' => sub {
    # 左波括弧カウンタが0、かつ左波括弧が存在しないため false
    my $str = "void hashaddrdump(nodeptr *p)";
    my $func = "test";
    my ($got, $func_name, $func_nest_count) = $obj->is_start_of_function($str, $func, 0);
    is $got, 0;
    is $func_nest_count, 0;
    is $func_name, "testvoid hashaddrdump(nodeptr *p)";
};

subtest 'code4, false ' => sub {
    # 左波括弧カウンタが0、かつ左波括弧が存在するため true
    my $str = "{";
    my $func = "";
    my ($got, $func_name, $func_nest_count) = $obj->is_start_of_function($str, $func, 0);
    is $got, 1;
    is $func_nest_count, 1;
    is $func_name, "";
};

subtest 'code5, false ' => sub {
    # 左波括弧カウンタが0、セミコロンが存在するため false
    my $str = "char initword[HASHSIZE][MAXWORDLEN + 1];		/** tetete */";
    my $func = "";
    my ($got, $func_name, $func_nest_count) = $obj->is_start_of_function($str, $func, 0);
    is $got, 0;
    is $func_nest_count, 0;
    is $func_name, "";
};

subtest 'code6, false ' => sub {
    # 左波括弧カウンタが0、#includeが存在するため false
    my $str = "#include <stdio.h>";
    my $func = "";
    my ($got, $func_name, $func_nest_count) = $obj->is_start_of_function($str, $func, 0);
    is $got, 0;
    is $func_nest_count, 0;
    is $func_name, "";
};

subtest 'code7, false ' => sub {
    # 左波括弧カウンタが0、#defineが存在するため false
    my $str = "#define MY_KEY_ENTER     13";
    my $func = "";
    my ($got, $func_name, $func_nest_count) = $obj->is_start_of_function($str, $func, 0);
    is $got, 0;
    is $func_nest_count, 0;
    is $func_name, "";
};

subtest 'code8, false ' => sub {
    # 左波括弧カウンタが0、typedefが存在するため false
    my $str = "typedef struct { ";
    my $func = "";
    my ($got, $func_name, $func_nest_count) = $obj->is_start_of_function($str, $func, 0);
    is $got, 0;
    is $func_nest_count, 0;
    is $func_name, "";
};

subtest 'code9, false ' => sub {
    # 左波括弧カウンタが0、structが存在するため false
    my $str = " struct { ";
    my $func = "";
    my ($got, $func_name, $func_nest_count) = $obj->is_start_of_function($str, $func, 0);
    is $got, 0;
    is $func_nest_count, 0;
    is $func_name, "";
};

done_testing;
