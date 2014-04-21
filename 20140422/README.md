## MongoDBのインストール

* MongoDBをダウンロード
 * 以下のURLからお使いのOSのものをダウンロード
 * https://www.mongodb.org/downloads
* MongoDBを適当なディレクトリに解凍

## MongoDBの起動

* コンソールを起動
 * Windowsならコマンドプロンプト
 * Mac,Linuxならbash等
* MongoDBを解凍したディレクトリに移動
* データディレクトリの作成

```
 $ mkdir data
```

* MongoDBの起動
 * bin以下にあるMongoDB本体(mongod)の引数に先ほど作ったデータディレクトリを指定

```
(bash) $ bin/mongod --dbpath data

(Win ) > bin\mongod.exe --dbpath data
```

* しばらくして以下のようなログが出たら起動成功

```
Mon Apr 21 23:57:38 [initandlisten] waiting for connections on port 27017
Mon Apr 21 23:57:38 [websvr] admin web console waiting for connections on port 28017
```

### MongoDBに接続

* 別のコンソールを起動

* bin以下にあるMongoDBクライアント(mongo)を起動 

```
(bash) $ bin/mongo

(Win ) > bin\mongo.exe
```

* 以下のような感じになったら成功

```
MongoDB shell version: 2.2.0
connecting to: test
> 
```

* 一旦exitで抜けましょう

### Pentahoのデータのインポート

* Pentahoのデータをダウンロード
 * https://github.com/syokenz/marunouchi-mongodb/raw/master/20140422/mongodb-bin-dump-pentaho.zip
* 適当なディレクトリに解凍
 * ここではMongoDBの解凍ディレクトリ以下に解凍します
 * 解凍する「dump」というディレクトリができます
* bin以下にあるリストアコマンド(mongorestore)でデータをインポートします

```
(win) > bin\mongorestore.exe dump

(bash) $ bin/mongorestore dump
```

* 結果は以下のような感じ

```
> bin\mongorestore.exe dump
connected to: 127.0.0.1
Tue Apr 22 00:19:55 dump/pentaho/events.bson
Tue Apr 22 00:19:55     going into namespace [pentaho.events]
5000 objects found
Tue Apr 22 00:19:55     Creating index: { key: { _id: 1 }, ns: "pentaho.events", name: "_id_" }
Tue Apr 22 00:19:55 dump/pentaho/sessions.bson
Tue Apr 22 00:19:55     going into namespace [pentaho.sessions]
1000 objects found
Tue Apr 22 00:19:55     Creating index: { key: { _id: 1 }, ns: "pentaho.sessions", name: "_id_" }
Tue Apr 22 00:19:55 dump/pentaho/sessions_events.bson
Tue Apr 22 00:19:55     going into namespace [pentaho.sessions_events]
1000 objects found
Tue Apr 22 00:19:55     Creating index: { key: { _id: 1 }, ns: "pentaho.sessions_events", name: "_id_" }
```

### Pentahoのデータの確認

* bin以下にあるMongoDBクライアント(mongo)を起動 

```
(bash) $ bin/mongo

(Win ) > bin\mongo.exe
```

* DB一覧コマンドを実行

```
> show dbs
local   (empty)
pentaho 0.0625GB
```

* pentahoのDBを選択

```
> use pentaho
```

* コレクション一覧

```
> show collections
events
sessions
sessions_events
system.indexes
```

* 中身を検索等

```
> db.events.count()
> db.events.find()
> db.sessions.count()
> db.sessions.find()
> db.sessions.find({browser:"Chrome"})
> db.sessions.findOne()
> doc = db.sessions.findOne()
> doc["browser"]
```
