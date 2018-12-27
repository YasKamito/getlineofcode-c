package GitChangeOfCode;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    bless \%args, $class;
}

sub move_to_git_dir {

  if ($ENV{GIT_DIR}) {
    chdir($ENV{GIT_DIR}) or die $!;
  }

  my $gitdir;
  open my $rs, "git rev-parse --git-dir |";
  my @rlist = <$rs>;
  close $rs;
  $gitdir = join '', @rlist;
  $gitdir =~ s/(\r\n|\r|\n)$//;
  if ($gitdir) {
    chdir($gitdir);
    chdir("../");
  }
}

sub get_change_of_line{

  my $self = shift;
  my ($fname, $cmtfrom, $cmtto) = @_;

  my %codeinfo = ();

  open FH1, "git diff --shortstat $cmtfrom..$cmtto -- $fname |" or die $!;
  while (<FH1>) {
    chomp;
    my @result = split(/,/, $_);
    foreach my $parts(@result){
      next if $parts =~ /file changed/;

      $parts =~ /(.+)\s(.+)\(/;
      my $condition = $2;
      my $count = $1;
      $count =~ s/^\s*(.+?)\s*$/$1/;
      $codeinfo{$condition} = $count;
    }
  }
  close FH1;
  return \%codeinfo;
}

sub get_code_info{

  my $self = shift;
  my ($cmtfrom, $cmtto) = @_;

  my %hash = ();

  open FH, "git diff --name-only $cmtfrom..$cmtto |" or die $!;
  while (<FH>) {
    chomp;
    if ($_ =~ m/^.*\.c$|^.*\.h$|^.*\.cpp$|^.*\.sqc$/) {
      my $fname = $_;
      $hash{$fname} = $self->get_change_of_line($fname, $cmtfrom, $cmtto);
      print "";
    }
  }
  close FH;

  return \%hash;

}

1;
