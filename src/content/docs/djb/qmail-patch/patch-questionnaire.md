---
title: アンケート
sidebar:
  order: 2
---

1998年5月6日初出、1999年4月10日更新

## qmailのパッチについてのアンケート

「qmailのパッチについて」のアンケートを日本のqmailのメイリングリスト
[qmail@jp.qmail.org](http://www.jp.qmail.org/ml/index.html)
で行いました。

アンケートの期間
1998年 3月12日〜27日

回答数
30 人

質問内容

1. パッチを当てているか当てていないか？
2. どういう理由で？

------------------------------------------------------------------------

## アンケートの結果

### 1. パッチを当てているか当てていないか？

#### パッチの有無

<table>
<tr><td>当てている<td>20 人</tr>
<tr><td>当てていない<td>10 人</tr>
</table>

- 当てている: 20 人
- 当てていない: 10 人

#### 当てているパッチと人数

<table>
<tr><th>作者名:パッチの目的<br>
        パッチの所在
    <th>人数
</tr>
<tr><td>John Saunders: ローカルタイム表示<br>
        ftp://ftp.nlc.net.au/pub/unix/mail/qmail/qmail-date-localtime.patch<br>
        [1.03]date822fmt.cには変更がない。
    <td align="right">17
</tr>
<tr><td>John Saunders: qmail-smtpdが\nで終了する行を受け付けるパッチ<br>
        ftp://ftp.nlc.net.au/pub/linux/mail/qmail/qmail-smtpd-newline.patch<br>
        [1.03]対応<br>
        [別手段]ucspi-tcp パッケージの fixcr を使う。
    <td align="right">7
</tr>
<tr><td>Bart Hartgers and Franz Sirl: STATUSなどのヘッダーを挿入するパッチ<br>
        http://homepages.munich.netsurf.de/Franz.Sirl/qmail-pop3d.diff<br>
        [1.03]http://homepages.munich.netsurf.de/Franz.Sirl/qmail-pop3d-1.03.diff
    <td align="right">4
</tr>
<tr><td>Russ Nelson: MAPS RBLプロジェクトのパッチ<br>
        http://www.jp.qmail.org/qmail/rbl/qmail-1.01-rbl.diffs<br>
        [1.03]http://www.jp.qmail.org/qmail/rbl/qmail-1.03-rbl.diffs<br>
        [別手段]rblsmtpd パッケージを使う。
    <td align="right">4
</tr>
<tr><td>電信八号等MUA対策<br>
        [1.03]HELO の後の multiline replies に対するパッチは必要なくなった。
    <td align="right">4
</tr>
<tr><td>Chuck Foster: "CNAME lookup failed"を受け付けるパッチ<br>
        http://www.jp.qmail.org/qmail/cname_lookup_failed<br>
        [1.03]CNAME lookup をやめたため必要無くなった。
    <td align="right">3
</tr>
<tr><td>Michael Samuel: RCPT TO の数を制限するパッチ<br>
        ftp://ftp.surfnetcity.com.au/pub/unix/qmail/qmail-1.01-maxrcpt.patch<br>
        [1.03]不明
    <td align="right">3
</tr>
<tr><td>Rask Ingemann Lambertsen: qmail-smtpdが\nで終了する行を受け付けるパッチ<br>
        http://www.gbar.dtu.dk/~c948374/qmail/qmail-bare-lf.diff<br>
        [1.03]不明<br>
        [別手段]ucspi-tcp パッケージの fixcr を使う。
    <td align="right">3
</tr>
<tr><td>Richard Letts: qmail-sendがSIGHUPしたときrecipientmapを再読み込みするパッチ<br>
        http://www.illuin.demon.co.uk/qmail/recipientmap-reload-0.6.patch<br>
        [1.03]control/recipientmap自体がなくなった。
    <td align="right">3
</tr>
<tr><td>Mark Delany: senderをチェックするspam対策のパッチ<br>
        ftp://ftp.mira.net/unix/mail/qmail/wildmat-0.2.patch<br>
        [1.03]不明
    <td align="right">3
</tr>
<tr><td>Bert Gijsbers: APOPのサポートをするためのパッチ<br>
        bert-send-apop@mc.bio.uva.nl へメールを送って返送されたqmapop-0.3.tar.gz<br>
        [1.03]qmail-1.02-popup.c.diffあり。See ML:qmail@jp.qmail.org #714
    <td align="right">2
</tr>
<tr><td>Sam Varshavchik: procmail-during-SMTP antispam patch<br>
        http://www.geocities.com/SiliconValley/Peaks/5799/qmail-uce.html
        [1.03]対応
    <td align="right">2
</tr>
<tr><td>Frank D. Cringle: /var/qmail/queue/lock/tcpto をリセットするパッチ<br>
        http://www.jp.qmail.org/qmail/qmail-del-tcpto<br>
        [1.03]qmail-tcpok が追加されたため必要無い。
    <td align="right">1
</tr>
<tr><td>Rask Ingemann Lambertsen: 中継を制御するqmail-smtpdへのパッチ<br>
        http://www.gbar.dtu.dk/~c948374/qmail/qmail-relayclient.diff
        [1.03]http://www.cs.uregina.ca/~wunschs/code/qmail-1.03-relayclient.diff
        [別手段]ucspi-tcp を使う。
    <td align="right">1
</tr>
<tr><td>IPv6対応
    <td align="right">1
</tr>
</table>

注）MUA対策とIPv6対応は手製のパッチです。
なお、アンケートの回答には Russ Nelson作の MAPS RBLプロジェクトのパッチ http://www.jp.qmail.org/qmail/rbl/ucspi-tcp-0.80-rbl.diffs が含まれていますが、qmail ではなく tcpserver に対するパッチなので除外します。解答数は 3 です。
上記のパッチは qmail 1.01 以前のパッチです。1.03 で対応状況は各欄の\[1.03\]という行に書いてあります。また、パッチを当てないで済む手段がある場合は\[別手段\]という行に書いてあります。
上記のパッチのほとんどはwww.qmail.orgミラーサイトからたどることができます。

### 2. どういう理由で？

コメントを簡潔にするため、送っていただいた理由の文章を一部変えたり、同じ内容はまとめたりしています。

#### パッチを当てない理由

- 特に当てる必要がない。
- オリジナルからの改変はしたくない。
- パッチの存在を知らなかった。
- 勉強不足でそこまで手が回っていない。
- 現在試験運用のため。
- 当てる理由はあるが別の方法で逃げている。
- MUA に問題があれば, MUA で対処して頂く 等の方針を採用している。

#### パッチを当てる理由

- qmail-date-localtime.patch
    - 時刻の表示を localtime(JST) にしたかったから。
    - JST の方が直感的にわかりやすい。
    - 配送状況を見やすくするため、他の MUA の表示と合わせたい。
    - DateをつけないMUAがあり、Dateの表示が -0000 となることを防ぐ為。
- qmail-smtpd-newline.patch
    - 不具合のでるメーラーがあると聞いたので。
    - RFCを守らないで実装されたMUA対策．
    - winなクライアントから利用するのに必要だったため。
    - 改行が \`LF' ではうまく動かないことがあった。
    - 行末処理(LF, LF+CR)
    - ISP で利用している以上、利用者の MUA でメールを送信できないのは論外である。
- qmail-pop3d.diff
    - 不具合のでるメーラーがあると聞いたので。
    - Authorized POP を導入する準備のため．まだ導入はしていません．
    - 単純に当てた方が良い気がした。
- qmail-1.01-rbl.diffs
    - SPAM/UCE対策．
    - 不正中継関係で活用できそう。
    - MAPS RBLプロジェクトの情報を利用するためです。
- 電信八号等MUA対策
    - winなクライアントから利用するのに必要だったため。
    - 電信八号がqmail-smtpdときちんとお話しできるようにする
    - ISP で利用している以上、利用者の MUA でメールを送信できないのは論外である。
    - 参照） [SMTPの実装に問題が報告されたクライアントの情報(前野さんのページ)](http://www.jp.qmail.org/client/broken-client.html)
    - [Windows のメイラーの選定](../../win-mailer/index.html)
- cname_lookup_failed
    - 大元のDNSが腐っているため．
    - ある無料メーリングリストサーバからのメールがこのチェックに引っかかって配信されない。
- qmail-1.01-maxrcpt.patch
    - 一度に RCPT できる宛先の数を制限できるようにすれば後々便利だと
  思ったため．実行はしてませんが．
- qmail-bare-lf.diff
    - RFCを守らないで実装されたMUA対策．
- recipientmap-reload-0.6.patch, wildmat-0.2.patch
    - SPAM/UCE対策．
    - 不正中継関係で活用できそう。
- qmapop-0.3
    - APOPのため
- qmail-uce.tgz
    - UCE 対策。
- qmail-del-tcpto, qmail-relayclient-diff
    - 不正中継関係で活用できそう。
- IPv6対応
    - tcp-envでIPv6アドレスへの対応、qmail-remoteでIPv6先へのsend

