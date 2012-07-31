# SQLライクなMongoDBの操作

## インストールはダウンロードしたファイルを展開するだけです
### 展開と確認
<pre>
[root@dev modules]# tar zxfv mongodb-linux-x86_64-2.0.5.tgz
[root@dev modules]# cd mongodb-linux-x86_64-2.0.6
[root@dev mongodb-linux-x86_64-2.0.6]# ll
合計 56
-rw------- 1 root root 34520  2月 14 01:05 GNU-AGPL-3.0
-rw------- 1 root root  1364  2月 14 01:05 README
-rw------- 1 root root  9879  2月 14 01:05 THIRD-PARTY-NOTICES
drwxr-xr-x 2 root root  4096  6月  5 04:37 bin
[root@dev mongodb-linux-x86_64-2.0.6]# ll bin
合計 90824
-rwxr-xr-x 1 root root 8634376  6月  5 04:36 bsondump
-rwxr-xr-x 1 root root 2802456  6月  5 04:36 mongo
-rwxr-xr-x 1 root root 8683688  6月  5 04:36 mongod
-rwxr-xr-x 1 root root 8678136  6月  5 04:36 mongodump
-rwxr-xr-x 1 root root 8647080  6月  5 04:36 mongoexport
-rwxr-xr-x 1 root root 8645992  6月  5 04:36 mongofiles
-rwxr-xr-x 1 root root 8665816  6月  5 04:36 mongoimport
-rwxr-xr-x 1 root root 8661672  6月  5 04:36 mongorestore
-rwxr-xr-x 1 root root 5338272  6月  5 04:36 mongos
-rwxr-xr-x 1 root root 6667000  6月  5 04:36 mongosniff
-rwxr-xr-x 1 root root 8720552  6月  5 04:36 mongostat
-rwxr-xr-x 1 root root 8653544  6月  5 04:37 mongotop
</pre>

## pathの確認
### Windows
* マイコンピュータ右クリック -> プロパティ -> システムの詳細設定 -> 詳細設定タブ -> 環境変数 -> Path に#{MongoDBのインストールパス/bin}を追加

### Mac, Linux
* 以下のコマンドを実行
<pre>
> export PATH=#{MongoDBのインストールパス/bin}:$PATH
</pre>

* 追加されたpathが入っていることを確認
<pre>
> echo $PATH
</pre>

## mongodbの起動

* mongodの起動
 * dbpathオプションでdataディレクトリを指定します。指定しない場合は、/data/db または C:\data\db に作成しようとして、ディレクトリが無かった場合はエラーで起動しません。
<pre>
>mongod --dbpath #{path}
</pre>

* configファイルを使用した起動
<pre>
> mongod -f #{config_file}
</pre>

* mongo shellの起動
<pre>
> mongo
</pre>

## DBS
* データベースを参照する // mysql> show databases
<pre>
> show dbs
</pre>

* データベースを選択/作成する // mysql> use #{db_name}; create database #{db_name}
<pre>
> use #{db_name}
</pre>

* データベースを削除する // mysql> drop database #{db_name}
<pre>
//useコマンドでデータベースを選択しておく    
> db.dropDatabase()
</pre>

## COLLECTION
* コレクションを参照/作成する // mysql> show tables; create table #{table_name}(...)
<pre>
> show dbs  
> use #{db_name}  
> show collections  //コレクションが何も表示されなかったら適当にinsertする  
> db.marunouchi.insert({"now":new Date()})  //現在時刻をinsert  
> show collections //marunouchiが見えますか
</pre>

* コレクションを削除する // mysql> drop table #{table_name}
<pre>
> show dbs  
> use #{db_name}  
> show collections  
> db.marunouchi.drop()  foo コレクション全部を削除します  
> show collections //確認、marunouchiは削除された  
</pre>

* コレクション内のデータを削除する // mysql> truncate table #{table_name}
<pre>
> db.marunouchi.insert({"now":new Date()})  
> show collections  
> db.marunouchi.remove()   コレクションの中のすべてのオブジェクトを削除します  
> show collections //確認、marunouchiはまだある  
</pre>

* descコマンドはありません // mysql> desc #{table_name}

## DOCUMENT
### INSERT
* mysql> insert into #{table_name} values(...)
<pre>
> use #{db_name}
> db.marunouchi.insert({"now":new Date()})
> db["marunouchi"].insert({"now":new Date()}) //こんな書き方もできます 
> for(var i=1; i<=20; i++) db.marunouchi.insert({"stock":i})
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
> db.marunouchi.find({},{"now":1}) //_id フィールドは常に表示される  
> db.marunouchi.find({},{"_id":0,"now":1}) //0で非表示に  
</pre>

* mysql> select _id from where stock = 10
<pre>
> db.marunouchi.find({"stock":10},{"_id":1})  
</pre>

* mysql> select _id from where stock {>, <, >=, <=} 10
<pre>
> db.marunouchi.find({ "stock" : { $gt:  10 } } )
> db.marunouchi.find({ "stock" : { $lt:  10 } } )
> db.marunouchi.find({ "stock" : { $gte: 10 } } )
> db.marunouchi.find({ "stock" : { $lte: 10 } } )
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
> db.marunouchi.update({"name":"debian"},{$set:{"stock":10}}) //$setがないと他のフィールドが消えてしまうので注意
</pre>

* _idが存在すればupdate、存在しなければinsert
<pre>
> db.marunouchi.save({"_id":ObjectId("xxxx"),"stock":10})
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
