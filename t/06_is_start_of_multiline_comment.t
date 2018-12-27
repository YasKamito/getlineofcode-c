use strict;
use warnings;
use Test::More;
use LineOfCodeC;

my $obj = LineOfCodeC->new;

subtest 'code1, /* ' => sub {
     my $str = "   /* これはコメントです ";
    my $got = $obj->is_start_of_multiline_comment($str);
    is $got, 1;
};

subtest 'code2, /**//** ' => sub {
     my $str = "   /* これはコメントです *//** ";
    my $got = $obj->is_start_of_multiline_comment($str);
    is $got, 1;
};

subtest 'code3, /* false' => sub {
     my $str = "   /* これはコメントです */";
    my $got = $obj->is_start_of_multiline_comment($str);
    is $got, 0;
};

subtest 'code4, /* false' => sub {
     my $str = "/* これはコメントです */";
    my $got = $obj->is_start_of_multiline_comment($str);
    is $got, 0;
};

subtest 'code5 false' => sub {
     my $str = " int a;";
    my $got = $obj->is_start_of_multiline_comment($str);
    is $got, 0;
};

subtest 'code6 false' => sub {
     my $str = "   ";
    my $got = $obj->is_start_of_multiline_comment($str);
    is $got, 0;
};

subtest 'code7 false' => sub {
     my $str = "sprintf(errstr1, \"/** %s ** Proc:%d Thread:%d\", practice, Mypno, *Thread_No);   ";
    my $got = $obj->is_start_of_multiline_comment($str);
    is $got, 0;
};

subtest 'code8 true' => sub {
     my $str = "/***************************************************************************//**";
    my $got = $obj->is_start_of_multiline_comment($str);
    is $got, 1;
};

done_testing;
