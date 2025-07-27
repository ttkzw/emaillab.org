---
title: 添付ファイルにおける日本語のファイル名に関して
sidebar:
  order: 4
---
1999年6月20日初出

Last modified: Thu Feb 8 07:22:14 2001

------------------------------------------------------------------------

## <span id="at_first">はじめに</span>

Windows のメイラーでは日本語のファイル名の付いた添付ファイルを扱えるものがほとんどであるが、その実装は正しいのであろうか？ 実はほどんどが誤りである。しかし、誤りではあるが同じ方法を実装していれば相互間の運用にはそれほど不都合はないため、Windows しか使っていないユーザーは誤りであることに気が付かないことが多い。定義されていない実装であるから当然のことながら、正しい実装をしている IMAP サーバやメイラーではそのファイル名を認識できない。本末転倒である。そこで、ここでは添付ファイルにおける日本語のファイル名について考察を行っていくことにする。

------------------------------------------------------------------------

## <span id="mime_header">MIME ヘッダ</span>

まず、この文書を理解するために必要な MIME 関連の RFC と MIME ヘッダを紹介する。

- RFC 2045 "MIME Part One: Format of Internet Message Bodies"
    - MIME ヘッダ（MIME-Version, Content-Type, Content-Transfer-Encoding, Content-ID, Content-Description）の解説および定義。符号化/復号化（quoted-printable, base64）の解説および定義。
- RFC 2046 "MIME Part Two: Media Types"
    - media type および主要な subtype と parameter の解説および定義。multipart の構造の解説も含まれる。
- RFC 2047 "MIME Part Three: Message Header Extensions for Non-ASCII Text"
    - non-ASCII をヘッダに扱うための符号化/復号化の解説および定義。
- RFC 2049 "MIME Part Five: Conformance Criteria and Examples"
    - MIME の適用例など。
- RFC 2183 "Communicating Presentation Information in Internet Messages: The Content-Disposition Header Field"
    - Content-Disposition ヘッダの解説および定義。
- RFC 2231 "MIME Parameter Value and Encoded Word Extensions: Character Sets, Languages, and Continuations"
    - parameter の non-ASCII に対する拡張および長い parameter の記述方法の解説および定義。

- Content-Type
    データの種類を特定するためのフィールドであり、RFC 2045に規定されている。データの種類に関してはRFC 2046に規定されており、Top-Level Media Type として "Text", "Image", "Audio", "Video", "Application", "Multipart", "Message" がある。
- Content-Transfer-Encoding
    - データの符号の種類を示すためのフィールドであり、RFC 2045に規定されている。データの符合としては "7bit", "8bit", "binary" があり、"8bit", "binary" を 7bit で記述するための符号化の種類としては "quoted-printable" と "base64" がある。以上5種類が規定されていて、どれかを記述することになっている。しかし、"7bit" がデフォルトとして示されているため、"7bit" の場合は省略することが可能である。
    - なお、一部のメイラーでは uuencode を無理やり MIME 化し、Content-Transfer-Encoding として "x-uuencode" という規定されていないものを記述するものもあるが、相互運用性に欠るため用いるべきではない。uuencode は "7bit" のデータとしてボディに記述するにとどめるべきである。
- Content-Disposition
    - データの性質を記述するためのフィールドであり、RFC 2183に規定されている。データの性質とはファイル名、作成日、サイズなどである。詳しい説明は後述するためここでは省略する。
- Content-Description
    - データに関する情報を記述するためのフィールドであり、RFC 2045に規定されている。Subject と同じようなものである。
- Content-ID
    - ユニークな識別子を記述するためのフィールドであり、RFC 2045に規定されている。Message-ID と同じようなものである。

------------------------------------------------------------------------

## <span id="filename_syntax">ファイル名の記述方法</span>

添付ファイルのファイル名は先の節で述べたように Content-Disposition フィールドに記述することになっている。
時々、Content-Type フィールドに name パラメータを用いてファイル名を記述しているものも見受けられるが、これは特に規定されていないためあまりよろしくない。一応、"Content-Type: message/external-body" には name パラメータはあるが、これは外部のリソースのファイル名を示すものであり、添付ファイルの名前を示すものではない。

Content-Dispositon の定義はRFC 2183の "2. The Content-Disposition Header Field" に次のように記述されている。

> disposition := "Content-Disposition" ":"
> disposition-type
> *(";" disposition-parm)

ここで、disposition-type は「自動的に表示することを示す」 "inline" と 「ユーザの判断により表示したり保存したりすることを示す」"attachment" の二つをどちらかが大抵記述される。disposition-parm はこのパートの性質（ファイル名、作成日、サイズ等）を示すパラメータが記述される。ファイル名を示すパラメータ filename-parm は次のように定義されている。

> filename-parm := "filename" "=" value

なお、parameter, value の定義はRFC 2045を参照すると記述されているので、RFC 2045 の "5.1. Syntax of the Content-Type Header Field" を引用すると次のように定義されている。

> parameter := attribute "=" value
> attribute := token
> ; Matching of attributes
> ; is ALWAYS case-insensitive.
> value := token / quoted-string
> token := 1*<any (US-ASCII) CHAR except SPACE, CTLs,
> or tspecials>
> tspecials :=  "(" / ")" / "<" / ">" / "@" /
> "," / ";" / ":" / "\" / <">
> "/" / "[" / "]" / "?" / "="
> ; Must be in quoted-string,
> ; to use within parameter values

次にサンプルを示す。これは画像ファイルを添付したときの例である。

> Content-Type: image/jpeg
> Content-Transfer-Encoding: base64
> Content-Disposition: attachment; filename=hogohoge.jpeg
> Content-Description: a picture of the hogohoge
>
>     [base64-encoded-data]

なお、RFC 2183は non-ASCII キャラクタと 78 文字以上のパラメータを扱っていない。これらはRFC 2231で定義されている。

------------------------------------------------------------------------

## <span id="win-mailer">現状の Windows のメイラーにおける日本語ファイル名の取り扱い</span>

ここでは添付ファイル名における日本語の取り扱いに関して考えてみる。まず、現状での Windows のメイラーにおいてどのように取り扱っているかを見てみよう。次に並べているのは筆者が[調査した結果](/win-mailer/table.html)をまとめたものである。

1. MIME B encoding（8割）
2. JIS(ISO-2022-JP)（2割）
3. Shift_JIS（古いメイラーの一部）
4. 日本語を許容しない（いくつかある）

ほぼ主流となっている 1 の MIME B encoding は実は RFC 2047の "5. Use of encoded-words in message headers" に「'encoded-word' は MIME Content-Type や Content-Disposition フィールドの parameter で使用してはいけない」という記述があるため間違いである。さらに ISO-2022-JP を B encoding すると文字列が長くなって、途中で折り返す(folding)ことがあるが、parameter の value は先の定義によると CR, LF を含む CTLs が使えないため折り返しができないことになり、折り返している現状も間違いである。そのため、国際化している（日本特有の事情を知らない）メイラーや IMAP サーバではこの B encoding した日本語のファイル名や折り返しを正しく認識できないことがあり、問題である。特に IMAP4 ではマルチパートのメールの特定のパートだけ取り出すという便利な機能があるのだが、このような現状のため日本語のファイル名を取得することができないことがある（IMAP4 に関する事例は [IMAP4-ML](http://imap4.orangesoft.co.jp/imap/imap4-ml.html) \#01118 より）。

2,3 の JIS, Shift_JIS は Character Encoding Scheme の指定がなくそのまま記述してあるため好ましくない。さらに、先の [RFC 2045](/emailref/RFC/rfc2045.txt) における parameter, value の定義によると US-ASCII でないため明らかに間違いである。また、Shift_JIS は 8bit であるため弊害が大きい。

そうなると、現実的には 4 が一番正しい。しかし、これでは日本語のファイル名が使えない。先の節の最後に non-ASCII を扱う方法を定義した RFC があると紹介したのになぜそれを使わないのか？ その答えはこの方式のパラメータをデコードできるメイラーが最近では増えてきたもののまだ多くない（[一覧表](../win-mailer/table.html)参照）からであるからである。相手がデコードできないファイル名で送っても意味がない。かといって、このまま間違いのまま放っておくのも問題がある。では、どのようにしたらいいだろうか。結論としては、RFC 2231に従ってエンコードされたファイル名のデコードができるメイラーが増えてくるのを待つしかない。それまでは日本語のファイル名は使わないか、あるいは相手がデコードできないかも知れないことを前提として日本語のファイル名を使うことになる。いつになるかわからないが、増えてきたところで、エンコードもできるようにすればよい。

ということで、ここで筆者からのお願いであるが、メイラーの作者の方がこの文書を読んでくれていたら、ぜひ第一段階である RFC 2231 のファイル名のデコードをサポートして欲しい。また、メイラーの利用者もこの文書に書いてある内容が重要であると認識してくれたら、ぜひ作者の方へ RFC 2231 によるファイル名のデコードの要望を出してもらえないだろうか。決して RFC 2231 のエンコードを要求しているのではないし、要求できるような現状でもない。とにかく RFC 2231 のデコードができるメイラーを増やすことが重要なのである。なお、RFC 2231 に従ってエンコードした[サンプルメッセージ(Ver1.2)](/essay/rfc2231.sample.txt)を置いておく。

------------------------------------------------------------------------

## <span id="rfc2231">RFC 2231</span>

ここではRFC 2231についての説明を行う。先に説明した通り、RFC 2231 は non-ASCII キャラクタと 78 文字以上のパラメータを扱うために、RFC 2045の parameter の定義を拡張し、再定義している。RFC 2183で定義されている Content-Disposition フィールドにおける disposition-parm は文法的には parameter と同じ位置づけであり、parameter は RFC 2045 で定義されているという記述があるため、この disposition-parm も同様に拡張される。なお、RFC 2045 の parameter の定義は先に記述してあるのでここでは省略する。

RFC 2231の "7. Modifications to MIME ABNF" では次のように再定義されている。

> parameter := regular-parameter / extended-parameter
> regular-parameter := regular-parameter-name "=" value
> regular-parameter-name := attribute [section]
> attribute := 1*attribute-char
> attribute-char := <any (US-ASCII) CHAR except SPACE, CTLs,
> "*", "'", "%", or tspecials>
> section := initial-section / other-sections
> initial-section := "*0"
> other-sections := "*" ("1" / "2" / "3" / "4" / "5" /
> "6" / "7" / "8" / "9") *DIGIT)

ここで、regular-parameter というのは US-ASCII における parameter である。その例を示すと次のようになる。parameter が複数行になる場合に attribute に "\*" とシーケンス番号が付くことがわかるだろう。

> Content-Disposition: attachment;
> filename*0=hogohoge;
> filename*1=.jpeg

これは次と同じ意味になる。

> Content-Disposition: attachment;
> filename=hogohoge.jpeg

次に、extended-parameter というのは US-ASCII 以外の文字符号を伴う場合の拡張であり、次のように定義されている。

> extended-parameter := (extended-initial-name "="
> extended-value) /
> (extended-other-names "="
> extended-other-values)
> extended-initial-name := attribute [initial-section] "*"
> extended-other-names := attribute other-sections "*"
> extended-initial-value := [charset] "'" [language] "'"
> extended-other-values
> extended-other-values := *(ext-octet / attribute-char)
> ext-octet := "%" 2(DIGIT / "A" / "B" / "C" / "D" / "E" / "F")

value としては attribute-char 以外は16進数で表現することになる。charset は文字符号化方式で、language は RFC 1766 に規定された言語タグを示す。具体例を示すと次のようになる。charset としては "ISO-2022-JP" を、language としては "ja"(日本語) を使ってみる。parameter の2つ目は US-ASCII のみなのでここでは regular-parameter 扱いとして書いてみる。ちなみに、"ほごほげ.jpeg"である。US-ASCII 以外の文字符号が伴う場合は attribute に "\*" が付くことがわかると思う。

> Content-Disposition: attachment;
> filename*0*=iso-2022-jp'ja'%1B%24B%24%5B%244%24%5B%242%1B%28B;
> filename*1=.jpeg

なお、一行で書くと次のようになる。

> Content-Disposition: attachment;
> filename*=iso-2022-jp'ja'%1B%24B%24%5B%244%24%5B%242%1B%28B.jpeg

なお、RFC 1468 "Japanese Character Encoding for Internet Messages"の改定案draft-yamamoto-charset-iso-2022-jp-02.txtの "5.4 MIME Parameter Extensions" では charset に "ISO-2022-JP"を使い、language は省くべきであると記述されている。この例では language は付けている。ISO-2022-JP を使う上で注意しなければならないのは attribute-char として使えない文字が ISO-2022-JP のコード上では表れる点である。そのため、このドラフトでは\[0-9A-Za-z\]以外のコードを符号化する考えも示されている。この考えにしたがって上記の例では\[0-9A-Za-z\]以外のコードをすべて ext-octet に符号化したが、("$"はattribute-charであるため)%24を"$"にしても実は問題ないのである。

------------------------------------------------------------------------

## <span id="mistake">RFC 2231 の誤り</span>

RFC 2231を読んでいるとどうしても理解できない部分がある。"4.1. Combining Character Set, Language, and Parameter Continuations" に示されている次の例である。

> Content-Type: application/x-stuff
> title*0*=us-ascii'en'This%20is%20even%20more%20
> title*1*=%2A%2A%2Afun%2A%2A%2A%20
> title*2="isn't it!"

RFC 2231はRFC 2045の parameter の定義を拡張し、再定義しているに過ぎない。しかし、この例では parameter の前に ";"(semicolon) が存在しない。明らかに、RFC 2045の定義に反している。そのため、この例はこの RFC の著者の書き間違いであると思われる。RFC 2045の定義通りに書くと次のようになる。

> Content-Type: application/x-stuff;
> title*0*=us-ascii'en'This%20is%20even%20more%20;
> title*1*=%2A%2A%2Afun%2A%2A%2A%20;
> title*2="isn't it!"

追記(1999年10月7日)：Winbiff でお馴染の[オレンジソフト](http://www.orangesoft.co.jp/)の日比野さんがこの RFC の著者に問い合わせたところ、やはり例の方が間違っているとのことでした。次の改訂では直すそうです。

------------------------------------------------------------------------

Thanks to HAT, Hirokatsu Hibino and AONO Yuhei.

滝澤 隆史(TAKIZAWA Takashi)
<taki@cyber.email.ne.jp>
