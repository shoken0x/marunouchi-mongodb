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

### CRUD

ドキュメントの挿入

```
db.col1.insert({a:1})
```

ドキュメントの検索

```
db.col1.find()
```

ドキュメントの更新

```
db.col1.update({},{$})
```



## DBS
* データベースを参照する // mysql> show databases
```
> show dbs
```

* データベースを選択/作成する // mysql> use {db_name}; create database {db_name}  
MongoDBのデータベースは、選択してコレクションへ最初のドキュメントをinsertしたタイミングで作成されます。
```
> use {db_name}
```

* データベースを削除する // mysql> drop database {db_name}
```
//useコマンドでデータベースを選択しておく    
> db.dropDatabase()
```

## COLLECTION
* コレクションを参照/作成する // mysql> show tables; create table {table_name}(...)
```
> show dbs  
> use {db_name}  
> show collections  //コレクションが何も表示されなかったら適当にinsertする  
> db.marunouchi.insert({"created_at":new Date()})  //現在時刻をinsert  
> show collections //marunouchiが見えますか？
```

* コレクションを削除する // mysql> drop table {table_name}
```
> show dbs  
> use {db_name}  
> show collections  
> db.marunouchi.drop({})  //コレクション全部を削除します  
> show collections //確認、marunouchiは削除された  
```

* コレクション内のデータを削除する // mysql> truncate table {table_name}
```
> db.marunouchi.insert({"created_at":new Date()})  
> show collections  
> db.marunouchi.remove() //コレクションの中のすべてのオブジェクトを削除します  
> show collections //確認、marunouchiはまだある  
```

* descコマンドはありません // mysql> desc {table_name}

## DOCUMENT
### INSERT
* mysql> insert into {table_name} values(...)
```
> use {db_name}
> db.marunouchi.insert({"created_at":new Date()})
> db["marunouchi"].insert({"created_at":new Date()}) //こんな書き方もできます 
> for(var i=1; i<=20; i++) db.marunouchi.insert({"stock":i}) //for文も使えます
```


#### ちょっと脱線 
* ハッシュであるdbのキー一覧を表示してみる
```
> for(var k in db) print(k)
> //versionというキーあり、呼んでみる
> db.version
> db.version()
```


### SELECT
* mysql> select count(*) from marunouchi
```
> db.marunouchi.count()
```

* mysql> select * from marunouchi
```
> db.marunouchi.find()
```

* has more と表示されたら
```
> it //iterator
```

* find()で20件以上表示させたい
```
> DBQuery.shellBatchSize = 300  
もしくは  
> db.marunouchi.find().toArray()  
> db.marunouchi.find().toArray().forEach(printjsononeline)  
```


* とりあえず1件表示 // mysql> select * from marunouchi limit 1
```
> db.marunouchi.findOne()
```

* mysql> select * from marunouchi limit 5
```
> db.marunouchi.find().limit(5)
```

* mysql> select _id from marunouchi
```
> db.marunouchi.find({},{"_id":1})  
> db.marunouchi.find({},{"created_at":1}) //_id フィールドは常に表示される  
> db.marunouchi.find({},{"_id":0,"created_at":1}) //0で非表示に  
```

* mysql> select _id from where stock = 10
```
> db.marunouchi.find({"stock":10}, {"_id":1})
```

* mysql> select _id from where stock {>, <, >=, <=} 10
```
> db.marunouchi.find({ "stock": { $gt:  10 } }, { "_id": 1 })
> db.marunouchi.find({ "stock": { $lt:  10 } }, { "_id": 1 })
> db.marunouchi.find({ "stock": { $gte: 10 } }, { "_id": 1 })
> db.marunouchi.find({ "stock": { $lte: 10 } }, { "_id": 1 })
```

* JSON形式で表示
```
> db.marunouchi.find().forEach(printjson)
> db.marunouchi.find().forEach(printjsononeline)
```


* toArray
```
> db.marunouchi.find().toArray()
```

### UPDATE
* mysql> update marunouchi set stock = 11 where stock = 10
```
> db.marunouchi.update({"stock":10},{$set:{"stock":11}}) //$setがないと他のフィールドが消えてしまうので注意
```

* _idが存在すればupdate、存在しなければinsert
```
> db.marunouchi.save({"_id":ObjectId("xxxx"),"stock":20})
```

### DELETE
* mysql> delete from marunouchi where stock = 11

```
> db.marunouchi.remove({"stock":11})
```

## INDEX
* INDEX参照
```
> db.system.indexes.find()
```

* INDEX作成
```
> db.marunouchi.ensureIndex({"stock":1})
```

* INDEX削除
```
> db.marunouchi.dropIndex({"stock":1})  
> db.marunouchi.dropIndexes() //全て削除  
```

##参考サイト

* [SQL脳に優しいMongoDBクエリー入門](http://d.hatena.ne.jp/taka512/20110220/1298195574)  
* [MongoDB公式マニュアル チュートリアル](http://www.mongodb.org/pages/viewpage.action?pageId=5079135)  
* [MongoDB公式マニュアル 高度なクエリー](http://www.mongodb.org/pages/viewpage.action?pageId=6029357)  
* [MongoDB公式マニュアル インデックス](http://www.mongodb.org/pages/viewpage.action?pageId=5800049)
* [MongoDBでゆるふわDB体験](http://gihyo.jp/dev/serial/01/mongodb) [第3回　MongoDBのクエリを使いこなそう](http://gihyo.jp/dev/serial/01/mongodb/0003)
