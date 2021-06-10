---
title: "WSL2 から Vagrant-Virtualbox を動かす"
emoji: "🦆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["WSL2", "Vagrant", "VirtualBox"]
published: true
---

# はじめに

こんにちは、Lapi（[@dragoneena12](https://github.com/dragoneena12)）です。

Vagrant-Virtualbox を WSL2 から動かしたいなと思ったのですが、意外としっかりした情報がなくて若干詰まったので大事なことだけまとめておきます。

WSL2 環境がある前提です。

# 1. Vagrant のインストール

Windows と WSL2 の両方に同じバージョンの Vagrant をインストールする必要があります。

Windows は普通にインストーラから、WSL2 は Debian の項にある debian package を下記コマンドでインストールするのがオススメです。

```
$ dpkg -i vagrant_2.2.16_x86_64.deb
```

https://www.vagrantup.com/downloads

# 2. VirtualBox のインストール

Windows 側に普通にインストーラからインストールすれば OK です。

https://www.virtualbox.org/wiki/Downloads

# 3. 環境変数の設定

WSL2 の Vagrant が Windows の VirtualBox を使えるようにするため、以下の環境変数を設定してあげる必要があります。

`~/.bashrc` などに以下を記載

```sh
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
```

# 4. virtualbox_WSL2 プラグインのインストール

WSL2 の仕様上このままでは box への ssh がうまくいかないので、[virtualbox_WSL2](https://github.com/Karandash8/virtualbox_WSL2)というやつを入れてあげる必要があります。下記コマンドでインストールできます。

```
$ vagrant plugin install virtualbox_WSL2
```

以上で WSL2 上で Vagrant がつかえるようになるはずです！

# おわりに

意外とこれらが綺麗にまとまっているサイトがなくて苦労しました。何か追加でつまりポイントあったら教えていただけると幸いです。

参考：

- [Vagrant and Windows Subsystem for Linux](https://www.vagrantup.com/docs/other/wsl)
- [How to run Vagrant + VirtualBox on WSL 2 (2021)](https://blog.thenets.org/how-to-run-vagrant-on-wsl-2/)
- [Connection Refused in Vagrant using WSL 2](https://stackoverflow.com/questions/65001570/connection-refused-in-vagrant-using-wsl-2)
