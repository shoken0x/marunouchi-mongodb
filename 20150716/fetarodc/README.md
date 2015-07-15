
## MongoDBハンズオン

### インストール

#### MongoDBのダウンロード

MongoDB公式サイトから環境に合ったMongoDB 3.0のZip用バイナリをダウンロードしておいてください。以下のリンクからも落とせます。

* [64bit Windows用MongoDB 3.0.4(Zip版)](https://fastdl.mongodb.org/win32/mongodb-win32-x86_64-3.0.4.zip)
* [64bit MacOSX用MongoDB 3.0.4(Zip版)](https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-3.0.4.tgz)
* [64bit Linux用MongoDB 3.0.4(Zip版)](https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.4.tgz)

32bit版はこちら

* [32bit Windows用MongoDB 3.0.4(Zip版)](https://fastdl.mongodb.org/win32/mongodb-win32-i386-3.0.4.zip)

#### MongoDBのインストール

Windowsの場合はコマンドプロンプトを起動
Linux, MacOSXの場合はターミナルを起動

1. zipを解凍

```
(MongoDBを解凍したディレクトリ)
└bin
 ├ mongod #MongoDB本体
 ├ mongo  #MongoDBクライアント
 ├ ...各種ツール
 
```

2. データディレクトリの作成

```
cd (MongoDBを解凍したディレクトリ)
mkdir data
```

### 起動・停止

#### MongoDBの起動

Windowsの場合

```
bin\mongod --dbpath data --nojournal
```

Linux, MacOSXの場合

```
bin/mongod --dbpath data --nojournal
```

` waiting for connections on port 27017 `と出れば成功


オプションの説明

* --dbpath : データディレクトリの場所.指定しないと`/data/db`や`c:\data\db`を利用する。
* --nojournal : ディスク先行書き込み(journal)を無効にする。これをしないとデータ容量を食います。

#### MongoDBをWiredTigerで起動する（オプション）

64bitのアーキテクチャ限定で、新しいストレージエンジンであるWiredTigerを利用できます。

Windowsの場合

```
bin\mongod --dbpath data --nojournal --storageEngine wiredTiger
```

Linux, MacOSXの場合

```
bin/mongod --dbpath data --nojournal --storageEngine wiredTiger
```

#### MongoDBの停止

Ctrl + C

#### 最初からやり直したいときは

MongoDBの停止してdataフォルダの中身をすべて削除すればOK



### MongoDBへの接続

もう一つコマンドプロンプトorコンソールを立ち上げて、MongoDBに接続する。

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

### （おさらい）MongoDBのデータ構造

```
プロセス(mongod)
└データベース
　└コレクション
　　└ドキュメント(JSON)
```

### データ定義コマンド (いわるゆDDL)

データベース一覧を参照する

```
show dbs
```

データベースを選択/作成する 

```
use mydb
```

※MongoDBのデータベースは選択するだけでは作成されません。コレクションへ最初のドキュメントをinsertしたタイミングで作成されます。

コレクションを一覧を参照する

```
show collections
もしくは
show tables
```


### データ操作コマンド (DML)

#### INSERT

データを挿入します。
`SQL: INSERT INTO mycol ('a') VALUES(1)`

```
use mydb
db.mycol.insert({a:1})
```

`WriteResult({ "nInserted" : 1 }) `が出れば成功。
`db`は今選択しているDB「mydb」のオブジェクト
`mycol`はコレクションの名前を指定して、コレクションオブジェクトを取得

```
//関数が使えます
db.mycol.insert({"created_at":new Date()})
//for文も使えます
for(var i=1; i<=10; i++) db.mycol.insert({"stock":i}) 
```

#### SELECT

選択
`SQL: SELECT * FROM mycol`

```
db.mycol.find()
```

ドキュメントの件数をカウント
`SQL: SELECT count(*) FROM mycol` 

```
db.mycol.count()
```

条件をつけて検索
`SQL: SELECT * FROM mycol WHERE stock = 5`
`SQL: SELECT * FROM mycol WHERE stock > 5`

```
db.mycol.find({ "stock": 5 })
db.mycol.find({ "stock": { $gt:  5 } })
```

ソート

`SQL: SELECT * FROM mycol ORDER BY stock DESC `

```
db.mycol.find().sort({stock: -1})
```
1は昇順-1は降順

件数の制限

`SQL: SELECT * FROM mycol ORDER BY stock DESC LIMIT 1`

```
db.mycol.find().sort({stock: -1}).limit(1)
```

射影

`SQL: SELECT _id FROM mycol`

```
//２つ目の引数に射影するキー名を指定
db.mycol.find({},{"_id":1})
//_id フィールドは常に表示される
db.mycol.find({},{"created_at":1})
//0で非表示に
db.mycol.find({},{"_id":0,"created_at":1}) 
```

豆知識：mongo shellはbashと同じキーバインドです。↑↓でコマンド履歴やTABで補完ができます


### UPDATE

`UPDATE mycol SET stock = 11 WHERE stock = 5`
```
db.mycol.update({"stock":5},{$set:{"stock":11}})
```

`$set`がない場合はドキュメント全体の置き換え。つまりと他のフィールドが消えてしまうので注意

_idが存在すればupdate、存在しなければinsert
```
db.mycol.save({"_id":ObjectId("xxxx"),"stock":20})
```

### DELETE

`DELETE FROM mycol WHERE stock = 5`

```
db.mycol.remove({"stock":5})
```



## Mongo Shell ならではのコマンド

### findOne()

ドキュメントを１件を取得

```
db.mycol.findOne()
```

### findOne()とfind().limit(1)の違い

find()はカーソルが返却され、findOne()はドキュメントそのものが返却されます

```
doc1 = db.mycol.find().limit(1) // -DBのカーソルが返却される
doc1

doc2 = db.mycol.findOne() // -JSONが返却される
doc2
```

find()メソッドの戻り値はカーソルです。
カーソルは検索結果の位置を示すものです。
例えば100万件あるときにfind()して100万件全件帰ってくると、性能が劣化します。
MongoDBではデフォルトでは20件づつドキュメントを取ってきます。
`it`をうつとカーソルが進み、次の20件をとりに行きます。

find()で20件以上取得したい場合は以下のようにします。
```
DBQuery.shellBatchSize = 300

```

手っ取り早く全件表示したい場合は.toArray()をつけます。
```
db.mycol.find().toArray()
```

#### cursol.forEach

検索結果の中身を関数で処理します
```
db.team.insert({ name : "watanabe", age : 32 })
db.team.insert({ name : "kitazawa", age : 28 })
db.team.insert({ name : "hayashida", age : 30 })
db.team.find()
db.team.find().forEach( function(doc) { print( "name is " + doc.name ); } );
```

#### cursol.map

検索結果の中身を関数で評価し、配列にして返却します
```
db.team.find().map( function(doc) { return doc.age } )
```

#### mongoshell はjavascript
forやfunctionやtoArray()でピンときた人はきたでしょう。

Mongo shellはjavascriptです。

```
1 + 1
var doc = {a:3}
db.hoge.insert(doc)
```

javascriptでは()をつけずに関数を実行すると関数そのものが観れます。
```
db.mycol.find
```

### もう少し少し実践的なデータで試してみる

```
db.profile.insert({
  "name" : "watanabe",
  "skill" : ["MongoDB","ruby","swift"],
  "job":{
    "before" : "Online Trade System",
    "now" : "Open Source"
  },
  "editor":"emacs"
})

db.profile.insert({
  "name" : "ogasawara",
  "skill" : ["MongoDB","LibreOffice","Printing"],
  "editor":"vim"
})


db.profile.insert({
  "name" : "kubota",
  "skill" : ["MongoDB","MySQL","PostgreSQL","ruby","c++","java","Web"],
  "editor":"emacs",
  "keybord":"kinesis"
})
```

skillにMongoDBを持っているユーザのnameを表示
```
db.profile.find({"skill":"MongoDB"},{"name":1})
```

nameがwatanabeのドキュメントを変数に格納して利用
```
watanabe = db.profile.findOne({"name":"watanabe"})
watanabe["job"]
watanabe["job"]["before"]
watanabe["skill"][2]
```

jobのキーがないユーザのに対して、nameを表示する
```
db.profile.find({"job":null}).forEach(function(doc){
  print(doc.name);
})
```

### 集計してみる

[公式のサンプル](http://docs.mongodb.org/manual/tutorial/aggregation-zip-code-data-set/)を利用して、集計を試してみる。
まず、以下の元データをダウンロード。

直リンク　→　[zips.json](http://media.mongodb.org/zips.json)

mongoimportコマンドでインポートする

```
# bin/mongoimport zips.json
2015-07-14T23:20:14.649+0900	no collection specified
2015-07-14T23:20:14.650+0900	using filename 'zips' as collection
2015-07-14T23:20:14.660+0900	connected to: localhost
2015-07-14T23:20:15.735+0900	imported 29353 documents
```

```
db.zips.count()

db.zips.find()
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

## さらに学ぶには

英語が読める人は

* [公式マニュアル](http://docs.mongodb.org/manual/)

英語が読めない人は

* [MongoDBでゆるふわDB体験](http://gihyo.jp/dev/serial/01/mongodb)
* [MongoDB インアクション](http://www.oreilly.co.jp/books/9784873115900/)
* [MongoDB University](https://university.mongodb.com/courses)　日本語webinerあります

更に高みを目指す場合は
* [脱初心者MongoDB中級編(仮)](http://enterprisezine.jp/) 近日連載開始（宣伝）
* [LinuxとApacheの憂鬱](http://d.hatena.ne.jp/hiroppon/?of=5)
