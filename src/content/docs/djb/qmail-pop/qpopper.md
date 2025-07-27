---
title: Qpopper
sidebar:
  order: 1
---

Last modified: Sun May 14 10:19:21 2000

## 1. Qpopper とは

Qpopper とは Berkeley "popper" を Qualcomm 社が拡張した POP3 サーバです。最新版 3.0 ではかなり機能の拡張がなされており RFC 1939 と RFC 2449 を完全実装しています。恐らく、POP3 サーバとしては最も高機能のものの一つであります（現状のクライアントがそこまで要求しているかはともかくとして）。

しかし、Qpopper にはときどきセキュリティホールが見つかります。特に、2.41 以前および3.0 beta 21 以前には重大なセキュリティホールが見つかっています。そのため、Qpopper を使うのであれば常に最新版の動向をつかむ必要があります。要は最新版以外のものは使うべきではないということです。

なお、3.0 から加わった新しい機能の主だったものを並べてみます。詳細は doc/Release.Notes を読んでください。

- RFC 2449 のサポート(CAPA, X-MANGLE, LOGIN-DELAY and EXPIRE)
- SASL をサポート(SCRAM-MD5 のみ)
- クライアントのIPアドレスの逆引きを無効化
- RETR したメッセージの自動削除
- home directory でのスプールファイルの指定（以前はソースコードを直接編集する必要があった。つまり、qmail の ~/Mailbox への対応が楽になった）
- POP before SMTP 用の認証ログの出力（MTA が対応していなければ意味がないが）
- PAM のサポート
- UW IMAP の status message (最初に入っている邪魔な奴:-))を隠蔽

------------------------------------------------------------------------

## 2. インストール

### 方針

ここでは、次の条件のもとでインストールを行うことにします。

- 認証には APOP のみを用いる。
- MTA に qmail を用いる。つまり、スプールファイルは ~/Mailbox になるということ。なお、qmail の Maildir 形式のスプールは Qpopper では使えません。

### インストール方法

Qualcomm 社の[Qpopper Home Page](http://www.eudora.com/freeware/qpop.html) からパッケージを取得してください。2000年5月7日時点での最新版は 3.0.1 です。

パッケージを展開します。

```sh
$ uncompress qpopper3.0.1.tar.Z
$ tar xvf qpopper3.0.1.tar
$ cd qpopper3.0.1
```

README, INSTALL を読みます。

APOP 用のアカウント pop を追加します。

コンパイルしてインストールします。

```sh
$ ./configure --enable-apop=/etc/pop.auth --with-popuid=pop --enable-home-dir-mail=Mailbox
$ make
# cp popper/popper /usr/local/lib
# cp popper/popauth /usr/local/bin
# cp man/\*.8 /usr/local/man/man8
# chown pop /usr/local/bin/popauth
# chmod u+s /usr/local/bin/popauth
```

APOP データベースの初期化を行います。

```sh
# popauth -init
```

/etc/service に次の行があることを確認します。

```
pop3    110/tcp
```

inetd から popper を起動するのであれば、/etc/inetd.conf に次の行を設定し、起動している inetd に対して SIGHUP を送ってください。この例では tcpd 経由で起動させているので、tcpd の設定(hosts.allow, hosts.deny)も合わせて行ってください。

```
pop3 stream tcp nowait root /usr/sbin/tcpd /usr/local/lib/popper -s
```

tcpserver と daemontools を組み合わせて、popper を起動するのであれば、次のような ./run を作ってください。詳しくは [daemontools-HOW-TO](../daemontools/daemontools-howto.html) をご覧下さい。

```sh
#!/bin/sh
#  qpopper
exec env - PATH="/usr/local/lib:$PATH" \
tcpserver -vR -c 40 -xtcp.cdb -u 0 -g 0 0 pop3 popper -s 2>&1
```
