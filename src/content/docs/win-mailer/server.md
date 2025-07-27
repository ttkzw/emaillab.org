---
title: 試験環境
---
Last modified: Sun Jun 11 17:04:15 2000

------------------------------------------------------------------------

### OS

サーバマシンの OS は Linux (Kondara MNU/Linux 1.1) です。

### SMTPサーバ

SMTPサーバには [qmail](http://cr.yp.to/qmail.html) を用いました。バージョンは 1.03 です。SMTP-AUTH のために、[qmail-smtpd-auth パッチ](http://members.elysium.pl/brush/qmail-smtpd-auth/)を当て、CRAM-MD5 用の認証プログラムには [cmd5checkpw](http://members.elysium.pl/brush/cmd5checkpw/) を、平文用の認証プログラムには [checkpassword](http://cr.yp.to/checkpwd.html) を用いました。

### POP3サーバ

POP3サーバには [qmail](http://cr.yp.to/qmail.html) パッケージ付属のものを用いました。APOP 認証パッケージとして [qmapop](http://www.ne.jp/asahi/cyber/taki/djb/qmapop/) を用いました。バージョンは 0.51 です。

### IMAPサーバ

IMAPサーバには [UW IMAP server](http://www.washington.edu/imap/) を用いました。バージョンは 4.7c2 です。qmail に対応するためにいくつかの修正を行っています。

### LDAPサーバ

LDAPサーバには [OpenLDAP](http://www.openldap.org/) を用いています。バージョンは 1.2.10 です。

------------------------------------------------------------------------

滝澤 隆史(TAKIZAWA Takashi)
<taki@cyber.email.ne.jp>
