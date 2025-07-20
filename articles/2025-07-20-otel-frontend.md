---
title: "Opentelemetryでフロントエンドのトレースを取得する"
emoji: "😽"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Opentelemetry", "Tracing", "Frontend", "React"]
published: false
---

## はじめに
こんにちは、Lapi（[@dragoneena12](https://github.com/dragoneena12)）です。

趣味で制作しているwebアプリケーションのパフォーマンス改善のため、Opentelemetryでフロントエンドのトレーシングをしてみました。

あまりOtelを使ったフロントエンドのトレースについての記事がなかったので参考になると幸いです。

## Otelを使ったフロントエンドトレーシングについて

https://opentelemetry.io/docs/languages/js/getting-started/browser/

基本的には上記の公式ドキュメントに書いてあります。まだExperimental扱いなのでご利用の際はご注意ください。

現時点で利用できる自動計装としては以下があります（[参考](https://www.npmjs.com/package/@opentelemetry/auto-instrumentations-web)）。今回は `@opentelemetry/instrumentation-fetch` を利用してみました。

- [@opentelemetry/instrumentation-document-load](https://github.com/open-telemetry/opentelemetry-js-contrib/tree/main/packages/instrumentation-document-load)
- [@opentelemetry/instrumentation-fetch](https://github.com/open-telemetry/opentelemetry-js/tree/main/experimental/packages/opentelemetry-instrumentation-fetch)
- [@opentelemetry/instrumentation-user-interaction](https://github.com/open-telemetry/opentelemetry-js-contrib/tree/main/packages/instrumentation-user-interaction)
- [@opentelemetry/instrumentation-xml-http-request](https://github.com/open-telemetry/opentelemetry-js/tree/main/experimental/packages/opentelemetry-instrumentation-xml-http-request)

また今回はExporterとして `@opentelemetry/exporter-trace-otlp-http` を利用し、実際にtrace spanをotel collectorに送信してみます。

https://www.npmjs.com/package/@opentelemetry/exporter-trace-otlp-http

## 実装

以下の依存パッケージをインストールします

```console
npm i @opentelemetry/sdk-trace-web \
@opentelemetry/instrumentation-fetch \
@opentelemetry/context-zone \
@opentelemetry/instrumentation \
@opentelemetry/exporter-trace-otlp-http \
@opentelemetry/resources \
@opentelemetry/semantic-conventions \
```

以下のようにトレース用のコードを作成し、コードの適当な箇所でimportします。

```ts
import {
  BatchSpanProcessor,
  WebTracerProvider,
} from "@opentelemetry/sdk-trace-web";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { FetchInstrumentation } from "@opentelemetry/instrumentation-fetch";
import { ZoneContextManager } from "@opentelemetry/context-zone";
import { registerInstrumentations } from "@opentelemetry/instrumentation";
import { resourceFromAttributes } from '@opentelemetry/resources';
import { ATTR_SERVICE_NAME } from "@opentelemetry/semantic-conventions";

const resource = resourceFromAttributes({
  [ATTR_SERVICE_NAME]: "my-app",
});

const provider = new WebTracerProvider({
  resource,
  spanProcessors: [
    new BatchSpanProcessor(
      new OTLPTraceExporter({
        url: "https://<your-otlp-collector-url>/v1/traces", // URLはオプションで省略可能 - デフォルトは http://localhost:4318/v1/traces
        headers: {}, // 各リクエストで送信するカスタムヘッダーを含むオプションのオブジェクト
        concurrencyLimit: 10, // 保留中のリクエストに対するオプションの制限
      }),
      {
        // 最大キューサイズ。サイズに達した後、スパンは破棄されます。
        maxQueueSize: 100,
        // 各エクスポートの最大バッチサイズ。maxQueueSize以下である必要があります。
        maxExportBatchSize: 10,
        // 2つの連続したエクスポート間の間隔
        scheduledDelayMillis: 500,
        // エクスポートがキャンセルされるまでの実行可能時間
        exportTimeoutMillis: 30000,
      }
    ),
  ],
});

provider.register({
  contextManager: new ZoneContextManager(),
});

registerInstrumentations({
  instrumentations: [new FetchInstrumentation()],
});
```

以上が揃ったらアプリケーションを実行すると、fetchについてのtraceが取れるようになるはずです。今回はjaegerを使って可視化してみました。リクエストについての基本的な情報のほか、レスポンスが返ってくるまでにかかった時間などについても見ることができます。

![jaegerを使って可視化したトレース](/images/2025-07-20-otel-frontend-1.png)

## まとめ

今回はOtelを使ってフロントエンドのトレースを取得する手順を簡単に紹介してみました。思ったより簡単に導入できて、フロントエンドパフォーマンスを測る上で便利そうなほか、バックエンドと合わせた分散トレーシング計測がとても強力そうに思えました。気になった方はぜひこの手順を参考に実装してみてください！

また、Otelのリポジトリを覗きにいくと本記事で紹介した以外にもいろいろ面白そうなパッケージがあるので、ぜひ覗いてみてください。

https://github.com/open-telemetry/opentelemetry-js/tree/main/experimental/packages
https://github.com/open-telemetry/opentelemetry-js/tree/main/packages/opentelemetry-sdk-trace-base

## 参考文献

- [OpenTelemetryのClient instrumentation for the browserを試した](https://zenn.dev/hosht/articles/9ed87b98941107)
- https://opentelemetry.io/docs/languages/js/getting-started/browser/
