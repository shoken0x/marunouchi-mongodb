# SQLと比較しながらクエリを学ぶ

* 本資料は、第1回丸の内MongoDB勉強会の資料をバージョン2.6.4向けに修正したものです。

## インストールはダウンロードしたファイルを展開するだけです
### ここからOSにあったバイナリをダウンロードしてください
[Downloads - MongoDB](http://www.mongodb.org/downloads)

### 展開と確認(Linuxの場合)
<pre>
# tar zxfv mongodb-linux-x86_64-2.6.4.tgz

# cd mongodb-linux-x86_64-2.6.4

# ls
GNU-AGPL-3.0
README
THIRD-PARTY-NOTICES
bin

# ls bin
bsondump
mongo
mongod
mongodump
mongoexport
mongofiles
mongoimport
mongooplog
mongoperf
mongorestore
mongos
mongosniff
mongostat
mongotop
</pre>

## pathの確認
### Windows
* マイコンピュータ右クリック -> プロパティ -> システムの詳細設定 -> 詳細設定タブ -> 環境変数 -> Path に{MongoDBのインストールパス/bin}を追加

### Mac, Linux
* 以下のコマンドを実行
<pre>
> export PATH={MongoDBのインストールパス/bin}:$PATH
</pre>

* 追加されたpathが入っていることを確認
<pre>
> echo $PATH
</pre>

## mongodbの起動

* mongodの起動
** nojournalオプションでジャーナリングを無効化します（ディスク容量節約のため）。ジャーナリングについてはdoryokujinさんの[「MongoDBの新機能：ジャーナリングについて詳しく」](http://doryokujin.hatenablog.jp/entry/20110614/1308010072)に詳しく書かれています。
** dbpathオプションでdataディレクトリを指定します。指定しない場合は、/data/db または C:\data\db に作成しようとして、ディレクトリが無かった場合はエラーで起動しません。
<pre>
> mongod --nojournal --dbpath {path} //例 mongod --nojournal --dbpath C:\mongo\db
</pre>

* mongo shellの起動
<pre>
> mongo
// 成功例
[root@dev bin]# mongo
MongoDB shell version: 2.6.4
connecting to: test
>
</pre>


## DBS
* データベースを参照する // mysql> show databases
<pre>
> show dbs
</pre>

* データベースを選択/作成する // mysql> use {db_name}; create database {db_name}  
MongoDBのデータベースは、選択してコレクションへ最初のドキュメントをinsertしたタイミングで作成されます。
<pre>
> use {db_name}
</pre>

* データベースを削除する // mysql> drop database {db_name}
<pre>
//useコマンドでデータベースを選択しておく    
> db.dropDatabase()
</pre>

## COLLECTION
* コレクションを参照/作成する // mysql> show tables; create table {table_name}(...)
<pre>
> show dbs  
> use {db_name}  
> show collections  //コレクションが何も表示されなかったら適当にinsertする  
> db.marunouchi.insert({"created_at":new Date()})  //現在時刻をinsert  
> show collections //marunouchiが見えますか？
</pre>

* コレクションを削除する // mysql> drop table {table_name}
<pre>
> show dbs  
> use {db_name}  
> show collections  
> db.marunouchi.drop()  //コレクション全部を削除します  
> show collections //確認、marunouchiは削除された  
</pre>

* コレクション内のデータを削除する // mysql> truncate table {table_name}
<pre>
> db.marunouchi.insert({"created_at":new Date()})  
> show collections  
> db.marunouchi.remove() //コレクションの中のすべてのオブジェクトを削除します  
> show collections //確認、marunouchiはまだある  
</pre>

* descコマンドはありません // mysql> desc {table_name}

## DOCUMENT
### INSERT
* mysql> insert into {table_name} values(...)
<pre>
> use {db_name}
> db.marunouchi.insert({"created_at":new Date()})
> db["marunouchi"].insert({"created_at":new Date()}) //こんな書き方もできます 
> for(var i=1; i<=20; i++) db.marunouchi.insert({"stock":i}) //for文も使えます
</pre>


#### ちょっと脱線 
* ハッシュであるdbのキー一覧を表示してみる
<pre>
> for(var k in db) print(k)
> //versionというキーあり、呼んでみる
> db.version
> db.version()
</pre>


### SELECT
* mysql> select count(*) from marunouchi
<pre>
> db.marunouchi.count()
</pre>

* mysql> select * from marunouchi
<pre>
> db.marunouchi.find()
</pre>

* has more と表示されたら
<pre>
> it //iterator
</pre>

* find()で20件以上表示させたい
<pre>
> DBQuery.shellBatchSize = 300  
もしくは  
> db.marunouchi.find().toArray()  
> db.marunouchi.find().toArray().forEach(printjsononeline)  
</pre>


* とりあえず1件表示 // mysql> select * from marunouchi limit 1
<pre>
> db.marunouchi.findOne()
</pre>

* mysql> select * from marunouchi limit 5
<pre>
> db.marunouchi.find().limit(5)
</pre>

* mysql> select _id from marunouchi
<pre>
> db.marunouchi.find({},{"_id":1})  
> db.marunouchi.find({},{"created_at":1}) //_id フィールドは常に表示される  
> db.marunouchi.find({},{"_id":0,"created_at":1}) //0で非表示に  
</pre>

* mysql> select _id from where stock = 10
<pre>
> db.marunouchi.find({"stock":10}, {"_id":1})  
</pre>

* mysql> select _id from where stock {>, <, >=, <=} 10
<pre>
> db.marunouchi.find({ "stock": { $gt:  10 } }, { "_id": 1 })
> db.marunouchi.find({ "stock": { $lt:  10 } }, { "_id": 1 })
> db.marunouchi.find({ "stock": { $gte: 10 } }, { "_id": 1 })
> db.marunouchi.find({ "stock": { $lte: 10 } }, { "_id": 1 })
</pre>

* JSON形式で表示
<pre>
> db.marunouchi.find().forEach(printjson)  
> db.marunouchi.find().forEach(printjsononeline)  
</pre>


* toArray
<pre>
> db.marunouchi.find().toArray()
</pre>

### UPDATE
* mysql> update marunouchi set version = 7 where name = 'debian'
<pre>
> db.marunouchi.update({"name":"debian"},{$set:{"version":7}}) //$setがないと他のフィールドが消えてしまうので注意
</pre>

* _idが存在すればupdate、存在しなければinsert
<pre>
> db.marunouchi.save({"_id":ObjectId("xxxx"),"version":7})
</pre>

### DELETE
* mysql> delete from marunouchi where name = 'centos'
<pre>
> db.marunouchi.remove({"name":"centos"})
</pre>

## INDEX
* INDEX参照
<pre>
> db.system.indexes.find()
</pre>

* INDEX作成
<pre>
> db.marunouchi.ensureIndex({"stock":1})
</pre>

* INDEX削除
<pre>
> db.marunouchi.dropIndex({"stock":1})  
> db.marunouchi.dropIndexes() //全て削除  
</pre>

##参考サイト

[SQL脳に優しいMongoDBクエリー入門](http://d.hatena.ne.jp/taka512/20110220/1298195574)  
[MongoDB公式マニュアル チュートリアル](http://www.mongodb.org/pages/viewpage.action?pageId=5079135)  
[MongoDB公式マニュアル 高度なクエリー](http://www.mongodb.org/pages/viewpage.action?pageId=6029357)  
[MongoDB公式マニュアル インデックス](http://www.mongodb.org/pages/viewpage.action?pageId=5800049)
[MongoDBでゆるふわDB体験](http://gihyo.jp/dev/serial/01/mongodb) [第3回　MongoDBのクエリを使いこなそう](http://gihyo.jp/dev/serial/01/mongodb/0003)
