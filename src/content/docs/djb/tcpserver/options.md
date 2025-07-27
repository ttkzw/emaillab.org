---
title: オプション
sidebar:
  order: 5
---

次のようにして起動します。

```
tcpserver options host port program [ arg ... ]
```

options
: 次のようにオプションを記述します。

```
[ -1pPhHrRoOdDqQv ] [ -climit ] [ -xrules.cdb ] [ -Bbanner ] \`
[ -ggid ] [ -uuid ] [ -bbacklog ] [ -llocalname ] [ -ttimeout ]`
```

また、下記の表に主なオプションを示します。詳細はman tcpserverを見てください。

host
: サーバを起動するIPアドレス/ホストを特定しないのであれば0を記述します。

port
: ポート番号あるいはサービス名を記述します。

program
: サーバ・プログラム名を記述します。


主なオプション

|オプション|内容|
|---|---|
|-q|エラーメッセージを出力する|
|-Q|エラーメッセージを出力しない（デフォルト）|
|-v|すべてのメッセージを出力する|
|-p|パラノイドを行う。リモートホスト名を調べた後、そのホスト名でIPアドレスを調べ、TCPREMOTEIP に一致するか調べる。一致しない場合は TCPREMOTEHOST をセットしない。|
|-P|パラノイドを行わない。（デフォルト）|
|-h|リモートホスト名を調べ、TCPREMOTEHOST をセットする。（デフォルト）|
|-H|リモートホスト名を調べない。|
|-r|IDENTを行い、TCPREMOTEINFO をセットする。（デフォルト）|
|-R|IDENTを行わない。|
|-c limit|最大同時接続数の設定。デフォルトは40|
|-x rules.cdb|接続制御を行うときの接続制御データベースのファイル名|
|-B banner|接続時にバナーをネットワークへ出力する。|
|-u uid|ユーザIDを uid に切り替える|
|-g gid|グループIDを gid に切り替える|
|-l localname|ローカルホスト名を調べるのをやめて、localname を TCPLOCALHOST にセットする|
|-t timeout|IDENT をタイムアウトする時間(秒)。デフォルトは 26|
