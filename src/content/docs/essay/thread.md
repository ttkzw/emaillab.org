---
title: スレッドの生成(Message-ID, In-Reply-To, References に関して) (第二版)
sidebar:
  order: 3
---
1999年3月21日初出、2001年3月16日第二版

Last modified: Sat Apr 28 21:22:27 2001

------------------------------------------------------------------------

## <span id="at_first">はじめに</span>

メイリングリストで大量のメッセージを受け取っている場合、MUA のスレッド表示の機能は大変便利である。また、メイリングリストマネージャによっては過去のメッセージをスレッド毎に取り出すことが可能なものもあり大変重宝する。また、人によってはメイリングリストのメッセージをニューズの形式に変換して、ニューズリーダーでスレッド表示にして読む人もいる。

このようなスレッドは基本的には "Message-ID", "In-Reply-To", "References" といったメッセージ識別子を記述するフィールドを持ったヘッダーにより生成される。しかし、現状では必ずしもうまくスレッドがつながらない場合がある。そのため、"Subject" で判断したり、"Date" で前後を判断したり、さらには本文の引用で判断する（ここまでくると異常だ）ものもある。なぜ、このような状態になるかというと、RFC 822 の記述が曖昧であるからだ。そこで、ここでは、RFC 822 の曖昧さを示し、その曖昧さを解消した RFC 822 の改定版 RFC 2822 を紹介する。

------------------------------------------------------------------------

## <span id="rfc822">RFC 822 における曖昧な定義</span>

[RFC 822](/emailref/RFC/rfc822.txt) における "Message-ID", "In-Reply-To", "References" の定義に関して、３つの曖昧さがある。その曖昧さを論じるために、RFC 822 から一部抜粋したものを以下に記す。

> 4.1.  SYNTAX
> optional-field =
> /  "Message-ID"        ":"   msg-id
> /  "In-Reply-To"       ":"  *(phrase / msg-id)
> /  "References"        ":"*(phrase / msg-id)
>
>     4.6.  REFERENCE FIELDS
>
>     4.6.2.  IN-REPLY-TO
>
>             The contents of this field identify  previous  correspon-
>        dence  which this message answers.  Note that if message iden-
>        tifiers are used in this  field,  they  must  use  the  msg-id
>        specification format.
>
>     4.6.3.  REFERENCES
>
>             The contents of this field identify other  correspondence
>        which  this message references.  Note that if message identif-
>        iers are used, they must use the msg-id specification format.

曖昧さの１つ目は "optional-field" という扱いである。そのため、"optional" という言葉を「付けても付けなくてもよい」と解釈し、メイリングリストに投稿する場合であっても（MUA 自体は宛先がメイリングリストかどうか判断できないから） "Message-ID", "In-Reply-To", "References" を付けない MUA が存在する。

曖昧さの２つ目は "In-Reply-To", "References" の文法の "\*(phrase / msg-id)" という記述である。返信/参照するメッセージを識別できるものであれば、msg-id でなくても日時などの文字列でもよいこととなっている。

曖昧さの３つ目は２つ目のことにも関係するが、"In-Reply-To", "References" の具体的な付け方に関する記述がないことである。つまり、返信するときの返信元の "Message-ID", "In-Reply-To", "References" との関係がはっきりしないことである。

これらの３つの曖昧さにより、現状では "Message-ID", "In-Reply-To", "References" に関して様々な実装があり、相互運用性において少なからずスレッド生成の処理に問題が生じている。この RFC 822 では "In-Reply-To", "References" がスレッドの生成に用いられるとは一切記述されていないため仕方ないのかも知れない。

------------------------------------------------------------------------

## <span id="rfc2822">RFC 2822 による曖昧さの解消</span>

2001年4月に RFC 822 の改訂版である [RFC 2822](/emailref/RFC/rfc2822.txt) が公開された。RFC 2822 では RFC 822 の現状に合わなく時代遅れになった部分（なにせ19年も前のものだ）が改善され、また、文法や意味が明確に記述され、曖昧さが解消されている。当然、ここで議論している "Message-ID", "In-Reply-To", "References" に関しても明確に記述されている。次にどのように解消されたか紹介する。以降引用するのは RFC 2822 の "3.6.4. Identification fields" に記述されている内容である。

"optional-field" という扱いに関しては次に引用した段落のようにそれぞれ "SHOULD have" と記述されている。つまり、各メッセージは "Message-ID" を持ち、返信するメッセージには "In-Reply-To" と "References" を持つべきであると記述されている。

> Though optional, every message SHOULD have a "Message-ID:" field.
> Furthermore, reply messages SHOULD have "In-Reply-To:" and
> "References:" fields as appropriate, as described below.

"In-Reply-To", "References" の文法に関しては、"phrase" がなくなり、一つ以上の msg-id のみを記述するようになっている。

> message-id      =       "Message-ID:" msg-id CRLF
> in-reply-to     =       "In-Reply-To:" 1*msg-id CRLF
> references      =       "References:" 1*msg-id CRLF

"In-Reply-To", "References" の付け方に関しては次に引用する RFC 2822 の "3.6.4. Identification fields" の "In-Reply-To:" と "References:" に関する記述（邦訳）に明確に記述されている。また、「スレッド」に関する記述も見られる。

> "In-Reply-To:" フィールドと "References:" フィールドは返信メッセージを作成するときに使われる。これらは元のメッセージのメッセージ識別子や他のメッセージ（例えば、返信メッセージに対してさらに返信する場合）のメッセージ識別子を保持する。"In-Reply-To:" フィールドは返信するメッセージを識別するために用いられ、"References:" フィールドは話題の「スレッド」を認識するために用いられる。
>
> 返信するときに生成されるメッセージの "In-Reply-To:" フィールドと "References:" フィールドは次のように構築される。
>
> "In-Reply-To:" フィールドには返信するメッセージ（親メッセージ）の "Message-ID:" フィールドの内容が含まれる。親メッセージが複数であれば "In-Reply-To:" フィールドには全ての親の "Message-ID:" フィールドの内容が含まれる。親メッセージに "Message-ID:" フィールドがなければ、新規メッセージには "In-Reply-To:" フィールドは付かない。
>
> "References:" フィールドには（もしあれば）親メッセージの "References:" フィールドの内容と（もしあれば）親メッセージの "Message-ID:" フィールドの内容がその順序で含まれる。親メッセージに "References:" フィールドが含まれていなく、たった一つのメッセージ識別子を含む "In-Reply-To:" フィールドがあれば、"References:" には親の "In-Reply-To:" フィールドの内容と（もしあれば）親の "Message-ID:" フィールドの内容がその順序で含まれる。親に "References:", "In-Reply-To:", "Message-ID:" がなければ、新規メッセージには "References:" フィールドは付かない。
>
> 注釈：「議論のスレッド」を表示するために "References:" フィールドを解析する実装がある。この実装は各新規メッセージが一つだけの親に対する返事であり、それゆえにそこに並べられる各メッセージの親を見つけるために "References:" フィールドを遡ることができると思い込んでいる。そのため、複数の親を持つ返事への "References:" フィールドを作る試みが妨げられる。

------------------------------------------------------------------------

## <span id="draft">現状での改善案</span>

RFC 2822 が公開された現在では RFC 822 は obsolete であるため、極力 RFC 2822 の文法に従うべきである。とはいっても、いきなり新しい RFC に合わせろというのは無理な話ではある。ただし、それぞれの文法を見てもらえばわかるが、RFC 2822 で生成した "In-Reply-To", "References" は RFC 822 には違反していない。ということは返信時には RFC 2822 に従ってメッセージを生成すればよい。逆に受け取ったメッセージはできるだけ RFC 822 の形式にも対応できるようにすればよい。次第に各 MUA が RFC 2822 の方法へ移行できれば相互運用性が高まっていくであろう。

ただし、"References" における msg-id の個数には様々な議論がある。RFC 2822 では過去に付いていたものを次々と追加していく仕様なので、過去に参照した msg-id がすべて付くようになる。しかし、スレッドが長く続くと、"References" が非常に膨らみよくないという意見もある。すべての msg-id を付けるか、msg-id の個数を制限するかは実装者の判断に委ねることになる（使用者の判断にまかせる実装もある）。

------------------------------------------------------------------------

滝澤 隆史(TAKIZAWA Takashi)
<taki@cyber.email.ne.jp>
