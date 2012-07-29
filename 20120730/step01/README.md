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
> \> db.marunouchi.insert({now:new Date()})  //現在時刻をinsert  
> \> show collections //marunouchiが見えますか

* コレクションを削除する // mysql> drop table #{table_name}

> \> show dbs  
> \> use #{db_name}  
> \> show collections  
> \> db.marunouchi.drop()  foo コレクション全部を削除します  
> \> show collections //確認、marunouchiは削除された  

* コレクション内のデータを削除する // mysql> truncate table #{table_name}

> \> db.marunouchi.insert({now:new Date()})  
> \> show collections  
> \> db.marunouchi.remove()   コレクションの中のすべてのオブジェクトを削除します  
> \> show collections //確認、marunouchiはまだある  


## DOCUMENT
* INSERT // mysql> insert into #{table_name} values(...)

> \> use #{db_name}  
> \> db.marunouchi.insert({now:new Date()})  
> \> //こんな書き方もできます

* SELECT

* UPDATE

* DELETE

* WEHER

* REGEX

## INDEX
* CREATE INDEX
* DELETE INDEX


##参考サイト

[SQL脳に優しいMongoDBクエリー入門](http://d.hatena.ne.jp/taka512/20110220/1298195574)


