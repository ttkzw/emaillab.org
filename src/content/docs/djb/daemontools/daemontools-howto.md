---
title: daemontools HOW-TO (α版)
sidebar:
  order: 1
---

Copyright 2000 滝澤 隆史 \<taki@cyber.email.ne.jp\>

Last modified: Sun Nov 19 19:29:10 2000

## <span id="prescript">前書き</span>

この文書はDJB氏のdaemontoolsパッケージに興味を持たれる方やこれから導入・運用しようとするかたに向けて書かれたものです。daemontoolsパッケージの概要、導入・設定方法、使用例などをまとめています。しかし、各ツールを詳細に説明するものではありません。そのため、この文書を読んだ後に、[マニュアル](http://cr.yp.to/daemontools.html)を読んでください。[日本語訳](http://www.emaillab.org/djb/tools/daemontools/top.html)もあります。
また、新山さんの [daemontools FAQ](https://www.unixuser.org/~euske/doc/daemontools/index.html)もありますのでそちらもご覧ください。

## <span id="chap1">1. 概要</span>

### <span id="chap1sec1">1.1. daemontools とは</span>

daemontoolsはサービスを安全・確実かつ容易に管理するためのツール集です。
主にサービスの制御、ログの収集、環境変数・資源制限を行います。

### <span id="chap1sec2">1.2. パッケージの内容</span>

daemontoolsパッケージに含まれているプログラムには次のものがあります。

|プログラム名|説明|
|---|---|
|`supervise`|サービスを開始させ、監視します。何らかのトラブルでサービスが停止したら、自動的に再起動させます。|
|`svc`|`supervise` により監視されているサービスを制御します。|
|`svok`|`supervise` が起動しているかを調べます。|
|`svstat`|`supervise` により監視されているサービスの状態を出力します。|
|`svscan`|サービスの集まりを開始させ、監視します。|
|`fghack`|自信をバックグランドに移すサービスがバックグランドに移るのを防ぐツールです。|
|`multilog`|標準入力から一続きの行を読み、任意の数のログに選択された行を追加します。|
|`tai64n`|各行に TAI64N 形式の正確なタイムスタンプを付けます。|
|`tai64nlocal`|TAI64N 形式のタイムスタンプを人が読める形式に変換します。|
|`setuidgid`|指定されたアカウントの uid と gid で別のプログラムを起動します。|
|`envuidgid`|指定されたアカウントの uid と gid を示す環境変数を設定して別のプログラムを起動させます。|
|`envdir`|指定したディレクトリにあるファイルによって修正された環境を設定して別のプログラムを起動させます。|
|`softlimit`|新しい資源制限を伴って別のプログラムを起動させます。|
|`setlock`|ファイルをロックして別のプログラムを起動させます。|

</tbody>
</table>

------------------------------------------------------------------------

### <span id="chap1sec3">1.3. 既存の他のプログラムとの違い</span>

既存の他のプログラムとに違いは次のとおりです。

- 自身が常駐するサービスの場合、何らかのトラブルが生じてサービスが死んだとき、通常は死んだまま。しかし、daemontoolsの`supervise`を使うと、サービスが突然死んでも、自動的に起動し直してくれる。
- サービスの中にはそのプロセスIDを*service*`.pid`のようなファイルに格納するものもあるが、そうでないものもある。一方、daemontoolsではサービスのプロセスIDを`supervise`が一括して管理している。そのため、その制御は `svc` を使って簡単にできる。
- SVR4形式のinitスクリプトでも起動／停止／再起動の指令は出せるが、daemontoolsの`svc`ではさらに多くの種類のシグナルを送ることができる。
- `syslogd` は負荷が高くなるとデータの取りこぼしがある。daemontoolsの`multilog`では取りこぼしは一切ない。また、ログのサイズの制限／循環、パターンマッチによりログの取捨選択ができるので効率のよいログの管理ができる。
- `syslogd` のタイムスタンプは一般に秒単位である。一方、`multilog`ではTAI64N形式のタイムスタンプで管理していて、その精度はナノ秒（ただし、現状のマシンクロックの制限により実質マイクロ秒の精度）。

## <span id="chap2">2. インストール</span>

### <span id="chap2sec1">2.1. daemontools のインストール</span>

次のサイトからdaemontoolsのパッケージdaemontools-0.70.tar.gzを入手します。

- https://cr.yp.to/daemontools/install.html

ファイルを展開し、そのディレクトリに移動します。

```
$ gzip -dc daemontools-0.70.tar.gz | tar xvf -
$ cd daemontools-0.70
```

コンパイルして、インストールします。

```
$ make
# make setup check
```

試験します。何も出力しなかったら正常です。

```
$ ./rts > rts.out
$ cmp rts.out rts.exp
```

タイムスタンプを確認します。各行の前の日時と後ろの日時は同じになります。ただし、端数の関係で1秒違うかもしれません。

```
$ date | ./tai64n | ./tai64nlocal
2000-05-05 11:16:53.959932500 Fri May 5 11:16:53 JST 2000
$ date | sh -c './multilog t e 2\>&1' | ./tai64nlocal
2000-05-05 11:17:11.739003500 Fri May 5 11:17:11 JST 2000
```

以上、何も問題が生じなければ、インストールは終了です。

#### 関連リンク

- [マニュアル: `daemontools` のインストール](/djb/tools/daemontools/install.html)

### <span id="chap2sec2">2.2. svscan の起動</span>

`svscan` が監視するディレクトリを作成します。`svscan` に関する説明は次章で行います。

```
# mkdir /service
# chmod 755 /service
```

ブートスクリプトに `svscan` を起動するコマンドを登録します。BSD形式の起動スクリプトであれば、`rc.local` などに、次のコマンドを追加してください。`PATH`は必要なものを設定してください。

```sh
env - PATH=/usr/local/bin:/usr/bin:/bin csh -cf 'svscan /service &'
```

SVR4形式の起動スクリプトであれば、次のようなスクリプト `svscan` を作成し、登録してください。OSにより少々修正する必要があります。

```sh
#!/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin

case "$1" in
  start)
        echo -n "Starting svscan: "
        exec env - PATH="$PATH" \
        csh -cf 'svscan /service &; echo $! > /var/run/svscan.pid'
        touch /var/lock/subsys/svscan
        ;;
  stop)
        if [ -f /var/run/svscan.pid ]; then
          echo -n "Stopping svscan: "
          kill `cat /var/run/svscan.pid`
          svc -dx /service/*
          svc -dx /service/*/log
          rm -f /var/run/svscan.pid
          rm -f /var/lock/subsys/svscan
        fi
        ;;
  *)
        echo "Usage: $0 {start|stop}"
        exit 1
esac

exit 0
```

なお、RedHat Linux 7.x用の起動スクリプトは [svscan](svscan) にあります。次のようにして登録してください。

```
# cd /etc/rc.d/init.d
# cp /tmp/svscan .
# chmod +x svscan
# chkconfig --add svscan
```

起動スクリプトの登録ができたら、起動スクリプトを個別に実行したり、再起動したりして、`svscan` を起動してください。

#### 関連リンク

- [マニュアル: `svscan` プログラム](http://www.emaillab.org/djb/tools/daemontools/svscan.html)

## <span id="chap3">3. サービスの制御</span>

### <span id="chap3sec1">3.1. `svscan` と `supervise` の動作</span>

`svscan`は監視対象のディレクトリ`/service`にサブディレクトリ*sub*があるとき、そのディレクトリ名を引数にして`supervise`を起動させます。`supervise`は引数で渡されたディレクトリ*sub*に移動し、`./run`スクリプトを起動させ、監視します。この`./run`にはサービスを実行するスクリプトを記述します。さらに、`sub`にsticky bitが立っていれば、`svscan`は*sub*に移動し、`log`を引数にして`supervise`を起動させ、*sub*`/run`の出力と*sub*`/log/run`の入力をパイプでつなぎます。このときの`supervise`は引数で渡されたディレクトリ`log`に移動し、`./run`スクリプトを起動させ、監視します。この`./run`にはログを記録するプログラム（`multilog`）を実行するスクリプトを記述します。このように `supervise`は`svscan`により起動させられるので、スクリプト中に`supervise`を明示して記述する必要はありません。
それぞれのプログラムとその引数および作業するディレクトリを整理すると次の表のようになります。

|プログラム|作業ディレクトリ|
|---|---|
|`svscan /service`|`/service`|
|`supervise`*sub*|`/service/`*sub*|
|`supervise log`|`/service/`*sub*`/log`|

上記で述べたことに加えて、`svscan` には次のような特徴があります。

- 起動したディレクトリを監視する。引数（ディレクトリ名）が与えられたら、起動後にそのディレクトリに移動し、そのディレクトリを監視する。
- 5秒毎にサブディレクトリを調べる。
    - 新しいサブディレクトリがあれば、`supervise`プロセスを開始させる。
    - `supervise` プロセスが終了しているサブディレクトリを見つけたら、その`supervise`プロセスを再開させる。
    - ドットで始まるサブディレクトリは無視する。

上記で述べたことに加えて、`supervise` には次のような特徴があります。

- `./run` が終了したら、`./run`を再起動させる。ループを防ぐため、再起動まで1秒間待つ。
- `supervise`の起動時に `./down`が存在すれば、`./run` を起動させない。
- `supervise`自身は終了の指示がない限り終了しない。

#### 関連リンク

- [マニュアル: `svscan` プログラム](/djb/tools/daemontools/svscan.html)
- [マニュアル: `supervise` プログラム](/djb/tools/daemontools/supervise.html)

### <span id="chap3sec2">3.2. 各サービスの起動</span>

#### a) ログを取らない場合

起動させたいサービスのためのディレクトリ`/path/to/`*foo*を適当な場所に作成します。

```
# mkdir /path/to/foo
```

次に、`./run` を作成し、サービスを実行するスクリプトを記述します。

`/service/`*sub* から `/path/to/`*foo* へのシンボリックリンクを作ります。

```
# ln -s /path/to/foo /service/sub
```

5秒以内に `supervise` が起動するでしょう。`svok` を使って起動が成功しているか確認できます。また、`svstat` でもその起動の状態を確認できます。

```
# svok /service/sub; echo "$?"
0
# svstat /service/sub
/service/sub: up (pid 1234) 20 seconds
```

#### b) ログを取る場合

起動させたいサービスのためのディレクトリ`/path/to/`*foo*を適当な場所に作成します。ログ用のディレクトリ `/path/to/`*foo*`/log` も作成します。さらに *foo* に対してsticky bitを立てます。ログを出力するUIDとGIDを変える場合は、`log`の所有者も変えます。

```
# mkdir /path/to/foo
# mkdir /path/to/foo/log
# chmod +t /path/to/foo
# chown uid.gid /path/to/foo/log
```

次に、`./run` を作成し、サービスを実行するスクリプトを記述します。また、`log/run` を作成し、ログを保存するスクリプトを記述します。

`/service/`*sub* から `/path/to/`*foo* へのシンボリックリンクを作ります。

```
# ln -s /path/to/foo /service/sub
```

5秒以内に `supervise` が起動するでしょう。`svok` を使って起動が成功しているか確認できます。また、`svstat` でもその起動の状態を確認できます。

```
# svok /service/sub; echo "$?"
0
# svok /service/sub/log; echo "$?"
0
# svstat /service/sub /service/sub/log
/service/sub: up (pid 1234) 20 seconds
/service/sub/log: up (pid 1235) 20 seconds
```

#### 具体例(qmailの場合)

まず、qmailの起動プログラム `qmail-start` 用のディレクトリを作成します。場所はどこでもかまいませんが、ここでは `/var/qmail/supurvise/qmail-send` とします。ログを保存するために、このディレクトリにsticky bitを立て、そのディレクトリの下に`qmail-send`のログ保存用ユーザ`qmaill`所有のディレクトリ`log`を作成します。

```
# mkdir /var/qmail/supervise/qmail-send
# chmod +t /var/qmail/supervise/qmail-send
# mkdir /var/qmail/supervise/qmail-send/log
# chown qmaill.nofiles /var/qmail/supervise/qmail-send/log
```

起動スクリプト `./run` と `log/run` を作成します。このスクリプトの例は次節に述べます。

`/service/qmail` からのシンボリックリンクを作ります。

```
# ln -s /var/qmail/supervise/qmail-send /service/qmail
```

5秒以内に`supervise`が起動するはずなので、`svok`あるいは`svstat`で起動を確認してください。また、qmailのマニュアルに記述してある配送試験を行ってください。

次に、qmailのSMTPデーモン`qmail-smtpd`用のディレクトリを作成します。ここでは`/var/qmail/supervise/qmail-smtpd`とします。ログを保存するために、このディレクトリにsticky bitを立て、そのディレクトリの下に`qmail-send`のログ保存用ユーザ`smtplog`所有のディレクトリ`log`を作成します。

```
# mkdir /var/qmail/supervise/qmail-smtpd
# chmod +t /var/qmail/supervise/qmail-smtpd
# mkdir /var/qmail/supervise/qmail-smtpd/log
# chown smtplog.nofiles /var/qmail/supervise/qmail-smtpd/log
```

起動スクリプト `./run` と `log/run` を作成します。このスクリプトの例は次節に述べます。

`/service/smtpd` からのシンボリックリンクを作ります。

```
# ln -s /var/qmail/supervise/qmail-smtpd /service/smtpd
```

5秒以内に `supervise` が起動するはずなので、`svok` あるいは `svstat` で起動を確認してください。

関連リンク

- [マニュアル: `svscan` プログラム](/djb/tools/daemontools/svscan.html)
- [マニュアル: `supervise` プログラム](/djb/tools/daemontools/supervise.html)
- [マニュアル: `svok` プログラム](/djb/tools/daemontools/svok.html)
- [マニュアル: `svstat` プログラム](/djb/tools/daemontools/svstat.html)

### <span id="chap3sec3">3.3. 起動スクリプト `./run` の例</span>

ここでは、サービスの起動スクリプト`./run`の作成例を示します。ログの収集スクリプト`log/run`に関してはここでは典型的な例しか示しません。応用例は次章に記述します。

#### `./run` を作成するに当たっての注意事項

- シグナルをサービスに直接送るために、`exec`を使って`sh`（`./run`のプロセス）を置き換える必要がある。
- `&` を付けてバックグランドで走らせてはいけない。
- 自身をforkしてバックグランドに移してしまうプログラムは`fghack`を使うことができる。ただし、制御は行えない。
- サービスによっては`supervise`からのシグナルでは制御できないものもある。

#### `qmail-send`

qmailのメール配送のプログラムを起動させ、配送のログを取る場合の例を示します。ログは`qmail-send`のログ保存専用のユーザ`qmaill`により保存されます。すべてのログはタイムスタンプを付けて`./log/main/`に保存されます。さらに現在の接続数は`./log/status`に保存されます。

##### `./run`

```sh
#!/bin/sh
exec env - PATH="/var/qmail/bin:$PATH" \
qmail-start ./Maildir/
```

##### `./log/run`

```sh
#!/bin/sh
exec \
setuidgid qmaill \
multilog t ./main '-*' '+* status: *' =status
```

#### `qmail-smtpd`

qmailのSMTPデーモン`qmail-smtpd`を`tcpserver`で起動させて接続制御を行い、接続状況のログを取る場合の例を示します。この場合はログ保存専用のユーザ`smtplog`によりログを保存します。また、接続制御ファイル`tcp.cdb`は同じディレクトリにあるものとします。

##### `./run`

```sh
#!/bin/sh
exec env - PATH="/var/qmail/bin:$PATH" \
tcpserver -vR -c40 -x./tcp.cdb -u7791 -g2108 0 smtp qmail-smtpd 2>&1
```

##### `./log/run`

```sh
#!/bin/sh
exec \
setuidgid smtplog \
multilog t ./main '-*' '+* * status: *' =status
```

#### 関連リンク

- [マニュアル: `supervise` プログラム](/djb/tools/daemontools/supervise.html)
- [マニュアル: `fghack` プログラム](/djb/tools/daemontools/fghack.html)

### <span id="chap3sec4">3.4. サービスの制御</span>

`svc` を使って次のことができます。

- サービスの起動・停止
- サービスへのシグナルの送信
- `supervise` の終了

`svc` の使い方は次の通りです。

```
svc opts services
```

*opts*はgetopt形式のオプションです。複数のオプションを指定でき、前から順番に実行されます。*services*は制御対象のディレクトリ名です。複数のディレクトリを同時に指定できます。ここで、`svc`のオプションの一覧を示します。

|オプション|意味|動作|
|---|---|---|
|`-u`|Up|サービスが起動していなければ、開始します。サービスが停止していれば、再開します。|
|`-d`|Down|サービスが起動していれば、TERM シグナルを送り、それから CONT シグナルを送ります。停止した後は再開しません。|
|`-o`|Once|サービスが起動していなければ、開始します。サービスが停止していれば、再開しません。|
|`-p`|Pause|サービスに STOP シグナルを送ります。|
|`-c`|Continue|サービスに CONT シグナルを送ります。|
|`-h`|Hangup|サービスに HUP シグナルを送ります。|
|`-a`|Alarm|サービスに ALRM シグナルを送ります。|
|`-i`|Interrupt|サービスに INT シグナルを送ります。|
|`-t`|Terminate|サービスに TERM シグナルを送ります。|
|`-k`|Kill|サービスに KILL シグナルを送ります。|
|`-x`|Exit|サービスがダウンしたらすぐに `supervise` は終了します。|

シグナルの意味は次のとおりです（値は環境により異なることがあります）。詳細はsignal(7)を読んでください。

|シグナル|値|意味|
|---|---|---|
|SIGSTOP|17|プロセスの停止|
|SIGCONT|19|停止状態からの再開|
|SIGHUP|1|制御している端末のハングアップの検出。制御しているプロセスの死。|
|SIGALRM|14|alarm(2)からのタイマーシグナル|
|SIGINT|2|キーボードからの割り込み|
|SIGTERM|15|終了シグナル|
|SIGKILL|9|Killシグナル|

ここで、いくつかの使用例を示します。

#### `qmail-send`の設定の変更を有効にするためのサービスの再起動

```
# svc -t /service/qmail
```

#### `./run`の書き換え時の処理

```
# mv ./run.new ./run; svc -t /service/smtpd
```

#### サービスの一時的な停止および再開

```
# svc -d /service/ftpd
# svc -u /service/ftpd
```

#### サービスの停止後、`supervise`の終了（ただし、5秒以内に `supervise`は再起動する）

```
# svc -dx /service/ftpd /service/ftpd/log
```

#### サービスの停止後、`supervise`の終了（`supervise`を再開させない）

```
# mv /service/ftpd /service/.ftpd; svc -dx /service/.ftpd /service/.ftpd/log
```

#### `svscan`を終了させるとき（全てのサービスの停止後、`supervise`を終了し、`svscan`のプロセスを終了する）

```
# svc -dx /service/*
# svc -dx /service/*/log
# kill pid_of_svscan
```

#### 関連リンク

- [マニュアル: `svc` プログラム](/djb/tools/daemontools/svc.html)

## <span id="chap4">4. ログの収集</span>

### <span id="chap4sec1">4.1. `multilog`</span>

前章で述べたログの収集スクリプト`log/run`には収集プログラムとして`multilog`を使います。ここでは、その`multilog`の使い方について説明します。

`multilog` の使い方は次のとおりです。

```
multilog script
```

*script*は動作(action)の集まりで、次の表に記述した動作の行の選択から出力までの組合わせを繰り返して指定できます。（恐らくシェルの限界まで）

|動作の概要|動作|備考|
|---|---|---|
|タイムスタンプ|`t`|各行の先頭にTAI64N形式のタイムスタンプを付ける。(最初の動作として記述した場合のみ有効)|
|行の選択|`-`*pattern*|*pattern*が行に合えばその行の選択が解除される。|
|〃|`+`*pattern*|*pattern* が行に合えばその行は選択される。|
|自動切り替えの動作|`s`*size*|最大ファイルサイズの設定。デフォルト99999。|
|〃|`n`*num*|ログファイルの最大数。デフォルト10。|
|〃|`!`*processor*|プロセッサの設定|
|ログ|*dir*|ログ *dir* へ選択された行を追加する。ドットやスラッシュで始まる必要がある。|
|警告|`e`|標準エラーに選択された各行（の最初の200バイト）を出力する。|
|Statusファイル|`=`*file*|*file* の中身を選択された各行（の最初の1000バイト）で置き換える。|

最初は各行が選択されています。行の選択指定はいくつでも記述でき、前から順番にそのパターンの選択・解除が追加されていきます。

*pattern*の仕様は次のとおりです。

- `*`とそれ以外の文字からなる文字列。
- `*`は直後に現れる文字を含まない任意の文字列に一致。
- 最後にある`*`は任意の文字列に一致。
- シェルのメタ文字を含めることができるが、引用符で囲む必要がある。

想定外の動作を防ぐために、*pattern*全体を引用符で囲んだほうが無難でしょう。

ここで、いくつか行の選択指定の例を示します。`multilog`の詳しい使用例に関しては次節をご覧ください。

#### 動作

`+hello`は`hello`を選択します。`hello world`は選択しません。

#### 動作

`-'* * > *'`は`@400000003879ded713291cfc 4357 > -ERR authorization failed`の選択を解除します。1つ目と2つ目の`*`はその直後のスペースを含まない任意の文字列に一致します。

#### 動作

`'-*'`はすべての行の選択を解除します。特定のパターンのみを選択する場合は通常、最初にこの動作を記述してすべての選択を解除してから、選択するパターンを追加していきます。

#### 一続きの動作

`-'*' +'* status: *' =status`は`@400000003914053c22ab2904 status: local 0/10 remote 0/20`を選択し、`status`というファイルの内容を置き換えます。つまり、`status`というファイルには常に最新の`status:`行が格納されることになります。

#### 関連リンク

- [マニュアル: `multilog` プログラム](/djb/tools/daemontools/multilog.html)

### <span id="chap4sec2">4.2. `.log/run` の作成例</span>

#### `qmail-send`

qmailのメール配送プログラム`qmail-send`のログを取る場合の例を示します。ログは`qmail-send`のログ保存専用のユーザ`qmaill`により保存されます。このスクリプトは次の3つの部分に分けることができます。

- タイムスタンプを付けてすべてのログを`./log/main/`に保存する。
- 通常よく出てくるパターンに一致しないものは`./log/alert/`に保存する。
- 現在の同時配送数を`./log/status`に保存する。

ちなみに、この例はDJB氏がメイリングリストに投稿した例を修正したものです。

```sh
#!/bin/sh
exec \
setuidgid qmaill \
multilog t ./main \
-'* status: *' \
-'* starting delivery *' \
-'* delivery * success*' \
-'* delivery * failure*' \
-'* new msg *' \
-'* info msg *' \
-'* end msg *' \
-'* bounce msg *' \
-"* delivery * deferral: Sorry,_I_couldn't_find_any_host_by_that_name*" \
-"* delivery * deferral: Sorry,_I_wasn't_able_to_establish_an_SMTP_*" \
./alert \
-'*' \
+'* status: *' \
=status
```

#### qmail-smtpd

qmailのSMTPデーモン`qmail-smtpd`を途中に`recordio`を挟んで`tcpserver`で起動させて接続制御を行い、接続状況のログとコマンドの応答を取る場合の例を示します。この場合はログ保存専用のユーザ`smtplog`によりログを保存します。このスクリプトは次の3つの動作に分けることができます。

- `recordio`によって記録されたもの以外のログをすべて`./log/main/`に保存する。
- `recordio`によって記録されたもの中でサーバへ送られる主要なコマンドとその応答を`./log/tcp/`に保存する。
- 現在の接続数を`./log/status`に保存する。

ちなみに`recordio`とは、プログラムの入出力を記録するプログラムで、ucspi-tcpパッケージに含まれています。これを用いれば、ログの出力を持たないサービスであっても、セッションのコマンドの応答から、不正中継の試みなどの様々な情報を記録できます。ただし、選択する行によってはプライバシの問題にもなるので扱いには注意が必要です。

```sh
#!/bin/sh
exec \
setuidgid smtplog \
multilog t \
-'* * > *' \
-'* * < *' \
s200000 \
./main \
-'*' \
+'* * < HELO *' \
+'* * < EHLO *' \
+'* * < MAIL *' \
+'* * < RCPT *' \
+'* * < DATA*' \
+'* * < QUIT*' \
+'* * < RSET*' \
+'* * < NOOP*' \
+'* * > 1*' \
+'* * > 2*' \
+'* * > 3*' \
+'* * > 4*' \
+'* * > 5*' \
s200000 \
./tcp \
-'*' \
+'* * status: *' \
=status
```

#### 関連リンク

- [マニュアル: `multilog` プログラム](/djb/tools/daemontools/multilog.html)
- [マニュアル: `setuidgid` プログラム](/djb/tools/daemontools/setuidgid.html)
- [ucspi-tcp マニュアル](/djb/tools/ucspi-tcp/top.html)

------------------------------------------------------------------------

Thanks to M.Sugimoto.
