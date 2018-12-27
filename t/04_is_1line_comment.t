# t/02_new.t
use strict;
use warnings;
use Test::More;
use LineOfCodeC;

my $obj = LineOfCodeC->new;

subtest '//,normal' => sub {
    my $str = "// これはコメントです";
    my $got = $obj->is_1line_comment($str);
    is $got, 1;
};

subtest '//,blank on the head' => sub {
    my $str = "    // これはコメントです";
    my $got = $obj->is_1line_comment($str);
    is $got, 1;
};

subtest '//,string on the head' => sub {
    my $str = "int a;    // これはコメントです";
    my $got = $obj->is_1line_comment($str);
    is $got, 0;
};

subtest '/**/normal' => sub {
    my $str = "/* これはコメントです */";
    my $got = $obj->is_1line_comment($str);
    is $got, 1;
};

subtest '/**/,blank on the head' => sub {
    my $str = "   /* これはコメントです */";
    my $got = $obj->is_1line_comment($str);
    is $got, 1;
};

subtest '/**/,string on the head' => sub {
    my $str = "int a;   /* これはコメントです */";
    my $got = $obj->is_1line_comment($str);
    is $got, 0;
};

subtest '/**/,number on the head' => sub {
    my $str = "1  /* これはコメントです */";
    my $got = $obj->is_1line_comment($str);
    is $got, 0;
};

subtest '/**/,string on the end' => sub {
    my $str = "/* これはコメントです */ int a;";
    my $got = $obj->is_1line_comment($str);
    is $got, 0;
};

done_testing;
