---
title: "pquerna/otpを使いGoでワンタイムパスワード認証するチュートリアル"
emoji: "🦆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go", "OTP"]
published: true
---
# はじめに
こんにちは、Lapi（[@dragoneena12](https://github.com/dragoneena12)）です。

趣味でGoを使って作成しているサービスでワンタイムパスワード（OTP）を実装したので、備忘録がてらやり方を書いておこうと思います。結構簡単に作れるので、OTPを組み込んだシステム作って遊んでみてください！

バージョン情報
- Go v1.16.4
- pquerna/otp v1.3.0

# OTPとは？
いろんなサービスの多要素認証（MFA）やGoogle Authenticatorなんかでおなじみの人も多いであろう6桁の数字が表示される一時的なパスワードです。HOTPやTOTPといった種類があるのですが、詳しくは [この記事](https://note.com/murakmii/n/n64b6d346172a) が分かりやすいです。結構単純な仕組みになっています。

今回のチュートリアルではTOTPを使っていこうと思います。最終的なソースコードは下記から見れます。

https://github.com/dragoneena12/go-otp-example

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
まず `totp.Generate()` でTOTP Keyを生成します。
```go
key, err := totp.Generate(totp.GenerateOpts{
		Issuer:      "Example.com",       // OTPを発行する組織・企業名。必須。
		AccountName: "alice@example.com", // OTP発行先のアカウント名。必須。
		Period:      30,                  // TOTPハッシュが有効な時間（秒）。デフォルトでは30秒。
		SecretSize:  20,                  // 生成されるSecretのバイト長。デフォルトでは20バイト。
		Secret:      []byte{},            // Secretとして用いるバイト列。デフォルトではempty。
		Digits:      otp.DigitsSix,       // 生成されるTOTPハッシュの桁数。デフォルトでは6桁。
		Algorithm:   otp.AlgorithmSHA1,   // HMACに用いるハッシュアルゴリズム。デフォルトではSHA1。
		Rand:        rand.Reader,         // Secret生成に用いる乱数生成io.Reader。デフォルトではrand.Reader。
	})
```

次に `key.Image()` でGoogleAuthenticatorなどに登録するためのQRコード画像を生成します。内部処理的には `key.orig` をQRコード化しているだけなので、フロントエンドが分かれている場合などは`key.String()` などで取得して別途QRコードを生成しても良さそうです。

```go
img, _ := key.Image(200, 200) // 引数は画像の幅・高さ
os.Create("qrcode.png")
png.Encode(f, img);
```

生成されたQRコードをGoogleAuthenticatorなどのOTPアプリで読み取り、実際に認証をしてみます。認証は `totp.Validate()` に入力とsecretを与えることでできます。

```go
var passcode string
fmt.Println("input one time password:")
fmt.Scanf("%s", &passcode)
valid := totp.Validate(passcode, key.Secret())

if valid {
	fmt.Println("Authorization succeed!")
	// 認証がうまくいったのでsecret情報を保存する。以降のログインはこれを読み出して利用。
	ioutil.WriteFile("secret.key", []byte(key.Secret()), 0600)
} else {
	fmt.Println("Access denied")
}
```

以上で簡単なOTP認証を実装できました！

# 備考
Google AuthenticatorではSHA-1, 6桁, 有効時間30秒の初期設定でしか正しく動作しない場合があるそうです。基本的な設定で利用するのが無難かもしれません。

参考：
- [TOTP 認証を提供する際に考慮すべき otpauth URI のフォーマット](https://lab.tricorn.co.jp/uzuki/5129)
- [pquerna/otp/issues/55](https://github.com/pquerna/otp/issues/55)
