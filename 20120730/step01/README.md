# SQLライクなMongoDBの操作

## pathの確認
### Windows
* マイコンピュータ右クリック -> プロパティ -> システムの詳細設定 -> 詳細設定タブ -> 環境変数 -> Path に#{MongoDBのインストールパス/bin}を追加

### Mac, Linux
* 以下のコマンドを実行

> \> export PATH = #{MongoDBのインストールパス/bin}:$PATH

* 追加されたpathが入っていることを確認

> \> echo $PATH

## mongodbの起動

* mongodの起動

> \> mongod --dbpath #{path}

* configファイルを使用した起動

> \> mongod -f #{config_file}

* mongo shellの起動

> \> mongo

## DBS
* データベースを参照する // mysql> show databases

> \> show dbs

* データベースを選択/作成する // mysql> use #{db_name}; create database #{db_name}

> \> use #{db_name}

* データベースを削除する // mysql> drop database #{db_name}

> //useコマンドでデータベースを選択しておく    
> \> db.dropDatabase()

## COLLECTION
* コレクションを参照/作成する // mysql> show tables; create table #{table_name}(...)

> \> show dbs  
> \> use #{db_name}  
> \> show collections  //コレクションが何も表示されなかったら適当にinsertする  
> \> db.marunouchi.insert({"now":new Date()})  //現在時刻をinsert  
> \> show collections //marunouchiが見えますか

* コレクションを削除する // mysql> drop table #{table_name}

> \> show dbs  
> \> use #{db_name}  
> \> show collections  
> \> db.marunouchi.drop()  foo コレクション全部を削除します  
> \> show collections //確認、marunouchiは削除された  

* コレクション内のデータを削除する // mysql> truncate table #{table_name}

> \> db.marunouchi.insert({"now":new Date()})  
> \> show collections  
> \> db.marunouchi.remove()   コレクションの中のすべてのオブジェクトを削除します  
> \> show collections //確認、marunouchiはまだある  


## DOCUMENT
### INSERT
* mysql> insert into #{table_name} values(...)

> \> use #{db_name}  
> \> db.marunouchi.insert({"now":new Date()})  
> \> db[marunouchi].insert({"now":new Date()}) //こんな書き方もできます  
> \> for(var i=1; i<=20; i++) db.marunouchi.insert({"stock":i})


### SELECT
* mysql> select * from marunouchi

> \> db.marunouchi.find()

* has more と表示されたら

> \> it //iterator

* find()で20件以上表示させたい

> \> DBQuery.shellBatchSize = 300  
> //もしくは  
> \> db.marunouchi.find().toArray()  
> \> db.marunouchi.find().toArray().forEach(printjsononeline)  

* とりあえず1件表示 mysql> select * from marunouchi limit 1

> \> db.marunouchi.findOne()

* mysql> select * from marunouchi limit 5

> \> db.marunouchi.find().limit(5)

* mysql> select _id from marunouchi

> \> db.marunouchi.find({},{"_id":1})  
> \> db.marunouchi.find({},{"now":1}) //_id フィールドは常に表示される  
> \> db.marunouchi.find({},{"_id":0,"now":1}) //0で非表示に  

* mysql> select _id from where stock = 10

> \> db.marunouchi.find({"stock":10},{"_id":1})  

* mysql> select _id from where stock {>, <, >=, <=} 10

> \> db.marunouchi.find({ "stock" : { $gt:  10 } } ); // 大きい : stock > 10  
> \> db.marunouchi.find({ "stock" : { $lt:  10 } } ); // 小さい : stock < 10  
> \> db.marunouchi.find({ "stock" : { $gte: 10 } } ); // 以上 : stock >= 10  
> \> db.marunouchi.find({ "stock" : { $lte: 10 } } ); // 以下 : stock <= 10   

* JSON形式で表示

> \> db.marunouchi.find().forEach(printjson)  
> \> db.marunouchi.find().forEach(printjsononeline)  

* toArray

> \> db.marunouchi.find().toArray()


### UPDATE
* mysql> update marunouchi set version = 7 where name = 'debian'

> \> db.marunouchi.update({"name":"debian"},{$set:{"stock":10}}) //$setがないと他のフィールドが消えてしまうので注意

* _idが存在すればupdate、存在しなければinsert

> \> db.marunouchi.save({"_id":ObjectId("xxxx"),"stock":10})

### DELETE
* mysql> delete from marunouchi where name = 'centos'

> \> db.marunouchi.remove({"name":"centos"})

## INDEX
* INDEX参照

> \> db.system.indexes.find()

* INDEX作成

> \> db.marunouchi.ensureIndex({"stock":1})

* INDEX削除

> \> db.marunouchi.dropIndex({"stock":1})  
> \> db.marunouchi.dropIndexes() //全て削除  

##参考サイト

[SQL脳に優しいMongoDBクエリー入門](http://d.hatena.ne.jp/taka512/20110220/1298195574)


