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

### サンプルデータの用意

今回サンプルデータを用意してみたので、やってみたい方は手元で実行してみてください。

```console
docker run --rm --name sample-postgres -it -v $(pwd)/sample1.sql:/docker-entrypoint-initdb.d/sample1.sql -e POSTGRES_PASSWORD=password -d postgres
docker exec -it sample-postgres psql -U postgres
```

今回のサンプルデータは以下のようなテーブル構成になっています。

```mermaid
erDiagram
    users {
        UUID id PK
        TEXT name
        TEXT email
    }
    
    tickets {
        UUID id PK
        TEXT title
        TEXT assignee
        TEXT assignee_type
    }
    
    users ||--o{ tickets : "assignee (when type=user)"
```

ticketsテーブルはassignee_typeが'user'の場合はusersテーブルを、'name'の場合は直接名前を格納します。

これはいわゆるポリモーフィック関連というパターンで、SQLアンチパターン6章にも取り上げられているとおり基本的にはアンチパターンとされています。このパターンを採用したときにSQLやパフォーマンスがどのようになるかみていきましょう。

### パフォーマンスを測定してみる

まず、ticketsの情報をassigneeの名前と一緒に表示するクエリを実行してみましょう。
このクエリでは、assignee_typeに応じて適切なテーブルと結合し、COALESCEを使って名前を取得しています。
クエリの先頭にEXPLAIN句をつけることで、実行計画を取得することができます、

```sql
EXPLAIN SELECT 
    t.id,
    t.title,
    t.assignee_type,
    CASE 
        WHEN t.assignee_type = 'user' THEN u.name
        WHEN t.assignee_type = 'name' THEN t.assignee
    END AS assignee_name
FROM tickets t
LEFT JOIN users u ON t.assignee_type = 'user' AND t.assignee = u.id::TEXT
WHERE t.id = '00000000-0000-0002-0000-000000012345';
                                               QUERY PLAN                                               
--------------------------------------------------------------------------------------------------------
 Hash Right Join  (cost=8.32..2143.57 rows=1 width=112)
   Hash Cond: ((u.id)::text = t.assignee)
   Join Filter: (t.assignee_type = 'user'::text)
   ->  Seq Scan on users u  (cost=0.00..1636.00 rows=100000 width=48)
   ->  Hash  (cost=8.30..8.30 rows=1 width=80)
         ->  Index Scan using tickets_pkey on tickets t  (cost=0.29..8.30 rows=1 width=80)
               Index Cond: (id = '00000000-0000-0002-0000-000000012345'::uuid)
```

いろいろな処理が書かれていますが、ここではusersテーブルに対して全件走査（Seq Scan）がかかっている部分に着目します。

```sql
   Hash Cond: ((u.id)::text = t.assignee)
   Join Filter: (t.assignee_type = 'user'::text)
   ->  Seq Scan on users u  (cost=0.00..1636.00 rows=100000 width=48)
```

usersテーブルはサイズが大きいため、全件走査はかなりのパフォーマンス低下につながってしまいます。usersテーブルのIDは主キーのため、本来はindexを使った高速な取得が可能なはずです。しかしticketsテーブルのassignee列はTEXT型となっており、usersテーブルのIDを比較するにはまずTEXT型へとキャストする必要があります。このためindexが使えなくなっているのが大きな原因です。


