# MongoDB入門

* 本資料は、第1回丸の内MongoDB勉強会の資料をバージョン2.6.1（2014/5/5リリース）向けに修正したものです。

## インストールはダウンロードしたファイルを展開するだけです
### ここからOSにあったバイナリをダウンロードしてください
[Downloads - MongoDB](http://www.mongodb.org/downloads)

### 展開と確認(Linuxの場合)
<pre>
# tar zxfv mongodb-linux-x86_64-2.6.1.tgz

# cd mongodb-linux-x86_64-2.6.1

# ll
GNU-AGPL-3.0
README
THIRD-PARTY-NOTICES
bin

# ll bin/
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
mongostat
mongotop
</pre>

### 展開(Windowsの場合)
* ダウンロードしたzipファイルを解凍する(msi形式でもダウンロードできますが、ここではzip形式の場合を記載します)

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
dbpathオプションでdataディレクトリを指定します。指定しない場合は、/data/db または C:\data\db に作成しようとして、ディレクトリが無かった場合はエラーで起動しません。
--nojournalオプションは、
<pre>
> mongod --nojournal --dbpath {path}  //例 mongod --dbpath C:\mongo\db
</pre>

* configファイルを使用した起動(configファイルで設定したい人向け)
<pre>
> mongod -f {config_file}  //例 mongod -f C:\mongo\mongod.conf
</pre>

* mongo shellの起動
<pre>
> mongo
// 成功例
[root@dev bin]# mongo
MongoDB shell version: 2.6.1
connecting to: test
Welcome to the MongoDB shell.
For interactive help, type "help".
For more comprehensive documentation, see
        http://docs.mongodb.org/
Questions? Try the support group
        http://groups.google.com/group/mongodb-user
>
</pre>


## DBS
* データベースを参照する // mysql> show databases
<pre>
> show dbs
admin  (empty)
local  0.078GB

> show databases
admin  (empty)
local  0.078GB
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
WriteResult({ "nInserted" : 1 })
> show collections //marunouchiが見えますか
</pre>

* コレクションを削除する // mysql> drop table {table_name}
<pre>
> show dbs  
> use {db_name}  
> show collections  
> db.marunouchi.drop()  //コレクション全部を削除します  
> show collections //確認、marunouchiは削除された  
</pre>

* コレクション内のドキュメントを削除する // mysql> truncate table {table_name}
<pre>
> db.marunouchi.insert({"created_at":new Date()})
WriteResult({ "nInserted" : 1 })
> show collections  
> db.marunouchi.remove()
2014-05-12T02:36:44.040+0000 remove needs a query at src/mongo/shell/collection.js:299
// removeにはクエリが必要になりました（2.6.0？～）
> db.marunouchi.remove({}) //これで全てのドキュメントを削除できます
WriteResult({ "nRemoved" : 1 })
> show collections //確認、marunouchiはまだある
</pre>

* descコマンドはありません // mysql> desc {table_name}

## DOCUMENT
### INSERT
* mysql> insert into {table_name} values(...)
<pre>
> use {db_name}
> db.marunouchi.insert({"created_at":new Date()})
WriteResult({ "nInserted" : 1 })
> db["marunouchi"].insert({"created_at":new Date()}) //こんな書き方もできます 
WriteResult({ "nInserted" : 1 })
> for(var i=1; i<=20; i++) db.marunouchi.insert({"stock":i}) //for文も使えます
WriteResult({ "nInserted" : 1 })
</pre>


#### ちょっと脱線 
* ハッシュであるdbのキー一覧を表示してみる
<pre>
> for(var k in db) print(k)
//versionというキーあり、呼んでみる
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
* mysql> update marunouchi set name = "box1" where stock = 10
<pre>
> db.marunouchi.update({"stock":10},{$set:{"name":"box1"}},{"multi":"true"})
//$setがないと他のフィールドが消えてしまうので注意
//{"multi":"true"}がないと複数ドキュメントに対する更新ができないので注意
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
> db.marunouchi.find({"stock":10})
</pre>

* _idが存在すればupdate、存在しなければinsert
<pre>
> db.marunouchi.save({"_id":ObjectId("***************"),"name":"box2"})
</pre>

### DELETE
* mysql> delete from marunouchi where name = 'centos'
<pre>
> db.marunouchi.remove({"name":"box2"})
WriteResult({ "nRemoved" : 1 })
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
