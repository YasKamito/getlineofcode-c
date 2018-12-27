# t/02_new.t
use strict;
use warnings;
use Test::More;
use LineOfCodeC;

my $obj = LineOfCodeC->new;

subtest 'code1, //' => sub {
    my $str = "int a; // これはコメントです";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 1;
};

subtest 'code2, //' => sub {
    my $str = "   include <stdio.h>; // これはコメントです";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 1;
};

subtest 'code3, //' => sub {
    my $str = "   extern int (*test)( int , char *); // これはコメントです";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 1;
};

subtest 'code4, //' => sub {
    my $str = " for (idx=0; idx<TThMax; idx++)  // これはコメントです";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 1;
};

subtest 'code5, //' => sub {
    my $str = " sprintf(errstr1, \"/**/ %s ** //Proc:%d\", practice, Mypno); // これはコメントです";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 1;
};

subtest 'code6, // false' => sub {
    my $str = "   // これはコメントです";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 0;
};

subtest 'code7, // false' => sub {
    my $str = "// これはコメントです";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 0;
};

subtest 'code10, // false' => sub {
    my $str = "";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 0;
};

subtest 'code1, /**/' => sub {
    my $str = "int a; /* これはコメントです */";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 1;
};

subtest 'code2, /**/' => sub {
    my $str = "   include <stdio.h>; /* これはコメントです */";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 1;
};

subtest 'code3, /**/' => sub {
    my $str = "   extern int (*test)( int , char *); /* これはコメントです */";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 1;
};

subtest 'code4, /**/' => sub {
    my $str = " for (idx=0; idx<TThMax; idx++)  /* これはコメントです */";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 1;
};

subtest 'code5, /**/' => sub {
    my $str = " sprintf(errstr1, \"/**/ %s ** //Proc:%d\", practice, Mypno); /* これはコメントです */";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 1;
};

subtest 'code6, /**/ false' => sub {
    my $str = "   /* これはコメントです */";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 0;
};

subtest 'code7, /**/ false' => sub {
    my $str = "/* これはコメントです */";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 0;
};

subtest 'code8 false' => sub {
    my $str = " int a;";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 0;
};

subtest 'code9 false' => sub {
    my $str = "   ";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 0;
};

subtest 'code10 false' => sub {
    my $str = "  /*******//** ";
    my $got = $obj->is_code_with_1line_comment($str);
    is $got, 0;
};

done_testing;
