MongoDB 2.2.0 新機能紹介
=================
#コンテンツ
- 並列処理の強化（DBのレベルロック、PageFaultアーキテクチャの改善）
- Aggregation Framework
- Readに関する設定
- Tagを使用したShardingが可能に
- TTL(Time To Live) Collections
- その他

出所:[New Features in 2.2](http://kumoya.com/wordpress/wp-content/uploads/2012/09/New-Features-2.2.0.pdf)


## 並列処理の強化

### DBレベルのロック
Globalロックを排除し、DBレベルのロックへ 

![DB Lock](http://www.fedc.biz/~fujisaki/img/db_lock.jpg)  
出所:[MongoDBの開発元、サンフランシスコの10gen社のエリックさんにインタビューしてきました](http://enterprisezine.jp/dbonline/detail/4177)


今後、ロックの粒度を細かくして行く予定  
[collection level locking](https://jira.mongodb.org/browse/SERVER-1240)はチケットがある、リリースバージョンは未定  
ロックの状態は以下のコマンドで確認可能  
```
currentOp()
serverStatus()
```

### Page faultアーキテクチャの改善
ロック中にPageFaultが発生することを避ける仕組み
```
If 書き込みオペレーションで、  
・アクセス先がメモリ上になくて、mutationが起こりそうで  
・Page faultしようとしている時  
Then  
・PageFaultEceptionを発生させます  
・ロックを解除して、pageをメモリに読み込み
・書き込みオペレーションを再実行  
```
![concurrency-internals-mongodb-2-2](http://www.fedc.biz/~fujisaki/img/concurrency-internals-mongodb-2-2.png)  
参考：[MongoDB Concurrency Internals in v2.2](http://www.slideshare.net/mongodb/mongosf-mongodb-concurrency-internals-in-v22)  
書き込みオペレーションで、PageFaultが発生することが分かってる場合は、ロックする前にPageFaultExceptionを発生させてオペレーションを実行  
参考：[MongoDB v2.2に含まれる予定のConcurrency改善](http://d.hatena.ne.jp/matsukaz/20120528/1338201757)  
同一コレクション内の同時実効性(特にupdate?)が向上  
参考：[Goodbye global lock – MongoDB 2.0 vs 2.2](http://blog.serverdensity.com/goodbye-global-lock-mongodb-2-0-vs-2-2/)


## Aggregation Framework

SQLでいう、GROUP BY機能に似たもの。

<pre>
Aggregation Frameworkは保存されたデータに対しさまざまな処理や操作を行うもので、
従来はJavaScriptで実装していたような集計処理をMongoDBにコマンドを発行することで
実行できるようになる
</pre>
出所: [「MongoDB 2.2」リリース、データの集計・操作機構など多数の新機能を追加](http://sourceforge.jp/magazine/12/08/30/0423241)より引用

```
- $match    //集計処理を行う条件を指定する（SQLのHAVING区）
- $project  //集計処理を行うフィールドの選択/除外、リネーム（SQLのAS区）、計算結果のinsertを行える
- $unwind   //配列を引数にとり、展開して返す
- $group    //$sum, $avgなどを使い集計処理を実施する
- $sort     //sortキーを指定
- $skip     //数字を引数にとり、数字分スキップする
- $limit    //数字を引数にとり、数字分の集計結果を返す
```

[Aggregation Framework Reference -MongoDB マニュアル- ](http://docs.mongodb.org/manual/reference/aggregation/)

$projectの例
```
```

$unwindの例
```
```

![Aggregation Framework](http://www.fedc.biz/~fujisaki/img/af01.png)  
出所:[New Features in 2.2](http://kumoya.com/wordpress/wp-content/uploads/2012/09/New-Features-2.2.0.pdf)

sample document
```js
> use classdb
> year = ["freshman", "junior", "senior"];
> for(var i=1; i<=100; i++) db.scores.insert({"name":"quiz","score":Math.floor(Math.random()*100+1),"student":i,"year":year[Math.floor(Math.random()*year.length)]})
> db.scores.findOne()
{ 
  "_id" : ObjectId("5029e745a0988a275aefd0c0"),
  "name" : "quiz",	
  "score"	:	99,	
  "student"	:	7,	
  "year"	:	"junior"
}

```

集計処理
```js
>db.scores.aggregate(  { $match   : { "year"  : "junior" } },
                       { $project : { "name"  : 1, "score" : 1 } },
                       { $group   : { "_id"     : "$name", 
                                      "average" : {"$avg" : "$score" } } }
)

{
 "result" : [
		{
			"_id" : "quiz",
			"average" : 65.41666666666667
		}
	],
	"ok" : 1
}

```

SQLで同じ処理
```SQL
SELECT name, AVG(score) FROM scores
GROUP BY name
HAVING year = 'junior' 
```

## Readに関する設定

### Read時のConsistency強度を指定可能に
- PRIMARY
- PRIMARY PREFERRED
- SECONDARY
- SECONDARY PREFERRED
- NEAREST  
![StrongConsistency](http://www.fedc.biz/~fujisaki/img/StrongConsistency.png)  
![EventualConsistency](http://www.fedc.biz/~fujisaki/img/EventualConsistency.png)  
出所:[New Features in 2.2](http://kumoya.com/wordpress/wp-content/uploads/2012/09/New-Features-2.2.0.pdf)

Rubyでの例
```ruby
@collection.find({:doc => 'foo'}, :read => :primary)    # read from primary only
@collection.find({:doc => 'foo'}, :read => :secondary)  # read from secondaries only
```
出所:[Read Preference in Ruby](http://api.mongodb.org/ruby/1.7.0.rc0/file.READ_PREFERENCE.html)


### ドライバが一定間隔でpingを発行



## Tagを使用したShardingが可能に

###Tagベースでのレンジパーティション
uid=1〜100は東京データセンターのノード、uid=100〜200はNewYorkデータセンターのノード、という設定が可能に

```js
sh.addShardTag(shard, tag)
sh.addTagRange(namespace, minimum, maximum, tag)
sh.removeShardTag(shard, tag)

//例
sh.addShardTag("shard0000", "TokyoDC")
sh.addShardTag("shard0001", "NewYorkDC")
sh.addTagRange("logdb.logs", { "uid" : 1   }, { "uid" : 100 }, "TokyoDC")
sh.addTagRange("logdb.logs", { "uid" : 100 }, { "uid" : 200 }, "NewYorkDC")
```

## TTL(Time To Live) Collections
コレクションから期限切れデータを削除する

## その他

### Windows XPのサポート終了

### すべてのドライバ及びShardingインタフェース間の読み込み設定の標準化

### mongodumpやmongorestoreといった各ツールの改良

## 参考リンク
- [Release Notes for MongoDB 2.2](http://docs.mongodb.org/manual/release-notes/2.2/)
- [MongoDB 2.2 At the Silicon Valley MongoDB User Group](http://sssslide.com/speakerdeck.com/u/mongodb/p/mongodb-2-dot-2-at-the-silicon-valley-mongodb-user-group)  
- [「MongoDB 2.2」リリース、データの集計・操作機構など多数の新機能を追加 -sourceforge- ](http://sourceforge.jp/magazine/12/08/30/0423241)
- [MongoDB 2.2登場 - パフォーマンスや柔軟性を強化 -マイナビニュース- ](http://news.mynavi.jp/news/2012/09/03/010/index.html)
- [MongoDB 2.2 Aggregation Framework -IIJの最新技術- ](http://www.iij.ad.jp/company/development/tech/activities/mongodb/index.html)
- [MongoDB v2.2に含まれる予定のConcurrency改善 -matsukazの日記- ](http://d.hatena.ne.jp/matsukaz/20120528/1338201757)