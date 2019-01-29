# getLineOfCode

## Overview

Gitリポジトリを基に、ソースコードの変更行数、削除定数、ならびにソースコード全体の有効行数、コメント行数を出力します。

## Description

* 各ソースコードにおけるGitリポジトリのコミット間のソースコード変更行数を出力します。
* 変更前コミットと変更後コミットのコミットハッシュをそれぞれコマンドオプションに指定することにより、そのコミット間で変更のあったC言語ソースコードを抽出し、変更行数を取得します。
* 変更のあったC言語ソースコードのコメント行と有効行を取得します。
* コマンドオプション`--sum`を指定することにより、全てのファイルの各行数合計値を算出します。
* 出力形式としてcsvとjsonをサポートします。

## Demo

```
準備中
```

## Requirement

* Perl 5.x

## Usage

```
$ cm --help

This tool for Obtaining line of source code information based on git repository.

Usage:
     cm.pl {--ls-files|--git-diff} [options]

Mode:
         --ls-files          print all files on repository.
         --git-diff          print changed files between commit hashes.

Options:
        [--from]             commit hash before change.                 (default: HEAD^)
        [--to]               commit hash after change.                  (default: HEAD)
        [--sum]              total count line of all files.             (default: false)
        [--function]         print function metrics.                    (default: false)
        [--format(csv|json)] set the output format.                     (default: csv)

```

## Install

* gitリポジトリをclone

```
$ git clone ....
$ cd getlineofcode-c
```

* perlのモジュールパスの通っているディレクトリに`lib/*.pm`をコピーする

```
ex)

$ perl -E 'say for @INC'
/Users/xxxxxx/perl5/lib/perl5/5.18.2
/Users/xxxxxx/perl5/lib/perl5
.

$ cp -p lib/*.pm /Users/xxxxxx/perl5/lib/perl5/.
```

* コマンド実行パスの通っているディレクトリに`bin/*.pl`をコピーする

```
ex)

$ cp -p bin/*.pl /Users/xxxxxx/perl5/bin/.
```

