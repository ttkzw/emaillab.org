---
title: Cyrus IMAP Server
sidebar:
  order: 1
---

1999年2月9日初稿、1999年2月13日更新

## Cyrus IMAP Server を使う方法

注意)ここに述べる方法は配送ができたというレベルのものでしかありません。実際に運用しているわけではないので運用上何か問題が生じるかもしれません。配送動作をよく理解してからお使い下さい。

### 各ユーザ毎に IMAP の利用を設定する場合、その1

各ユーザの ~/.qmail に次の一行を記述するだけです。

```
|preline -f /usr/cyrus/bin/deliver "$USER" ;/usr/cyrus/bin/qmail-error "$?"
```

このファイルの動作原理を説明します。各ユーザに配送されたメールは .qmail にしたがって処理されます。具体的には preline により "Return-Path:" の行を付けた後に Cyrus IMAP Server の配送プログラム deliver によりそのメールボックスへ配送されます。qmail-error に関しては「[deliver のエラーコードの処理](#qmail-error)」を参照してください。なお、qmail の場合はローカル配送は配送先のユーザの権限で行われているので deliver のパーミッションを o+x してあげる必要があります。ただし、4750 (cyrus の SUID)のパーミッションを 4751 にするわけですから、それなりの注意が必要です。配送が冗長になりますが、その2の方法が安全です。

また、~/.qmail-default に次の一行を記述すると qmail の拡張アドレスにより、userid-mailbox 宛てのメールは Cyrus のメールボックス user.userid.mailbox へ配送されます。

```
|preline -f /usr/cyrus/bin/deliver -u "$EXT" -a "$USER" "$USER" ; /usr/cyrus/bin/qmail-error "$?"
```


### 各ユーザ毎に IMAP の利用を設定する場合、その2

まず、各ユーザの ~/.qmail に次の一行を記述します。

```
|qmail-inject -f "$SENDER" "cyrus-$RECIPIENT"
```

次に、~cyrus/.qmail-default に次の一行を記述します。

```
|preline -f /usr/cyrus/bin/deliver "$EXT" ;/usr/cyrus/bin/qmail-error "$?"
```

これらのファイルの動作原理を説明します。qmail ではローカル配送は配送先のユーザの権限で行われるため、そのままの権限では deliver (cyrus.mail の 4750)を起動させることはできません。そのため、メールを cyrus に転送することにより cyrus の権限で deliver を起動させてあげます。具体的に説明すると、宛先 userid@domain に配送されたものを ~/.qmail の処理で宛先を cyrus-userid@domain に書き換え、ユーザ cyrus に転送します。cyrus の拡張アドレスである cyrus-userid@domain は .qmail-default のしたがって処理されます。ここでは userid の部分だけがアドレスとして取り出され、preline により "Return-Path:" の行を付けた後に Cyrus IMAP Server の配送プログラム deliver によりそのメールボックスへ配送されます。なお、最後の qmail-error に関しては「[deliver のエラーコードの処理](#qmail-error)」を参照してください。

### システムにユーザアカウントを設けずに cyrus のみのアカウントで処理する方法

Cyrus ではメールボックスの操作を含めあらゆる操作を cyrus のユーザ権限のみ（認証のみ root 権限）で行います。そのため、極端な話ですがユーザのシステムアカウントを作らなくても認証部分をどうにかすれば運用できます。ここではその方法を実現する方法を示します。

まず、~alias/.qmail-default に次の一行を記述します。

```
|qmail-inject -f "$SENDER" "cyrus-$RECIPIENT"
```

次に、~cyrus/.qmail-default に次の一行を記述します。

```
|preline -f /usr/cyrus/bin/deliver "$EXT" ;/usr/cyrus/bin/qmail-error "$?"
```

これらのファイルの動作を説明します。qmail では ~alias/.qmail-default のファイルがある場合、そのドメインにおける宛先のないメッセージは ~alias/.qmail-default の記述に従って処理されます。ここでは受信アドレス userid@domain を cyrus-userid@domain のように書き換えて、転送します。

次に cyrus-userid@domain はユーザ cyrus のホームディレクトリへ配送されます。ファイル ~cyrus/.qmail-default があるため、ユーザ cyrus の拡張アドレスである cyrus-userid@domain は .qmail-default の記述にしたがって処理されます。ここでは userid の部分だけがアドレスとして取り出され、preline により "Return-Path:" の行を付けた後に Cyrus IMAP Server の配送プログラム deliver によりそのメールボックスへ配送されます。なお、最後の qmail-error に関しては「[deliver のエラーコードの処理](#qmail-error)」を参照してください。

なお、システムのユーザアカウントがないため、独自のパスワードファイルを持つように pwcheck をいじる必要があります。OBATA Akio さん編集の [IMAP FAQ LIST](http://www.geocities.co.jp/SiliconValley-PaloAlto/7393/imap/faq.html) に 独自の pwcheck を使用しているページへのリンクがあります。

### 補足事項

#### <span id="qmail-error">deliver のエラーコードの処理</span>

Cyrus の内部配送プログラム deliver はエラーコードとして /usr/include/sysexits.h を扱っています。ここに示されているのは 64 から 78 まで（deliver.c で実際使われているのは64, 65, 67, 70, 74, 75, 77）のエラーコードです。一方、man qmail-command を読めばわかりますが、qmail では 100 が hard error (failure) で 111 が soft error (deferral)です。また、64, 65, 70, 76, 77, 78, 112 も hard error 扱いとなり、残りは soft error 扱いとなります。そのため、最もよく起こるであろう"67 /\* addressee unknown \*/" は soft error となり再送を試みようとします。これでは問題があるので deliver のエラーコードの一部を qmail 用に変えてあげる必要があります。

エラーコードを変換するスクリプト /usr/cyrus/bin/qmail-error の例を示します。必要ならエラーメッセージを追加することができます（ここでは qmail-local が出力するエラーメッセージと同じものを返すことにします）。

```sh
#!/bin/sh
# qmail-error
#
#  This script derives the error code for Cyrus' deliver from $1,
#  and change the code into the qmail's.
#  See also /usr/include/sysexits.h and qmail-command(8).
#
case $1 in
  67)
    echo "Sorry, no mailbox here by that name. (#5.1.1)" >&2
    exit 100
    ;;
  *)
    exit "$1"
    ;;
esac
# end of script
```

Thanks to OBATA Akio.
