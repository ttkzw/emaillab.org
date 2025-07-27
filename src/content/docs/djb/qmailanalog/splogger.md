---
title: splogger
sidebar:
  order: 2
---

splogger は標準入力から入力されたメッセージを syslog にタグと詳細な時間を付けて出力するソフトウェアであり、qmail のパッケージに含まれています。引数を２つ取り、１つ目がタグで、２つ目がファシリティです。ファシリティはデフォルトでは 2(LOG_MAIL) が使われます。tcpserver のログの出力として使う場合は接続の制御という点から見て 4(LOG_AUTH) を使うことにします。ファシリティについては（OSによって違うかも知れませんが） /usr/include/sys/syslog.h を見てください。
