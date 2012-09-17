MongoDB 2.2.0 新機能紹介
=================

出所:[New Features in 2.2](http://kumoya.com/wordpress/wp-content/uploads/2012/09/New-Features-2.2.0.pdf)


## 並列処理の強化

### DBレベルのロック
Globalロックを排除し、DBレベルのロックへ

### Page faultアーキテクチャの改善
update時にpage faultにロックを生成していた問題を修正  
=> 同一コレクション内の同時実効性(update?)が向上  
参考：[Goodbye global lock – MongoDB 2.0 vs 2.2](http://blog.serverdensity.com/goodbye-global-lock-mongodb-2-0-vs-2-2/)


## Readに関する設定

## Sharding, geo-shardingに関するTag機能の追加

## Aggregation Framework

<pre>
Aggregation Frameworkは保存されたデータに対しさまざまな処理や操作を行うもので、
従来はJavaScriptで実装していたような集計処理をMongoDBにコマンドを発行することで
実行できるようになる
</pre>
 [「MongoDB 2.2」リリース、データの集計・操作機構など多数の新機能を追加](http://sourceforge.jp/magazine/12/08/30/0423241)より引用

## TTL(Time To Live) Collections
コレクションから期限切れデータを削除する

## その他

### Windows XPのサポート終了

### すべてのドライバ及びShardingインタフェース間の読み込み設定の標準化

### mongodumpやmongorestoreといった各ツールの改良

## 参考リンク
- [Release Notes for MongoDB 2.2](http://docs.mongodb.org/manual/release-notes/2.2/)
- [「MongoDB 2.2」リリース、データの集計・操作機構など多数の新機能を追加 -sourceforge- ](http://sourceforge.jp/magazine/12/08/30/0423241)
- [MongoDB 2.2登場 - パフォーマンスや柔軟性を強化 -マイナビニュース- ](http://news.mynavi.jp/news/2012/09/03/010/index.html)
- [MongoDB 2.2 Aggregation Framework -IIJの最新技術- ](http://www.iij.ad.jp/company/development/tech/activities/mongodb/index.html)
- [MongoDB v2.2に含まれる予定のConcurrency改善 -matsukazの日記- ](http://d.hatena.ne.jp/matsukaz/20120528/1338201757)