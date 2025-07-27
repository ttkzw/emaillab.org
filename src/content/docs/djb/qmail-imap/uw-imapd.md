---
title: UW IMAP server
sidebar:
  order: 2
---

Last modified: Sun Jan 7 15:20:15 2001

## 1. UW IMAP server とは

UW IMAP server は University of Washington の Mark Crispin 氏によって開発が行われており、Mark Crispin 氏が IMAP4 関連の RFC の著者でもあることから、IMAP4 のリファレンス実装的な位置付けにもあります。

しかし、時々、セキュリティホールが見つかるため、常に最新版の動向を調べる必要があります。要は最新版以外のものは使うべきではないということです。

また、ユーザ数が増えるとパフォーマンスが悪くなるという話も聞きますので、他の IMAP サーバを使うことも検討してみてください。

------------------------------------------------------------------------

## 2. インストール

### 方針

ここでは次の条件のもとでインストールを行うことにします。

- MTA に qmail を用いる。つまり、スプールファイルは ~/Mailbox になるということ。なお、qmail の Maildir 形式のスプールは UW IMAP server では使えません。
- 通常ではホームディレクトリの中身が全て見えてしまうため、これを見せないようにする。

MTA に qmail を用いるのであれば Maildir 形式のスプールを使いたいところですが、UW IMAP server ではサポートしていません。ただし、サードパーティのアドオンドライバがあります(docs/FAQ)。しかし、UW IMAP server は mbx 形式のスプールを扱うように最適化されているため、Maildir 形式のパフォーマンスはよくないという話もあります。

### インストール方法

[IMAP Information Center](http://www.washington.edu/imap/) からパッケージを取得してください。2001年1月7日時点での最新版は 2000a です。

パッケージを展開します。

```sh
$ uncompress imap-2000a.tar.Z
$ tar xvf imap-2000a.tar
$ cd imap-2000a
```

ここで、方針に従って、次のことを行います。詳細は docs/CONFIG を読んだ下さい。

- ~/Mailbox から読み出す。
- ~/mail/ を IMAP 用のホームディレクトリとすることによって Mailbox をはじめホームディレクトリ直下のファイルを見せなくする。

まず、~/Mailbox を使うために、src/osdep/unix/env_unix.c に対して、の関数 sysinbox () において

```c
sprintf (tmp,"%s/%s",MAILSPOOL,myusername ());
```

を

```c
sprintf (tmp,"%s/Mailbox",myhomedir ());
```

に書き換えます。

次にトップの Makefile を編集し、EXTRACFLAGS= の行に -DMAILSUBDIR="mail" を追加します。

以上の書き換えが終ったら、コンパイルしてインストールします(Linux で PAM を使う場合の例です)。平文認証を認めないようにするのであれば PASSWDTYPE=nul も付けるといいでしょう。POP3 も使うのであれば ipop3d もインストールしてください。

```sh
$ make lnp PASSWDTYPE=pam
# cp imapd/imapd /usr/local/sbin/
# cp ipopd/ipop3d /usr/local/sbin/
```

/etc/service に次の行があることを確認します。

```
imap    143/tcp
```

inetd から imapd を起動するのであれば、/etc/inetd.conf に次の行を設定し、起
動している inetd に対して SIGHUP を送ってください。この例では tcpd 経由で起動さ
せているので、tcpd の設定(hosts.allow, hosts.deny)も合わせて行ってください。

```
pop3 stream tcp nowait root /usr/sbin/tcpd /usr/local/sbin/imapd
```

tcpserver と daemontools を組み合わせて、imapd を起動するのであれば、次のよ
うな ./run を作ってください。詳しくは [daemontools HOW-TO](../daemontools/daemontools-howto.html) をご覧下さい。

```sh
#!/bin/sh
#  imapd
exec env - PATH="/usr/local/sbin:$PATH" \
tcpserver -vR -c40 -xtcp.cdb -u0 -g0 0 imap imapd 2>&1
```
