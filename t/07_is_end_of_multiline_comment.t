use strict;
use warnings;
use Test::More;
use LineOfCodeC;

my $obj = LineOfCodeC->new;

subtest 'code1, false ' => sub {
    # 行頭/*から始まっているのでfalse
    my $str = "   /* これはコメントです ";
    my $got = $obj->is_end_of_multiline_comment($str);
    is $got, 0;
};

subtest 'code2, false *//** ' => sub {
    # 行末*/でないのでfalse
    my $str = "    これはコメントです *//** ";
    my $got = $obj->is_end_of_multiline_comment($str);
    is $got, 0;
};

subtest 'code3, false /* ' => sub {
    # 行末*/で終わっているが、行頭/*から始まっており、1lineコメントのためfalse
    my $str = "   /* これはコメントです */";
    my $got = $obj->is_end_of_multiline_comment($str);
    is $got, 1;
};

subtest 'code4, true */ ' => sub {
    my $str = " これはコメントです */";
    my $got = $obj->is_end_of_multiline_comment($str);
    is $got, 1;
};

subtest 'code5 false' => sub {
    # 行末*/でないのでfalse
    my $str = " int a;";
    my $got = $obj->is_end_of_multiline_comment($str);
    is $got, 0;
};

subtest 'code6 false' => sub {
    # 行末*/でないのでfalse
    my $str = "   ";
    my $got = $obj->is_end_of_multiline_comment($str);
    is $got, 0;
};

subtest 'code7 false' => sub {
    # 行末*/のためtrue
     my $str = "sprintf(errstr1, \"** %s ** Proc:%d Thread:%d\", practice, Mypno, *Thread_No);  */  ";
    my $got = $obj->is_end_of_multiline_comment($str);
    is $got, 1;
};

subtest 'code8 false' => sub {
    # 行末*/のためtrue
     my $str = "*/";
    my $got = $obj->is_end_of_multiline_comment($str);
    is $got, 1;
};

subtest 'code9 true' => sub {
    # 行末*/のためtrue
     my $str = "*//*-< 001 DEL >-*/";
    my $got = $obj->is_end_of_multiline_comment($str);
    is $got, 1;
};

done_testing;
