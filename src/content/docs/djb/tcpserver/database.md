---
title: 接続制御データベース
sidebar:
  order: 3
---

## データベースの作成方法

接続制御データベースの作成には[tcprules](https://cr.yp.to/ucspi-tcp/tcprules.html)（[日本語訳](/djb/tools/ucspi-tcp/tcprules.html)）を使います。

## データベースの作成例

1. データベースを作成するために次の形式のファイルを作成する。

    ```
    IPアドレス:制御
    ```

2. 次のようなファイルを作成する。
    - 特定のユーザ、ホストからのみftpを許可したい。

        ```
        $ cat /service/ftpd/tcp

        foo@1.2.3.7:allow
        1.2.3.6:allow
        1.2.4.:allow
        :deny
        ```

        （ユーザ名が`foo`、IPアドレスが`1.2.3.7`のホスト及びIPアドレスが`1.2.3.6`と`1.2.4.*`であるホストからは接続を許可し、他のホストからは接続を拒否する）

    - 特定のホストからのsmtpの接続に対して環境変数を設定したい。

        ```
        $ cat /service/smtpd/tcp

        1.2.3.6:allow,RELAYCLIENT=""
        127.:allow,RELAYCLIENT=""
        ```

        （IPアドレスが`1.2.3.6`と`127.*`であるホストからの接続に対しては環境変数`RELAYCLIENT=""`を設定して接続を許可し、他のホストからは環境変数を設定せずに接続を許可する）

3. 以上のファイルをcdb形式に変換する。

    ```
    $ cd /service/ftpd
    # /usr/local/bin/tcprules tcp.cdb tcp.tmp < tcp
    $ cd /service/smtpd
    # /usr/local/bin/tcprules tcp.cdb tcp.tmp < tcp
    ```
