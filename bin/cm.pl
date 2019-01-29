#!/usr/bin/perl -w
# gitリポジトリを基に、コミット間のソースコード変更情報を取得する。

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use File::Basename;
use File::Find;
use File::Spec;
use JSON qw/ encode_json /;
use LineOfCodeC;
use GitChangeOfCode;

my $cmdname = basename $0;
my $cmtfrom = 'HEAD^';
my $cmtto = 'HEAD';
my $lsfilesmode = 0;
my $gitdiffmode = 0;
my $optsum = 0;
my $optfunc = 0;
my $gitbranch = 'master';
my $output_format = "csv";
my $help;
my $codestat;

my %ls_mod = ();
my $search_regex = qr/^.*\.c$|^.*\.h$|^.*\.cpp$|^.*\.sqc$/sm;

my $locobj = LineOfCodeC->new;
my $gcolobj = GitChangeOfCode->new;

GetOptions(
  'ls-files'    => \$lsfilesmode,
  'git-diff'    => \$gitdiffmode,
  'from=s'      => \$cmtfrom,
  'to=s'        => \$cmtto,
  'sum'         => \$optsum,
  'function'    => \$optfunc,
  'format=s'    => \$output_format,
  'branch=s'    => \$gitbranch,
  'help'        => \$help
) || exit 0;

# ==============================
# メイン処理
# ==============================

# ヘルプを表示
if ($help) {
  die show_help();
}

# コマンドオプションをチェック
if (is_valid_options()) {
  die show_help();
}

# Gitリポジトリルートディレクトリに移動
$gcolobj->move_to_git_dir();

# 変更のあったコード情報を取得
if ($gitdiffmode) {
  $codestat = $gcolobj->get_code_info($cmtfrom, $cmtto);
  $lsfilesmode = 0;
}

# リポジトリ管理下のすべてのコード情報を取得
if ($lsfilesmode) {
  $codestat = $gcolobj->get_ls_files($cmtfrom, $cmtto);
}

# コード有効行情報を取得
$codestat = get_loc($codestat);

# 集計モードの場合、コード情報を集計する
if ($optsum) {
  $codestat = summary($codestat);
}

# 指定した出力フォーマット形式で出力
if ($output_format eq "csv"){
  print_by_csv($codestat);
}elsif ($output_format eq "json") {
  print_by_json($codestat);
}

# ==============================
# メイン処理ここまで
# ==============================

# ==============================
# 以下、関数定義
# ==============================
sub is_valid_options {
  return 1 if ($gitdiffmode ne 1 && $lsfilesmode ne 1); 
  return 1 if ($output_format ne "csv" && $output_format ne "json"); 
  return 0;
}

sub show_help {
    my $help_doc = <<EOF;

This tool for Obtaining line of source code information based on git repository.

Usage:
     $cmdname {--ls-files|--git-diff} [Options] filename[or direcory]

Mode:
         --ls-files          print all files on repository.
         --git-diff          print changed files between commit hashes.

Options:
        [--from]             commit hash before change.                 (default: HEAD^)
        [--to]               commit hash after change.                  (default: HEAD)
        [--sum]              total count line of all files.             (default: false)
        [--function]         print function metrics.                    (default: false)
        [--format(csv|json)] set the output format.                     (default: csv)

EOF
    return $help_doc;
}

sub get_loc {

  my $hash = shift;
  my %result = ();

  foreach my $filename (sort keys %$hash)
  {
    my $col = $hash->{$filename};
    my $loc = {};
    my $merge = {};
    
    if (-f $filename){
      $loc = $locobj->count($filename);
    }

    $merge = {%{$col}, %{$loc}};
    $result{$filename} = $merge;
  }

  return \%result;
}

sub summary {
  
  my $hash = shift;
  my %result;
  my %sumh;

  foreach my $filename (sort keys %$hash)
  {
    my $codeinfo = $hash->{$filename};

    $sumh{"code"}         += $codeinfo->{"code"}||'0';
    $sumh{"codecomment"}  += $codeinfo->{"codecomment"}||'0';
    $sumh{"comment"}      += $codeinfo->{"comment"}||'0';
    $sumh{"blank"}        += $codeinfo->{"blank"}||'0';
    $sumh{"insertions"}   += $codeinfo->{"insertions"}||'0';
    $sumh{"deletions"}    += $codeinfo->{"deletions"}||'0';

  }

  $result{"total"} = \%sumh;
  return \%result;

}

sub print_by_csv{
  
  my $hash = shift;
  my @header;

  if ($optfunc) {
    @header = ( 'filename', 'code', 'codecomment', 'comment', 'blank', 'insertions', 'deletions', 'func_id', 'func_loc', 'func_nest', 'func_name');
  }else{
    @header = ( 'filename', 'code', 'codecomment', 'comment', 'blank', 'insertions', 'deletions');
  }
  print join("\t", @header) . "\n";

  foreach my $filename (sort keys %$hash)
  {
    my $codeinfo = $hash->{$filename};
    my @output;
    my $functions;
    push(@output, $filename);
    push(@output, $codeinfo->{'code'}||'-');
    push(@output, $codeinfo->{'codecomment'}||'-');
    push(@output, $codeinfo->{'comment'}||'-');
    push(@output, $codeinfo->{'blank'}||'-');
    push(@output, $codeinfo->{'insertions'}||'-');
    push(@output, $codeinfo->{'deletions'}||'-');
    print join("\t", @output) . "\n";

    if ($optfunc) {
      if (! -f $filename) {
        next;
      }
      $functions = $codeinfo->{'functions'};
      foreach my $func ( sort keys $functions ){
        my @body;
        push(@body, "\t\t\t\t\t\t");
        push(@body, $func);
        push(@body, $functions->{$func}->{'loc'}||'0');
        push(@body, $functions->{$func}->{'nest'}||'0');
        push(@body, $functions->{$func}->{'name'}||'0');
        print join("\t", @body) . "\n";
      }
    }
  }
}

sub print_by_json {
  my $hash = shift;
  my $json = encode_json({%$hash});
  #print Dumper($json);
  print $json . "\n";
}

1;
