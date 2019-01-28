package LineOfCodeC;
use strict;
use warnings;
use Data::Dumper;

sub new {
    my ($class, %args) = @_;
    bless \%args, $class;
}

sub is_blank {
    my $self = shift;
    my ($str) = @_;
    $str =~/^\s*$/ ? 1 : 0;
}

sub is_1line_comment {
    my $self = shift;
    my ($str) = @_;
    $str =~ s/^\s*(.+?)\s*$/$1/;
    # 行頭ブランク(\s)から始まる//。または/* (文字) */
    $str =~/^\/\/.*$|^\/\*.*\*\/$/ ? 1 : 0;
}

sub is_code_with_1line_comment {
    my $self = shift;
    my ($str) = @_;
    $str =~ s/^\s*(.+?)\s*$/$1/;
    # ソースコード有効文字：!"#$%&'()*,-+.:;<>?@[]\^_`{|}~a-zA-Z0-9およびブランク
    # ソースコード有効文字から始まる//または/* */
    # 行頭から//(または/*)までがすべてブランクのものを除く
    # 行末が/*で終わるものは除く（複数コメント行の開始行となるため）
    #
    if($str eq ""){
      return 0;
    }elsif($str =~ /(?!\s*\/\/)([!"#\$%&'()*,\-\+.:;<>?@\[\]\\\^_`{|}~a-zA-Z0-9\s]+\/\/.*$)/) {
        $str =~ /\/\*+$/ ? 0 : 1;
    }elsif($str =~/(?!\/\*)([!"#\$%&'()*,\-\+.:;<>?@\[\]\\\^_`{|}~a-zA-Z0-9\s]+\/\*.*\*\/\s*$)/){
        $str =~ /\/\*+$/ ? 0 : 1;
    }else{
        return 0;
    }
}

sub is_start_of_multiline_comment {
    my $self = shift;
    my ($str) = @_;
    $str =~ s/^\s*(.+?)\s*$/$1/;
    # 行頭が/*から始まる
    if ($str =~ /^\/\*/){
        # 末尾が*/でないものは複数行コメントとなるためtrue
        $str =~ /.+\*\/\s*$/ ? 0 : 1;
    }else{
        return 0;
    }
}

sub is_end_of_multiline_comment {
    my $self = shift;
    my ($str) = @_;
    $str =~ s/^\s*(.+?)\s*$/$1/;
    # 行頭が/*から始まる
    if($str =~ /^\/\*/){
        return 0;
    }else{
        # 末尾が*/のもの複数行コメント終了位置となるためtrue
        $str =~ /.*\*\/\s*$/ ? 1 : 0;
    }
}

sub is_start_of_function {
    my $self = shift;
    my ($str, $func_name, $func_nest_count) = @_;

    # 左波括弧が既にカウントアップされてるということは関数開始位置ではないのでfalse
    if(0 < $func_nest_count){
        return (0, $func_name, $func_nest_count);
    }

    # 左波括弧がカウントゼロで、include文はfalse
    if($str =~ /(^\s*\#include*)(.*)/){
        return (0, $func_name, $func_nest_count);
    }

    # 左波括弧がカウントゼロで、セミコロンが含まれるのは変数定義なのでfalse
    if($str =~ /(^\s*.*?\s*)(;)(.*?\s*$)/){
        return (0, $func_name, $func_nest_count);
    }

    # 左波括弧がカウントゼロで、かつ行末が左波括弧で終わっているということは
    # 関数開始位置なのでtrue
    if($str =~ /(^\s*.*?\s*)(\{)(.*?\s*$)/){
        $func_nest_count = 1;
        my $func_name_out = $func_name . $1;
        return (1, $func_name_out, $func_nest_count) ;
    }else{
        # 左波括弧がカウントゼロで、かつ行末が左波括弧でないということは
        # 関数名定義部分なので、func_nameに文字列連結して関数名を作成する
        # (is_blunkまたはis_commentがtrueのときは来ない想定)
        my $func_name_out = $func_name . $str;
        return (0, $func_name_out, $func_nest_count);
    }
}

sub is_left_bracket {
    my $self = shift;
    my ($str, $func_nest_count, $func_max_nest_count) = @_;

    # 左波括弧がカウントアップされていないということはまだ関数内ではないのでfalse
    if(0 >= $func_nest_count){
        return (0, $func_nest_count, $func_max_nest_count);
    }

    # 左波括弧がカウント１以上で、かつ左波括弧が含まれるということは
    # 制御構文のネストが発生しているためtrue
    # 最大ネスト数を更新
    if($str =~ /(^\s*.*?\s*)(\{)(.*?\s*$)/){
        $func_nest_count++;
        if($func_max_nest_count < $func_nest_count){
            $func_max_nest_count = $func_nest_count;
        }
        return (1, $func_nest_count, $func_max_nest_count) ;
    }else{
        # 左波括弧がカウント１以上で、かつ左波括弧が含まれていないので現状維持
        return (0, $func_nest_count, $func_max_nest_count);
    }
}

sub is_right_bracket {
    my $self = shift;
    my ($str, $func_nest_count) = @_;

    # 左波括弧がカウントアップされていないということはまだ関数内ではないのでfalse
    if(0 >= $func_nest_count){
        return (0, $func_nest_count);
    }

    # 左波括弧がカウント１以上で、かつ右波括弧が含まれるということは
    # 制御構文のネストが減少しているためtrue
    if($str =~ /(^\s*.*?\s*)(\})(.*?\s*$)/){
        $func_nest_count--;
        return (1, $func_nest_count) ;
    }else{
        # 左波括弧がカウント１以上で、かつ右波括弧が含まれていないので現状維持
        return (0, $func_nest_count);
    }
}

sub get_function_info {
    my $self = shift;
    my ($str, $func_count, $func_name, $func_nest_count, $func_loc, $func_max_nest_count) = @_;

    # 関数開始位置の場合、
    #    関数カウントUP
    #    関数LOC初期化
    #    ネスト最大数初期化
    my ($got_st, $got_st_func_name, $got_st_func_nest_count) = $self->is_start_of_function($str, $func_name, $func_nest_count);
    $func_name = $got_st_func_name;
    $func_nest_count = $got_st_func_nest_count;
    if(1 == $got_st){
        $func_count++;
        $func_loc = 0;
        $func_max_nest_count = $got_st_func_nest_count;
        return (1, $func_count, $got_st_func_name, $got_st_func_nest_count, $func_loc, $func_max_nest_count ) ;
    }

    if(1 <= $func_nest_count){
        $func_loc++;
        # 関数内、左波括弧が存在する場合
        my ($got_lft, $got_lft_func_nest_count, $got_lft_func_max_nest_count) = $self->is_left_bracket($str, $func_nest_count, $func_max_nest_count);
        $func_nest_count = $got_lft_func_nest_count;
        $func_max_nest_count = $got_lft_func_max_nest_count;

        # 関数内、右波括弧が存在する場合
        my ($got_rit, $got_rit_func_nest_count) = $self->is_right_bracket($str, $func_nest_count);
        $func_nest_count = $got_rit_func_nest_count;

        # 関数終了位置の場合
        if (0 == $func_nest_count){
            return (3, $func_count, $func_name, $func_nest_count, $func_loc, $func_max_nest_count ) ;
        }
        return (2, $func_count, $func_name, $func_nest_count, $func_loc, $func_max_nest_count ) ;
    }
    return (0, $func_count, $func_name, $func_nest_count, $func_loc, $func_max_nest_count ) ;
}

sub count {
    my $self = shift;
    my ($filename) = @_;

    my $fh;
    my %hash = ();
    my @header;
    my @codecnt;
    my $multiline_flg;

    my $func_count;
    my $func_name;
    my $func_nest_count;
    my $func_loc;
    my $func_max_nest_count;

    my %functions = ();
    my %function = ();

    $multiline_flg = 0;

    $func_count = 0;
    $func_name = "";
    $func_nest_count = 0;
    $func_loc = 0;
    $func_max_nest_count = 0;

    open $fh, '<', $filename
    or die "Cannot open '$filename': $!";
    
    while (my $line = <$fh>) {
        chomp $line;

        if($self->is_blank($line)){
            $hash{"blank"} += 1;
        }elsif($self->is_1line_comment($line)){
            $hash{"comment"} += 1;
        }elsif($self->is_code_with_1line_comment($line)){
            $hash{"codecomment"} += 1;
            my ($ret_got, 
                $ret_func_count, 
                $ret_func_name, 
                $ret_func_nest_count, 
                $ret_func_loc, 
                $ret_func_max_nest_count) = $self->get_function_info($line, 
                                                                $func_count, 
                                                                $func_name, 
                                                                $func_nest_count, 
                                                                $func_loc, 
                                                                $func_max_nest_count);
            if ( 3 == $ret_got){
                my $func_id = sprintf("%03d", $ret_func_count);
                $functions{$func_id}{"name"} = $ret_func_name;
                $functions{$func_id}{"loc"} = $ret_func_loc;
                $functions{$func_id}{"max_nest_count"} = $ret_func_max_nest_count;

                $func_name = "";
                $func_nest_count = 0;
                $func_loc = 0;
                $func_max_nest_count = 0;

            }else{
                $func_count = $ret_func_count;
                $func_name = $ret_func_name;
                $func_nest_count = $ret_func_nest_count;
                $func_loc = $ret_func_loc;
                $func_max_nest_count = $ret_func_max_nest_count;
            }
        }elsif($self->is_start_of_multiline_comment($line)){
            $hash{"comment"} += 1;
            $multiline_flg = 1;
        }elsif($self->is_end_of_multiline_comment($line)){
            $hash{"comment"} += 1;
            $multiline_flg = 0;
        }elsif($multiline_flg == 1){
            $hash{"comment"} += 1;
        }else{
            $hash{"code"} += 1;
            my ($ret2_got, 
                $ret2_func_count, 
                $ret2_func_name, 
                $ret2_func_nest_count, 
                $ret2_func_loc, 
                $ret2_func_max_nest_count) = $self->get_function_info($line, 
                                                                $func_count, 
                                                                $func_name, 
                                                                $func_nest_count, 
                                                                $func_loc, 
                                                                $func_max_nest_count);
            if ( 3 == $ret2_got){
                my $func_id = sprintf("%03d", $ret2_func_count);
                $functions{$func_id}{"name"} = $ret2_func_name;
                $functions{$func_id}{"loc"} = $ret2_func_loc;
                $functions{$func_id}{"nest"} = $ret2_func_max_nest_count;

                $func_name = "";
                $func_nest_count = 0;
                $func_loc = 0;
                $func_max_nest_count = 0;
            }else{
                $func_count = $ret2_func_count;
                $func_name = $ret2_func_name;
                $func_nest_count = $ret2_func_nest_count;
                $func_loc = $ret2_func_loc;
                $func_max_nest_count = $ret2_func_max_nest_count;
            }
        }
    }

    # push(@codecnt, $hash{'FILENAME'}||'0');
    # push(@codecnt, $hash{'CODE'}||'0');
    # push(@codecnt, $hash{'CODECOMMENT'}||'0');
    # push(@codecnt, $hash{'COMMENT'}||'0');
    # push(@codecnt, $hash{'BLANK'}||'0');
    #$NODE{$filename} = { %hash };
    $hash{"functions"} = \%functions;
    return \%hash;
}

1;
