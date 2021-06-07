---
title: "pquerna/otpを使いGoでワンタイムパスワード認証するチュートリアル"
emoji: "🗂"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go", "OTP"]
published: false
---
# はじめに
こんにちは、Lapi（[@dragoneena12](https://github.com/dragoneena12)）です。

趣味でGoを使って作成しているサービスでワンタイムパスワード（OTP）を実装したので、備忘録がてらチュートリアル形式でやり方を書いておこうと思います。是非参考にしてOTPを組み込んだシステム作って遊んでもらえるとうれしいです！

バージョン情報
- Go v1.16.4
- pquerna/otp v1.3.0

# OTPとは？
いろんなサービスの多要素認証（MFA）やGoogle Authenticatorなんかでおなじみの人も多いであろう6桁の数字が表示される一時的なパスワードです。HOTPやTOTPといった種類があるのですが、詳しくは [この記事](https://note.com/murakmii/n/n64b6d346172a) が分かりやすいです。結構単純な仕組みになっています。

今回のチュートリアルではTOTPを使っていこうと思います。

# インストール
まず新規のgoモジュールをセットアップします。

```
// go mod init github.com/<username>/<reponame>
go mod init github.com/dragoneena12/go-otp-example
```

goモジュールにTOTPライブラリ `pquerna/otp` をインストールします。

```
go get github.com/pquerna/otp
```

# TOTP Keyの生成と認証
まず `totp.GenerateOpts` でTOTP Keyを生成します。
```go
key, err := totp.Generate(totp.GenerateOpts{
		Issuer:      "Example.com",
		AccountName: "alice@example.com",
	})
```
