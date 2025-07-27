---
title: qmail のパッチについて
sidebar:
  order: 1
---

1998年5月6日初出

Last modified: Sun May 7 15:32:20 2000

## アンケートの概要

まず、qmailのことをよく知らない人のために始めに断っておきますが、qmailには基本的にパッチを当てる必要は全くありません。それ自体で十分に多機能で安全です。しかし、www.qmail.org などを見ていると、たくさんのパッチが公開されています。では、「なぜパッチを当てているのか？」「もしかしたらパッチを当てなければいけないのでは？」という疑問が上がります。そこで次のようなアンケートを行いました。

1. パッチを当てているか当てていないか？
2. どういう理由で？

その結果において、パッチを当てる理由をおおざっぱにまとめると次のようになりました。

1. ローカルタイム表示
2. POP3関連(APOP対応も含めて)
3. RFCを守らないMTA/MUA対策
4. SPAM対策などの接続制御

このアンケートを行った当時の qmail のバージョンは 1.01 であり、また、関連パッケージの状況も異なるので、この理由と対策方法は現状では異なる部分があります。そのため、対策方法を次の節に示すことにします。なお、このアンケートの詳細は[「アンケート」](patch-questionnaire.html)に示します。

## 対策

### 1. ローカルタイム表示

#### Recieved

Recieved: フィールドでの時刻を GMT ではなくローカルタイムで表示したい場合は、パッチを当てるしかありません。どちらがよいかは多分に趣味的な問題です。（日本国内だけでメールがやり取りされているわけではないということです。）
<ftp://ftp.nlc.net.au/pub/unix/mail/qmail/qmail-date-localtime.patch>

#### Date

Date: フィールドを付けない MUA からのメッセージに対して FAQ 5.5 の方法で付けさせたい場合において、Date: フィールドをローカルタイム表示にしたい場合は qmail のパッケージに含まれる predate 経由で qmail-inject を起動すればよいです。

### 2. POP3関連(APOP対応も含めて)

#### Status

未読の判断を Status: フィールドで行う場合はパッチを当てる必要があります。しかし、最近は UIDL が普及しているので必要無いと思います。
<http://homepages.munich.netsurf.de/Franz.Sirl/qmail-pop3d-1.03.diff>

#### APOP

APOP 対応にするのであれば、Christopher Johnson 氏の vchkpw という virtual domains package を使うのが簡単です。checkpassword の代わりに働き、様々な便利な機能を提供します。なお、現在、vchkpw の開発は Ken Jones 氏に引き継がれて vpopmail というパッケージになり、さらに便利になっています。
<http://www.inter7.com/vchkpw/>

### 3. RFCを守らないMTA/MUA対策

#### bare LFs

bare LFs に関してはまず DJB の文書 ["Bare LFs in SMTP"](https://cr.yp.to/docs/smtplf.html) を読んでください。原則として、MTA/MUA の作者に直してもらう必要があります。対応してくれない場合は、そのソフトを使うのを止めさせるか、接続できないままにしておくか、qmail 側で対策を行う必要があります。qmail 側で対策を行う場合は、[ucspi-tcp](../tools/ucspi-tcp/top.html) パッケージに含まれる fixcrio を使い、
`fixcrio qmail-smtpd`
のようにして qmail-smtpd を起動させればよいです。

#### multiple line replies

qmail 1.02 までは HELO の後に次のような３行の応答を返していました。
`250-mta.x.yyy.ac.jp`
`250-PIPELINING`
`250 8BITMIME`
MUA によってはこの複数行の応答を理解できずエラーが生じ、接続できないものがありました。しかし、qmail 1.03 では１行の応答を返すので、特に対策は必要ありません。

### 4. SPAM対策などの接続制御

#### MAPS RBL

MAPS RBLを利用するためには [ucspi-tcp](../tools/ucspi-tcp/top.html) パッケージに含まれている rblsmtpd を使えばできます。

#### RELAY CLIENT

特定のホストのみ中継を許可する方法は FAQ 5.4 の方法でできます。
