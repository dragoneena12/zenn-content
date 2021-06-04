---
title: "pquerna/otpを使いGoでワンタイムパスワード認証するチュートリアル"
emoji: "🗂"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go"]
published: false
---
# はじめに
こんにちは、Lapi（[@dragoneena12](https://github.com/dragoneena12)）です。

趣味でGoを使って作成しているサービスでワンタイムパスワード（OTP）を実装したので、備忘録がてらチュートリアル形式でやり方を書いておこうと思います。是非参考にしてOTPを組み込んだシステム作って遊んでもらえるとうれしいです！

# OTPとは？
いろんなサービスの多要素認証（MFA）やGoogle Authenticatorなんかでおなじみの人も多いであろう6桁の数字が表示される一時的なパスワードです。HOTPやTOTPといった種類があるのですが、詳しくは [この記事](https://note.com/murakmii/n/n64b6d346172a) が分かりやすいです。結構単純な仕組みになっています。

今回のチュートリアルではTOTPを使っていこうと思います。


