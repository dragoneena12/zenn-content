---
title: "PostgreSQLの実行計画を読んでパフォーマンスチューニングする"
emoji: "🔭"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["PostgreSQL"]
published: false
publication_name: tokium_dev
---

## はじめに
こんにちは、Lapi（[@dragoneena12](https://github.com/dragoneena12)）です。

最近は株式会社TOKIUMに縁あって入社することになり、Go言語を使ったアプリケーション開発に携わらせていただいてます。

そんなわけで僕のエンジニア人生で初めて大規模なDBを触ることとなったのですが、最初**パフォーマンスが悪すぎて全然クエリが終わらない**みたいな状況になってしまいました。それから頑張ってパフォーマンス改善をするという経験ができたので、この記事ではPostgreSQLの実行計画の読み方および実際のパフォーマンスチューニングの事例について紹介していきたいと思います。

## 実行計画の読み方

今回サンプルデータを用意してみたので、やってみたい方は手元で実行してみてください。

```console
docker run --rm --name sample-postgres -it -v $(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql -d postgres
docker exec -it sample-postgres psql -U postgress
```
