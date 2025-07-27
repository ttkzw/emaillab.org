---
title: TAI64NをTAIに変換するプログラム
sidebar:
  order: 2
---

1999年9月23日初出、2002年06月11日更新

daemontools 0.60以降ではタイムスタンプの表記がTAI64N形式となっています。
しかし、qmailanalog-0.70ではこのTAI64N表記が理解できないため、TAI64N表記をTAI表記に変えるプログラムtai64ntaiを作りました。また、TAI表記をローカルタイム表記に変えるプログラムtailocalも作りました。このプログラムはdaemontools0.70に[パッチ](daemontools-0.70.diff.gz)を当てて、コンパイルをすればできます。

```
$ patch -p1 < daemontools-0.70.diff
$ make
# make install
```

makeを実行したら、次のテストをしてみてください。TAI表記になっていれば問題なしです。手動でインストールしてください。

```
$ date | tai64n | ./tai64ntai
938162793.172317 Fri Sep 24 17:46:33 JST 1999
```

一応、注意事項として、このプログラムは完全に無保証です。各自の責任において使用してください。
