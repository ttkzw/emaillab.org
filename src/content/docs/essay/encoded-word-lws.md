---
title: Japanese in the header - encoded-word example
sidebar:
  order: 10
---

encoded-word と linear-space-white の関係を示す例を紹介する。主に RFC 2047 に示されている例である。

コメントのデリミタである"`(`"と"`)`"との間には linear-space-white が必要ないことを示す例

    encoded form                                displayed as
    (a)                        (a)

encoded-word と ctext との間には linear-space-white が必要な例

    encoded form                                displayed as
    (a b)                      (a b)
    (a b)                      (a b)
    (a                                          (a b)
     b)
    (a                         (a b)
     b)

encoded-word 間の linear-space-white が表示の目的で無視される例

    encoded form                                displayed as
    (ab)     (ab)
    (ab)    (ab)
    (a                         (ab)
        b)

符号化される文字列の中にスペースを表示するためにスペースを encoded-word として符号化する例

    encoded form                                displayed as
    (a b)                      (a b)

二つの符号化される文字列の間にスペースを表示ために encoded-word の一つにスペースを符号化する例

    encoded form                                displayed as
    (a=?ISO-8859-2?Q?_b?=)    (a b)
