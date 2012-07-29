## pathの確認
### Windows
* マイコンピュータ右クリック -> プロパティ -> システムの詳細設定 -> 詳細設定タブ -> 環境変数 -> Path に#{MongoDBのインストールパス/bin}を追加

### Mac, Linux
* 以下のコマンドを実行
> \> export PATH = #{MongoDBのインストールパス/bin}:$PATH

*追加されたpathが入っていることを確認
> \> echo $PATH

## mongodbの起動

* mongodの起動
> \> mongod --dbpath #{path}

* mongo shellの起動
> \> mongo

## DBS
* データベースを参照する // mysql> show databases
> \> show dbs

* データベースを選択する // mysql> use #{db_name}
> \> use #{db_name}

* データベースを削除する // mysql> drop database #{db_name}
> //useコマンドでデータベースを選択しておく  
> \> db.dropDatabase()

## DBS
* show dbs
* drop dbs

## COLLECTION
* show collections
* drop collections

## DOCUMENT
* INSERT

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


