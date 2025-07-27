---
title: 「表3. 日本語処理」の解説
---
Last modified: Sat Jan 13 16:05:38 2001

------------------------------------------------------------------------

### 半角カナ, 機種依存文字

#### 問題点

電子メールの日本語の取り扱いについては RFC1468 が実質的な標準です(RFC としては infomation ですが)。これによれば、日本語のメッセージは ISO-2022-JP (所謂JISコード)で送ることになっています。また、JIS X 0201 の仮名（半角カナ）は使われないと記述されています。しかし、日本のPCの歴史として、Shift_JIS(MS漢字)コード上で、半角カナや機種依存文字がよく使われてきました（現在のOS "Windows 98"でも使える）が、これを電子メールのメッセージに持ち込むわけにはいきません。各ユーザが意識して使わないようにすれば良いのですが、必ずしもそうはいきません。そこで、半角カナと機種依存文字の取り扱いを調べました。なお、「[使ってはいけない文字](/essay/japanese-character.html)」もお読み下さい。

#### 評価方法

「半角カナ」に関しては、半角カナの文字を使用したときに、メイラ─がどう処理するかを示します。

「機種依存文字」に関しては、機種依存文字をどのように処理しているかを示します。また、括弧内に対応する領域（13:JIS X 0208 の13区、NEC:NEC選定IBM拡張漢字,IBM:IBM拡張文字）を記述します。詳しくは「[使ってはいけない文字](/essay/japanese-character.html)」をご覧下さい。

### 日本語ファイル名

#### 問題点

日本語のファイル名の記述方法はRFC 2231による方法でなければなりません。しかし、RFC 2231 によるファイル名を認識できるメイラーは少ないため、実質的に使えません。そのため、それぞれのメイラーが勝手に日本語のファイル名を扱っているのが現状です。詳しくは[「添付ファイルにおける日本語のファイル名に関して」](/essay/japanese-filename.html) をお読み下さい。

#### 評価方法

日本語のファイル名のファイルを添付したときに、どのような形式で記述しているかを示します。RFC2231 に従って記述しているものは "RFC2231"、B エンコードしているものは "B"、ISO-2022-JP で記述しているものは "JIS"、Shift_JIS で記述しているものは "SJIS" で示します。RFC2231 以外で記述してあるものは RFC 上誤りです。なお、RFC2231 で記述しているもののなかにはその文法が正しくないものがありますのでご注意下さい（そこまでの検証はまだしていません）。

### RFC 2231 デコード

#### 問題点

先にも述べた通り、RFC2231 によるファイル名を認識できるメイラーは現状では少ないです。しかし、特に根拠のない方式で、何となく日本語のファイル名が使えるかもしれないという状態はよくありません。そのため、RFC2231 によるファイル名を認識できるメイラーを増やす必要があります。詳しくは[「添付ファイルにおける日本語のファイル名に関して」](/essay/japanese-filename.html) をお読み下さい。

#### 評価方法

"ほごほげ.jpeg" というファイルを添付してどうなるかを調べました。次に、RFC 2231 のファイル名が認識できるか試験を行います。次のようなヘッダの４つのファイル名 "hogohoge0.jpeg", "hogohoge1.jpeg", "ほごほげ2.jpeg", "ほごほげ3.jpeg" の添付ファイル名が認識できるかを調べました。[サンプルメッセージ](/essay/rfc2231.sample.txt)を用意したので、メイラーの作者の方はぜひ試してみてください。

> Content-Transfer-Encoding: Base64
> Content-Type: image/jpeg
> Content-Disposition: attachment;
> filename=hogohoge0.jpeg

> Content-Transfer-Encoding: Base64
> Content-Type: image/jpeg
> Content-Disposition: attachment;
> filename*0=hogohoge1;
> filename*1=.jpeg

> Content-Transfer-Encoding: Base64
> Content-Type: image/jpeg
> Content-Disposition: attachment;
> filename*=iso-2022-jp'ja'%1B%24B%24%5B%244%24%5B%242%1B%28B2.jpeg

> Content-Transfer-Encoding: Base64
> Content-Type: image/jpeg
> Content-Disposition: attachment;
> filename*0*=iso-2022-jp'ja'%1B%24B%24%5B%244%24%5B%242%1B%28B;
> filename*1=3.jpeg

------------------------------------------------------------------------

滝澤 隆史(TAKIZAWA Takashi)
<taki@cyber.email.ne.jp>
