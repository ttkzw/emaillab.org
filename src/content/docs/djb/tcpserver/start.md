---
title: 起動例
sidebar:
  order: 6
---

1999年9月25日更新

## ログを出力しない場合

identdのように接続制御を必要とせず、ログをとる必要のない場合の起動スクリプトを示します。この例では同時接続数は40までであり、identdがむやみにたくさん起動するのを防ぐことができます。また、IDENTのピンポンを防ぐためにIDENTを行わないように`-R`オプションを付けます。

```sh
#!/bin/sh
#  identd
/usr/local/bin/tcpserver -HR -c 40 -u 0 -g 0 0 auth \
/usr/sbin/in.identd -w -t120 -l &
```

## ログを出力する場合（sploggerを使用）

qmailのSMTPデーモンqmail-smtpdの接続制御を行い、qmailのパッケージに含まれている[splogger](/djb/qmailanalog/splogger.html)にログを出力する場合の起動スクリプトを示します。

```sh
#!/bin/sh
#  qmail-smtpd
exec env - PATH=/var/qmail/bin:/usr/local/bin \
tcpserver -v -c 40 -x /etc/tcp.smtp.cdb -u 7791 -g 2108 0 smtp \
qmail-smtpd 2>&1 | splogger smtpd 4 &
```

なお、あらかじめsyslog.confを編集してauthレベルのログの出力を/var/log/authや/var/log/authlogなどにするようにしておきます。

## ログを出力する場合（multilog を使用）

qmailのSMTPデーモンqmail-smtpdの接続制御を行い、daemontoolsに含まれているmultilogにログを出力する場合の起動スクリプトを示します。詳しくは [daemontools](/djb/daemontools/) のページを見てください。

```sh
#!/bin/sh
#  qmail-smtpd
exec env -PATH="/var/qmail/bin:$PATH" \
tcpserver -v -c 40 -x /etc/tcp.smtp.cdb -u 7791 -g 2108 0 smtp qmail-smtpd 2>&1
```
