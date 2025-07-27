---
title: SpamAssassin Milter Plugin
---

このページは[SpamAssassin Milter Plugin](http://savannah.nongnu.org/projects/spamass-milt/)についての情報を提供するかも知れないページです。

## SpamAssassin Milter Pluginとは

SpamAssassin Milter PluginとはSpamAssassinをsendmailやPostfixのMilterから利用するためのプラグインです。

## ClamAV Plugin対応パッチ

このパッチは次のことを行います。

- SpamAssassinで[ClamAV Plugin](https://cwiki.apache.org/confluence/display/spamassassin/ClamAVPlugin)を利用しているときに、判定結果のヘッダX-Spam-Virusを挿入する。
- X-Spam-\*ヘッダの挿入をヘッダの末尾ではなく先頭にするように変更する。

### パッチ

- [spamass-milter-0.3.1-clamav_plugin.patch](spamass-milter/spamass-milter-0.3.1-clamav_plugin.patch)

### RHEL/CentOS/Fedora用SRPM

かつて提供されていたRPMForge(Dag Wieers)のSRPMを修正したものです。

- [spamass-milter-0.3.1-2.rf.src.rpm](spamass-milter/spamass-milter-0.3.1-2.rf.src.rpm)
