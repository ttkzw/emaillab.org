---
title: tcpanalog - tcpserver のログの整理ツール
sidebar:
  label: tcpanalog
  order: 7
---

2002年6月11日更新

注意：tcpanalogは現在は保守されていません。

tcpserverのログを整理するツールを作りましたので公開します。

- https://github.com/ttkzw/tcpanalog-splogger
- https://github.com/ttkzw/tcpanalog-multilog

これを作った動機はtcpserver + sploggerのログを眺めているうちに、qmailのログの分析ツールqmailanalogのtcpserver版が欲しいと思ったからです。そういうわけでqmailanalogを真似て、tcpanalogという名前をつけました。中身も参考にしただけあってよく似ています。このバージョンでは接続したホスト名あるいはドメイン名とその回数・時間、接続拒否したホスト名とその回数しか情報は出ませんが、他にこういう情報が入ったほうが良いというのがあれば、メールを下さい。考慮します。ucspi-tcp-0.83以降用です。なお、multilogを使っているときには、tcpmatchupにログを渡す前に[tai64ntai](/djb/tools/daemontools/tai64ntai.html)を通してタイムスタンプをTAI形式に変更してください。

## <span id="ta1">tcpanalogのインストール</span>

1. git cloneする。
2. ディレクトリに移動する。

    ```
    $ cd tcpanalog-multilog
    ```

3. インストールするディレクトリと使用するawkをMakefileで設定する。標準では/usr/local/bin/tcpanalogにインストールされる。
4. 次のようにしてインストールする。

    ```
    $ make
    $ su
    # make install
    ```

これでインストールの終了です。

## <span id="ta2">tcpanalog(splogger版) の使い方</span>

1. tcpserverのログからsyslogで付加される日時とホスト名を除去する。通常は1列目から4列目まで。
2. これをtcpmatchupに入力すると、整形して出力される。
3. ztcphosts、ztcpdomains、ztcpdenyにこれを入力すると、接続情報と拒否情報が出力される。

サンプル・スクリプトを示します。

```sh
#!/bin/sh
#  tcpanalog
PATH=/usr/local/bin/tcpanalog
AUTHLOG="/var/log/authlog"
TMPLOG="$HOME/tmp/log.$$"

/usr/bin/awk '{$1="";$2="";$3="";$4="";print}' < $AUTHLOG | \
  tcpmatchup > $TMPLOG
ztcpdomains < $TMPLOG
ztcphosts < $TMPLOG
ztcpdeny < $TMPLOG
/bin/rm -f $TMPLOG
```

------------------------------------------------------------------------

## <span id="ta2">tcpanalog(multilog版) の使い方</span>

1. multilogのタイムスタンプはTAI64N形式であるので、これをTAI形式に変換する。変換するプログラムに関しては[tai64ntai](/djb/tools/daemontools/tai64ntai.html) を参照してください。
2. タイムスタンプをTAI形式に変換したログをtcpmatchupに入力すると、整形して出力される。
3. ztcphosts、ztcpdomains、ztcpdenyにこれを入力すると、接続情報、拒否情報が出力される。

サンプル・スクリプトを示します。入力するログのファイル名をオプションとして実行するものです。logcollectorはsyslogxの吐き出すログから必要な時間だけを取り出すスクリプトだと思ってください。

```sh
#!/bin/sh
#  tcpanalog
PATH=/usr/local/bin/tcpanalog:/usr/local/bin
TMPLOG="$HOME/tmp/log.$$"

logcollector $1 $2 | tcpmatchup > $TMPLOG
ztcpdomains < $TMPLOG
ztcphosts < $TMPLOG
ztcpdeny < $TMPLOG
/bin/rm -f $TMPLOG
```
