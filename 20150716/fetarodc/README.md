### MongoDB 3.0のダウンロード

MongoDB公式サイトから環境に合ったMongoDB 3.0のZip用バイナリをダウンロードしておいてください。以下のリンクからも落とせます。

* [64bit Windows用MongoDB 3.0.4(Zip版)](https://fastdl.mongodb.org/win32/mongodb-win32-x86_64-3.0.4.zip)
* [64bit MacOSX用MongoDB 3.0.4(Zip版)](https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-3.0.4.tgz)
* [64bit Linux用MongoDB 3.0.4(Zip版)](https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.4.tgz)

### MongoDB 3.0のインストール

1. zipを解凍
```
(MongoDBを解凍したディレクトリ)
└bin
 ├ mongod #MongoDB本体
 ├ mongo  #MongoDBクライアント
 
```

2. データディレクトリの作成

```
cd (MongoDBを解凍したディレクトリ)
mkdir data
```

### MongoDB 3.0の起動

MongoDB 3.0を新しいストレージエンジンのWiredTigerで起動する。
新しいストレージエンジンの方が90%近くディスク使用量を削減できるのでオススメです。

Windowsの場合

```
bin\mongod --dbpath data --nojournal --storageEngine wiredTiger
```

Linux, MacOSXの場合

```
bin/mongod --dbpath data --nojournal --storageEngine wiredTiger
```

` waiting for connections on port 27017 `と出れば成功


オプションの説明
* --dbpath : データディレクトリの場所.指定しないと`/data/db`や`c:\data\db`を利用する。
* --nojournal : ディスク先行書き込み(journal)を無効にする。これをしないとデータ容量を食います。
* --storageEngine : ストレージエンジンの指定 mmapv1 と wiredTiger を選択できる。指定しないと従来の`mmapv1`になります。

### MongoDBへの接続

もう一つコンソールを立ち上げて、MongoDBに接続する。

Windowsの場合

```
cd (MongoDBを解凍したディレクトリ)
bin\mongo
```

Linux, MacOSXの場合

```
cd (MongoDBを解凍したディレクトリ)
bin/mongo
```

以下のようにコマンド待ち受けになれば成功

```
MongoDB shell version: 3.0.4
connecting to: test
> 
```

### MongoDBのデータ構造

```
プロセス(mongod)
└データベース
　└コレクション
　　└ドキュメント(JSON)
```

### データ定義 DDL

データベース一覧を参照する

```
> show dbs
```

データベースを選択/作成する 
MongoDBのデータベースは選択するだけでは作成されません。コレクションへ最初のドキュメントをinsertしたタイミングで作成されます。

```
> use mydb
```

コレクションを一覧を参照する
```
> show collections
もしくは
> show tables
```

### データ操作 (DML)

#### INSERT

データを挿入します。
対応するSQLは `INSERT INTO mycol VALUES(...)`です。

```
> use mydb
> db.mycol.insert({a:1})

WriteResult({ "nInserted" : 1 }) //これが出れば成功。
```

```
> db.mycol.insert({"created_at":new Date()}) //関数が使えます
> for(var i=1; i<=20; i++) db.mycol.insert({"stock":i}) //for文も使えます
```

豆知識：mongo shellはbashと同じキーバインドです。

#### SELECT

データの件数をカウントします。
対応するSQLは `SELECT count(*) FROM mycol` です。

```
> db.mycol.count()
```

データを選択します。
対応するSQLは`SELECT * FROM mycol`です。

```
> db.mycol.find()
```

`Type "it" for more`と表示されたら

```
> it
```
とうつと、次が表示されます。

表示件数の制限

`SELECT * FROM mycol limit 1`

```
> db.mycol.find().limit(1)
```

射影します。

`SELECT _id FROM mycol`
```
> db.mycol.find({},{"_id":1})  
> db.mycol.find({},{"created_at":1}) //_id フィールドは常に表示される  
> db.mycol.find({},{"_id":0,"created_at":1}) //0で非表示に  
```

条件をつけて検索します。
`SELECT _id FROM mycol WHERE stock = 10`
```
> db.mycol.find({"stock":10}, {"_id":1})
```

数値の範囲を条件とします
`SELECT _id FROM mycol WHERE stock > 10`
```
> db.mycol.find({ "stock": { $gt:  10 } }, { "_id": 1 })
```


### UPDATE

`UPDATE mycol SET stock = 11 WHERE stock = 10`
```
> db.mycol.update({"stock":10},{$set:{"stock":11}}) //$setがないと他のフィールドが消えてしまうので注意
```

_idが存在すればupdate、存在しなければinsert
```
> db.mycol.save({"_id":ObjectId("xxxx"),"stock":20})
```

### DELETE

`DELETE FROM mycol WHERE stock = 11`

```
> db.mycol.remove({"stock":11})
```

## Mongo Shell ならではのコマンド

### findOne()

ドキュメントを１件を取得

```
> db.mycol.findOne()
```

### findOne()とfind().limit(1)の違い

find()はカーソルが返却され、findOne()はドキュメントそのものが返却されます

```
> doc1 = db.mycol.find().limit(1) // -> DBのカーソルが返却される
> doc1

> doc2 = db.mycol.findOne() // -> JSONが返却される
> doc2
```

find()メソッドの戻り値はカーソルです。
カーソルは検索結果の位置を示すものです。
例えば100万件あるときにfind()して100万件全件帰ってくると、性能が劣化します。
MongoDBではデフォルトでは20件づつデータを取ってきます。
`it`をうつとカーソルが進み、次の20件をとりに行きます。

find()で20件以上取得したい場合は以下のようにします。
```
> DBQuery.shellBatchSize = 300

```

手っ取り早く全件表示したい場合は.toArray()をつけます。
```
> db.mycol.find().toArray()
```

### cursol.forEach

検索結果の中身を関数で処理します
```
> db.team.insert({ name : "watanabe", age : 32 })
> db.team.insert({ name : "kitazawa", age : 28 })
> db.team.insert({ name : "hayashida", age : 30 })
> db.team.find()
> db.team.find().forEach( function(doc) { print( "name is " + doc.name ); } );
```

### cursol.map

検索結果の中身を関数で評価し、配列にして返却します
```
> db.team.find().map( function(doc) { return doc.age } )
```

### mongoshell はjavascript
forやfunctionやtoArray()でピンときた人はきたでしょう。

Mongo shellはjavascriptです。

```
> 1 + 1
> var doc = {a:3}
> db.hoge.insert(doc)
```

javascriptでは()をつけずに関数を実行すると関数そのものが観れます。
```
> db.mycol.find
```

## 複雑なドキュメントを入れてみる


## 集計してみる

[公式のサンプル](http://docs.mongodb.org/manual/tutorial/aggregation-zip-code-data-set/)を利用して、集計を試してみる。
まず、以下の元データをダウンロード。

```
wget http://media.mongodb.org/zips.json
````

mongoimportコマンドでインポートする

```
# bin/mongoimport zips.json
2015-07-14T23:20:14.649+0900	no collection specified
2015-07-14T23:20:14.650+0900	using filename 'zips' as collection
2015-07-14T23:20:14.660+0900	connected to: localhost
2015-07-14T23:20:15.735+0900	imported 29353 documents
```

```
> db.zips.count()
29353
> db.zips.find()
```

```
db.zips.aggregate( [
   { $group: { _id: "$state", totalPop: { $sum: "$pop" } } },
   { $match: { totalPop: { $gte: 10*1000*1000 } } }
] )

{ "_id" : "CA", "totalPop" : 29754890 }
{ "_id" : "TX", "totalPop" : 16984601 }
{ "_id" : "FL", "totalPop" : 12686644 }
{ "_id" : "PA", "totalPop" : 11881643 }
{ "_id" : "OH", "totalPop" : 10846517 }
{ "_id" : "IL", "totalPop" : 11427576 }
{ "_id" : "NY", "totalPop" : 17990402 }
```

```
SELECT state, SUM(pop) AS totalPop
FROM zipcodes
GROUP BY state
HAVING totalPop >= (10*1000*1000)
```
