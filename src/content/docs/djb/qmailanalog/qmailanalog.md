---
title: ログの統計情報ツール qmailanalog
sidebar:
  order: 1
---

Last modified: Sun May 7 15:51:33 2000

qmailanalog は qmail が出力するログから統計情報を求めるためのツールです。

- [qmailanalog のインストール](#install)
- [qmailanalog の使い方(splogger を使う場合)](#how2use)
- [qmailanalog の使い方(multilog を使う場合)](#how2use-multilog)

------------------------------------------------------------------------

### <span id="install">qmailanalog のインストール</span>

インストールは次のとおりです。

1. 次のサイトからqmailanalog-0.70.tar.gzを入手します。
    - https://cr.yp.to/qmailanalog.html
2. それぞれファイルを展開します。

    ```sh
    $ gzip -dc qmailanalog-0.70.tar.gz | tar xvf -
    ```

3. make してインストールします。標準では /usr/local/qmailanalog にインストールされます。

    ```sh
    $ cd qmailanalog-0.70
    $ make
    $ su
    # make setup check
    ```

4. ezmlm を使っていると envelope sender の情報が長く、メッセージ毎にシーケンス番号が異なるので、そのままでは個別にそれぞれ出力され分析結果が見にくくなってしまいます。そこで senders を修正してみます。（必要に応じて行ってください）

    ```
      /^m/ {
        sender = $10"/"$8
    ```

    の次に行に

    ```
        sub("-return-.*=.*@","@",sender)
    ```

    を挿入します。また、

    ```
      /^d/ {
        sender = $10"/"$7
    ```

    の次の行にも

    ```
        sub("-return-.*=.*@","@",sender)
    ```

    を挿入します。

### <span id="how2use">qmailanalog の使い方(splogger を使う場合)</span>

1. /etc/syslog.conf を見て、maillog が単独で出力されるか確認します。以下は syslog.conf の例です。なおこの例では、パケットフィルタリングのログを KERN レベルで吐き出し、tcpserver のログを AUTH レベルで吐き出すため、maillog と同様にそれぞれファイルを独立させています。man 3 syslog あるいは syslog.h を見るといいです。

    ```
    *.=info;*.=notice;kern,mail,auth.none   /var/log/messages
    *.=debug;kern,mail,auth.none            /var/log/debug
    *.warn;kern,mail,auth.none              /var/log/syslog
    *.crit                                  /var/log/critical
    kern.*                                  /var/log/kernel
    mail.*                                  /var/log/maillog
    auth.*                                  /var/log/authlog
    ```

2. maillog から日時、ホスト名、"qmail:"を取り除いて、matchup に通してログを整理します。以下はこれを処理するスクリプトの一部です。

    ```sh
    #!/bin/sh
    #
    PATH=/usr/local/qmailanalog/bin:/var/qmail/bin
    MAILLOG="/var/log/maillog"
    QMAILLOG="$HOME/tmp/qmail.$$"
    /usr/bin/awk '{$1="";$2="";$3="";$4="";$5="";print}' \
        < $MAILLOG | matchup > $QMAILLOG
    ```

3. 整理されたログを標準入力として qmailanalog の各スクリプトに通して統計結果を得ます。以下のスクリプトは先のスクリプトにつなげて使い、ログの統計情報をpostmaster にメールするものです。cron で毎日1回動かすといいでしょう。

    ```sh
    (echo "To: postmaster@foo.or.jp"
    echo "From: postmaster@foo.or.jp"
    echo "Subject: maillog"
    echo ""
    zoverall < $QMAILLOG
    zfailures < $QMAILLOG
    zdeferrals < $QMAILLOG
    zrecipients < $QMAILLOG
    zsenders < $QMAILLOG )| qmail-inject -f postmaster@foo.or.jp
    /bin/rm -f $QMAILLOG
    ```

### <span id="how2use-multilog">qmailanalog の使い方(multilog を使う場合)</span>

splogger は syslogd を経由してログを出力するため、syslogd の性能上、すべてのログを確実に残せる保証はありません。そこで、DJB 氏による [daemontools](../tools/daemontools/top.html) というパッケージに含まれる multilog を用いた例を示します。

1. daemontools をインストールして、multilog の設定をします。
    詳細は [daemontools HOW-TO](../daemontools/daemontools-howto/) をご覧下さい。

2. /service/qmail にあるログから統計を取りたい時間のみ取り出し、matchup に通
    してログを整理します。以下はこれを処理するスクリプトの一部です。logcollector
    は multilog が出力するログから必要な時間だけを取り出すスクリプトだと思ってください。

    ```sh
    #!/bin/sh
    #
    PATH="/usr/local/qmailanalog/bin:/var/qmail/bin:$PATH"
    export PATH
    QMAILLOG="/service/qmail/log/qmail.$$"
    /usr/local/bin/logcollector /service/qmail/log 1 | matchup > $QMAILLOG
    ```

3. 整理されたログを標準入力として qmailanalog の各スクリプトに通して統計結果を得ます。以下のスクリプトは先のスクリプトにつなげて使い、ログの統計情報をpostmaster にメールするものです。qmaill の UID として cron で毎日1回動かすといいでしょう。

    ```sh
    (echo "To: postmaster@foo.or.jp"
    echo "From: postmaster@foo.or.jp"
    echo "Subject: maillog"
    echo ""
    zoverall < $QMAILLOG
    zfailures < $QMAILLOG
    zdeferrals < $QMAILLOG
    zrecipients < $QMAILLOG
    zsenders < $QMAILLOG )| qmail-inject -f postmaster@foo.or.jp
    /bin/rm -f $QMAILLOG
    ```
