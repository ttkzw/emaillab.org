---
title: インストール
sidebar:
  order: 2
---

ucspi-tcpパッケージのインストールに関しては"[How to install ucspi-tcp](https://cr.yp.to/ucspi-tcp/install.html)"（[日本語訳](/djb/tools/ucspi-tcp/install.html)）をご覧ください。また、旧バージョンからのアップグレードに関しては "[Upgrading from previous versions of ucspi-tcp](https://cr.yp.to/ucspi-tcp/upgrade.html)"（[日本語訳](/djb/tools/ucspi-tcp/upgrade.html)）もご覧ください。

ucspi-tcpパッケージと共に導入を検討してもらいたいものに[daemontools パッケージ](https://cr.yp.to/daemontools.html)（[日本語訳](/djb/tools/daemontools/top.html)）があります。このパッケージに含まれるsvscan/superviseを使うとtcpserverそのものの起動・停止・再起動などの制御が楽になります。tcpserverそのものが何かの原因で死んでも、superviseが自動的に起動し直してくれます。また、multilogを使って接続の記録をとることもできます。

また、これは特にインストールしなければならないというものではありませんが、[cdb パッケージ](https://cr.yp.to/cdb.html)（[日本語訳](/djb/tools/cdb/top.html)）もインストールすると何かと便利でしょう。tcpserverはアクセス制御データベースにcdbを用いているので、その内容の確認にcdbdumpなどが重宝します。
