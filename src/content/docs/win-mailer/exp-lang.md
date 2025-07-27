---
title: 「表4. 言語」の解説
---
Last modified: Sat Jan 13 16:13:03 2001

------------------------------------------------------------------------

### 言語

#### 評価方法

表示および作成の文字コードとして使用可能かを示しています。ただし、表示にしか対応していないものは△で示します。

#### 解説

特に厳密には調べていません。表示用の文字コードおよび作成用の文字コードの欄にあるかどうかを調べています。あるいはへルプなどの文書から調べているものもあります。

筆者は文字コードに関する専門家ではないので、記述が間違っている可能性があります。詳しくは参考文献で示したページを見てください。

<table data-border="1">
<colgroup>
<col style="width: 33%" />
<col style="width: 33%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr>
<th>言語</th>
<th>文字符号化方式</th>
<th>説明</th>
</tr>
</thead>
<tbody>
<tr>
<td>西ヨーロッパ</td>
<td>ISO-8859-1 (Latin1)</td>
<td>かつての EC 諸国で共通に使える文字</td>
</tr>
<tr>
<td>中央ヨーロッパ</td>
<td>ISO-8859-2 (Latin2)</td>
<td>東西の壁崩壊後に欧州協定に参加した諸国の文字</td>
</tr>
<tr>
<td>南ヨーロッパ</td>
<td>ISO-8859-3 (Latin3),<br />
ISO-8859-9 (Latin5)</td>
<td>エスペラント語とマルタ語。<br />
トルコ語に関しては ISO-8859-9 (Latin5) の方が使われている。</td>
</tr>
<tr>
<td>バルト言語</td>
<td>ISO-8859-4 (Latin4),<br />
ISO-8859-10 (Latin6)</td>
<td>北欧諸国で使える文字。<br />
ISO-8859-10 (Latin6) が使われている。</td>
</tr>
<tr>
<td>キリル言語</td>
<td>ISO-8859-5 (Cyrillic),<br />
KOI8-R (Russian),<br />
KOI8-U (Ukrainaian)</td>
<td>ロシア語としては ISO-8859-5 は使われず、KOI8-R (RFC1489) がデファクトスタンダードのようである。<br />
詳しくは <a href="http://czyborra.com/charsets/cyrillic.html">The Cyrillic Charset Soup</a> を参照。</td>
</tr>
<tr>
<td>アラビア語</td>
<td>ISO-8859-6 (Arabic)</td>
<td>アラビア語</td>
</tr>
<tr>
<td>ギリシャ語</td>
<td>ISO-8859-7 (Greek)</td>
<td>RFC1947</td>
</tr>
<tr>
<td>ヘブライ語</td>
<td>ISO-8859-8 (Hebrew)</td>
<td>RFC1555</td>
</tr>
<tr>
<td>簡体字中国語</td>
<td>GB2312,<br />
HZ-GB-2312</td>
<td>HZ-GB-2312 に関しては RFC 1842, RFC 1843 を参照。</td>
</tr>
<tr>
<td>繁体字中国語</td>
<td>Big5</td>
<td>台湾で用いられている。</td>
</tr>
<tr>
<td>日本語</td>
<td>ISO-2022-JP</td>
<td>RFC1468</td>
</tr>
<tr>
<td>韓国語</td>
<td>ISO-2022-KR,<br />
EUC-KR</td>
<td>RFC 1557 によると、へッダには EUC-KR を MIME 符号化したものを用い、本文には ISO-2022-KR を用いるようである。</td>
</tr>
<tr>
<td>UNICODE</td>
<td>UTF-8,<br />
UTF-7</td>
<td>IETF の方針として UTF-8 を将来実装することが望まれている。<br />
UTF-7 は原則としては使わない。</td>
</tr>
</tbody>
</table>

#### 参考文献

- [The ISO 8859 Alphabet Soup](http://czyborra.com/charsets/iso8859.html)
  http://czyborra.com/charsets/iso8859.html
- [漢字袋](http://kanji.zinbun.kyoto-u.ac.jp/~yasuoka/kanjibukuro/)
  http://kanji.zinbun.kyoto-u.ac.jp/~yasuoka/kanjibukuro/

------------------------------------------------------------------------

滝澤 隆史(TAKIZAWA Takashi)
<taki@cyber.email.ne.jp>
