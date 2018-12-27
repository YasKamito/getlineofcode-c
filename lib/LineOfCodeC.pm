package LineOfCodeC;
use strict;
use warnings;

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

sub count {
    my $self = shift;
    my ($filename) = @_;

    my $fh;
    my %hash = ();
    my @header;
    my @codecnt;
    my $multiline_flg;

    $multiline_flg = 0;

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
        }
    }

    # push(@codecnt, $hash{'FILENAME'}||'0');
    # push(@codecnt, $hash{'CODE'}||'0');
    # push(@codecnt, $hash{'CODECOMMENT'}||'0');
    # push(@codecnt, $hash{'COMMENT'}||'0');
    # push(@codecnt, $hash{'BLANK'}||'0');
    #$NODE{$filename} = { %hash };
    return \%hash;
}

1;
