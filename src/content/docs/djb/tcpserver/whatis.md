---
title: tcpserverとは
sidebar:
  order: 1
---

tcpserverはD. J. Bernstein氏作のサーバ制御ツールで[ucspi-tcp](https://cr.yp.to/ucspi-tcp.html)（[日本語訳](/djb/tools/ucspi-tcp/top.html)）というパッケージに入っています。UCSPIとはDJB氏が提案している [UNIX Client-Server Program Interface](https://cr.yp.to/proto/ucspi.txt)（[日本語訳](/djb/tools/ucspi-tcp/ucspi.txt)）というTCP/IPのクライアント・サーバ通信ツールのインターフェースの仕様です。また、接続制御のために同氏作のデータベース[cdb](https://cr.yp.to/cdb.html)（[日本語訳](/djb/tools/cdb/top.html)）を用います。

## 特徴

tcpserverには以下のような特徴があります。

- ローカルホスト・リモートホストのホスト名、IPアドレス、ポート番号、ユーザ名を環境変数で参照できる。
- 同時接続数を制限できる。
- そのホストが複数のIPアドレスを持つ場合、特定のIPアドレス/ホストへの接続に対して制御できる。
- ユーザ名、IPアドレス、ドメイン名を元にアクセス制御ができる。
- アクセス制御ルールにはハッシュ化されたデータベースcdbを用いているため、大規模・複雑になっても高速に処理できる。
- アクセス制御データベースの変更はすぐに反映される。（SIGHUPを送るといった操作はいらない）
- ソース・ルーティング(IP options)を落とすことができる。
- TCP_NODELAYを有効にできる。
