### MongoDBのダウンロード

MongoDB公式サイトから環境に合ったMongoDB 3.0のZip用バイナリをダウンロードしておいてください。以下のリンクからも落とせます。

* [64bit Windows用MongoDB 3.0.4(Zip版)](https://fastdl.mongodb.org/win32/mongodb-win32-x86_64-3.0.4.zip)
* [64bit MacOSX用MongoDB 3.0.4(Zip版)](https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-3.0.4.tgz)
* [64bit Linux用MongoDB 3.0.4(Zip版)](https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.4.tgz)

### MongoDBのインストール

1. zipを解凍
```
$MONGO_HOME
└bin
 ├ mongod MongoDB本体
 ├ mongo MongoDBクライアント
```

2. データディレクトリの作成

```
cd $MONGO_HOME
mkdir data
```

### MongoDBの起動

Windowsの場合

```
cd $MONGO_HOME
bin\mongod --dbpath data --nojournal --storageEngine wiredTiger
```

Linux, MacOSXの場合

```
cd $MONGO_HOME
bin/mongod --dbpath data --nojournal --storageEngine wiredTiger
```

` waiting for connections on port 27017 `と出れば成功


オプションの説明
* --dbpath : データディレクトリの場所.指定しないと`/data/db`や`c:\data\db`を利用する。
* --nojournal : ディスク先行書き込み(journal)を無効にする。これをしないとデータ容量を食います。
* --storageEngine : ストレージエンジンの指定 mmapv1 と wiredTiger を選択できる。指定しないと従来の`mmapv1`になります。

### MongoDBへの接続

もう一つコンソールを立ち上げる

Windowsの場合

```
cd $MONGO_HOME
bin\mongo
```

Linux, MacOSXの場合

```
cd $MONGO_HOME
bin/mongo
```


```
MongoDB shell version: 3.0.4
connecting to: test
> 　←これが出れば成功
```

### MongoDBのデータ構造

```
プロセス(mongod)
└データベース
　└コレクション
　　└ドキュメント(JSON)
```

### データ定義 DDL
* データベース一覧を参照する
```
> show dbs
```

* データベースを選択/作成する  
MongoDBのデータベースは選択するだけでは作成されません。コレクションへ最初のドキュメントをinsertしたタイミングで作成されます。
```
> use mydb
```

* データベースを削除する 
```
> use mydb
> db.dropDatabase()
```

* コレクションを一覧を参照する
```
> show collections
もしくは
> show tables
```

### データ操作 DML
#### INSERT

`SQL: INSERT INTO{table_name} VALUES(...)`

```
> use mydb
> db.mycol.insert({a:1})
> db.mycol.insert({"created_at":new Date()})
> db["mycol"].insert({b:1}) //こんな書き方もできます 
> for(var i=1; i<=20; i++) db.mycol.insert({"stock":i}) //for文も使えます
```


#### SELECT

`SQL: SELECT count(*) FROM mycol`

```
> db.mycol.count()
```

`SQL: SELECT * FROM mycol`

```
> db.mycol.find()
```

has more と表示されたら
```
> it //iterator
```

find()で20件以上表示させたい
```
> DBQuery.shellBatchSize = 300
もしくは
> db.mycol.find().toArray()
> db.mycol.find().toArray().forEach(printjsononeline)
```


1件表示

SQL: SELECT * FROM mycol limit 1

```
> db.mycol.findOne()
```

厳密には、一件表示させるだけでなく、データそのものを取得している。

```
> a = db.mycol.find() // -> DBのカーソルが返却される
> a
> a
> b = db.mycol.findOne() // -> JSONが返却される
> b
```

`SQL: SELECT * FROM mycol limit 5`

```
> db.mycol.find().limit(5)
```

`SQL: SELECT _id FROM mycol`
```
> db.mycol.find({},{"_id":1})  
> db.mycol.find({},{"created_at":1}) //_id フィールドは常に表示される  
> db.mycol.find({},{"_id":0,"created_at":1}) //0で非表示に  
```

`SQL: SELECT _id FROM where stock = 10`
```
> db.mycol.find({"stock":10}, {"_id":1})
```

`SQL: SELECT _id FROM where stock {>, <, >=, <=} 10`
```
> db.mycol.find({ "stock": { $gt:  10 } }, { "_id": 1 })
> db.mycol.find({ "stock": { $lt:  10 } }, { "_id": 1 })
> db.mycol.find({ "stock": { $gte: 10 } }, { "_id": 1 })
> db.mycol.find({ "stock": { $lte: 10 } }, { "_id": 1 })
```

JSON形式で表示
```
> db.mycol.find().forEach(printjson)
> db.mycol.find().forEach(printjsononeline)
```


toArray
```
> db.mycol.find().toArray()
```

ちょっと脱線 

複雑なドキュメントを入れてみる

MongoShellはjavascriptである

ハッシュであるdbのキー一覧を表示してみる
```
> for(var k in db) print(k)
> //versionというキーあり、呼んでみる
> db.version
> db.version()
```




### UPDATE

`SQL: update mycol set stock = 11 where stock = 10`
```
> db.mycol.update({"stock":10},{$set:{"stock":11}}) //$setがないと他のフィールドが消えてしまうので注意
```

`_idが存在すればupdate、存在しなければinsert`
```
> db.mycol.save({"_id":ObjectId("xxxx"),"stock":20})
```

### DELETE
`SQL: delete FROM mycol where stock = 11`

```
> db.mycol.remove({"stock":11})
```

## INDEX
* INDEX参照
```
> db.system.indexes.find()
```

* INDEX作成
```
> db.mycol.ensureIndex({"stock":1})
```

* INDEX削除
```
> db.mycol.dropIndex({"stock":1})  
> db.mycol.dropIndexes() //全て削除  
```

##参考サイト

* [SQL脳に優しいMongoDBクエリー入門](http://d.hatena.ne.jp/taka512/20110220/1298195574)  
* [MongoDB公式マニュアル チュートリアル](http://www.mongodb.org/pages/viewpage.action?pageId=5079135)  
* [MongoDB公式マニュアル 高度なクエリー](http://www.mongodb.org/pages/viewpage.action?pageId=6029357)  
* [MongoDB公式マニュアル インデックス](http://www.mongodb.org/pages/viewpage.action?pageId=5800049)
* [MongoDBでゆるふわDB体験](http://gihyo.jp/dev/serial/01/mongodb) [第3回　MongoDBのクエリを使いこなそう](http://gihyo.jp/dev/serial/01/mongodb/0003)
