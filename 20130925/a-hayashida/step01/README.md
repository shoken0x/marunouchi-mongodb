シャーディングの設定（Mac OSXで動作確認しています）
=================
### MongoDBでSharding環境を構築し、データを投入してみます。
----

#### 参考URL
[MongoDBでゆるふわDB体験 第5回「MongoDBのシャーディングを試してみよう」](http://gihyo.jp/dev/serial/01/mongodb/0005)

----

# 構成概要
今回は，1台の物理マシンにポートを分けて5つのサーバを立ち上げます。

### 概要図
![overview](http://image.gihyo.co.jp/assets/images/dev/serial/01/mongodb/0005/thumb/TH400_002s.jpg)

----

# 準備
データディレクトリ、ログディレクトリを作成します。なお、手順はすべてMongoDBを展開したディレクトリで行うことを想定しています。

```
$ cd (MongoDBの展開ディレクトリ)
$ mkdir -p data/config
$ mkdir data/node0
$ mkdir data/node1
$ mkdir data/node2
$ mkdir log
```


----
# 各サーバ起動
shardサーバ、configサーバ、mongosサーバを起動します。

#### shardサーバの起動

mongodコマンドに--shardsvrのオプションを指定することにより、このmongodがシャードになります。

```
$ bin/mongod --shardsvr --port 30000 --dbpath data/node0 --logpath log/node0.log --fork
$ bin/mongod --shardsvr --port 30001 --dbpath data/node1 --logpath log/node1.log --fork
$ bin/mongod --shardsvr --port 30002 --dbpath data/node2 --logpath log/node2.log --fork
```

#### configサーバ
mongodコマンドに--configsvrのオプションを指定することにより，このmongodがconfigサーバになります。

```
$ bin/mongod --configsvr --port 20001 --dbpath data/config --logpath log/config.log --fork
```

#### mongosサーバの起動
mongosコマンドによりmongosサーバを起動します（mongodではありません）。--configdbにてconfigサーバを指定します。mongosサーバはメモリ上にのみ存在するプロセスであるため，dbpathを指定する必要はありません。

```
$ bin/mongos --configdb localhost:20001 --port 20000 --logpath log/mongos.log --chunkSize 1 --fork
```

chunkSizeはチャンクのサイズをしています。デフォルトでは64Mですが，今回はチャンクが分割される動作を確認したいため，小さい1MBに設定します。

#### configサーバ、mongosサーバの確認
以下の5プロセスが見えればOK。

```
$ ps axu | grep [m]ongo
root 1221 ・・ bin/mongod --shardsvr --port 30000 --dbpath data/node0 --logpath log/node0.log
root 1235 ・・ bin/mongod --shardsvr --port 30001 --dbpath data/node1 --logpath log/node1.log
root 1236 ・・ bin/mongod --shardsvr --port 30002 --dbpath data/node2 --logpath log/node2.log
root 1239 ・・ bin/mongod --configsvr --port 20001 --dbpath data/config --logpath log/config.log
root 1241 ・・ bin/mongos --configdb localhost:20001 --port 20000 --logpath log/mongos.log --chunkSize 1

//ps axu | grep [m]ongoで 'grep mongo'プロセスが出てこない理由は、'grep [m]ongo'プロセスとなり、
正規表現の[m]ongo（mが1文字+ongo、つまりmongo）とマッチしなくなるため。
```

----
# mongosサーバにShardを追加する
#### mongosのadminに接続し、Shardを追加する。
mongoシェルで，mongosサーバのadminデータベースに接続します

```
$ bin/mongo localhost:20000/admin
```

sh.addShardメソッドでシャードを追加していきます。

```
mongos> sh.addShard("localhost:30000")    // ←30000ポートのmongodを追加
{ "shardAdded" : "shard0000", "ok" : 1 }  // ←okの値が1であれば正常です

mongos>  sh.addShard("localhost:30001")   // ←30001ポートのmongodを追加
{ "shardAdded" : "shard0001", "ok" : 1 }  // ←okの値が1であれば正常です

mongos> sh.addShard("localhost:30002")    // ←30002ポートのmongodを追加
{ "shardAdded" : "shard0002", "ok" : 1 }  // ←okの値が1であれば正常です
```

#### 追加したshardが正しく追加されているかどうか、確認する。  

```
mongos> sh.status()
--- Sharding Status ---
  sharding version: { "_id" : 1, "version" : 3 }
  shards:
        {  "_id" : "shard0000",  "host" : "localhost:30000" } // ←3つのmongodが追加されている
        {  "_id" : "shard0001",  "host" : "localhost:30001" }
        {  "_id" : "shard0002",  "host" : "localhost:30002" }
  databases:
        {  "_id" : "admin",  "partitioned" : false,  "primary" : "config" }
```

----
# mongos経由でデータ投入

mongosサーバに接続している状態で、logdbというデータベースを作り、logsというコレクションに10万件データを投入します。mongoシェルではjavascriptの文法が使えるため、forループによりデータを挿入しています。

```
mongos> use logdb
switched to db logdb
mongos> for(var i=1; i<=100000; i++) db.logs.insert({"uid":i, "value":Math.floor(Math.random()*100000+1)})      
mongos> db.logs.count()
100000                   // ←10万件挿入されている
```

## Sharding開始のための2ステップ

1. index作成  
注意：dbをadminではなく、対象のdb(今回はlogdb)に変更すること。

```
mongos> use logdb
mongos> db.logs.ensureIndex( { uid : 1 } );  
```

この時点ではまだシャーディングは有効になっていません。単純に最初のノードに10万件のデータが入っているだけです。

![シャーディング有効化前](http://image.gihyo.co.jp/assets/images/dev/serial/01/mongodb/0005/thumb/TH400_003.jpg)

この状態を確認するには、mongoシェルにてmongosサーバのconfigデータベースの中身を見ればわかります。configデータベースのchunksコレクションにクエリをかけてみましょう。

```
mongos> use config
switched to db config
mongos> db.chunks.count()    // ←チャンクの数を表示
0                            // ←0であることがわかる
```

2. sharding有効化  
シャーディングを有効にするにはshオブジェクトのenableShardingメソッドにデータベース名を指定します。

注意：dbはadmin

```
mongos> use admin
switched to db admin
mongos> sh.enableSharding("logdb")
{ "ok" : 1 }
//shardingが開始される
```

次にsh.shardCollectionメソッドでシャード化するコレクションを指定します。第一引数は、(データベース名).(コレクション名)の文字列、第二引数はインデックスを作成するときのハッシュです。

```
mongos> sh.shardCollection("logdb.logs" , { uid : 1 })
{ "collectionsharded" : "logdb.logs", "ok" : 1 }
```


## 本当にshardingされているか確認

sh.statusメソッドでシャーディングの状態を表示すると、3つのシャードサーバにそれぞれチャンクができている様子がわかります。

```
--- Sharding Status ---
  sharding version: { "_id" : 1, "version" : 3 }
  shards:
    {  "_id" : "shard0000",  "host" : "localhost:30000" }
    {  "_id" : "shard0001",  "host" : "localhost:30001" }
    {  "_id" : "shard0002",  "host" : "localhost:30002" }
  databases:
    {  "_id" : "admin",  "partitioned" : false,  "primary" : "config" }
    {  "_id" : "logdb",  "partitioned" : true,  "primary" : "shard0000" }
      logdb.logs chunks:
        shard0001       3    // ←shard0001のチャンク数
        shard0002       3    // ←shard0002のチャンク数
        shard0000       4    // ←shard0000のチャンク数
          { "uid" : { $minKey : 1 } } -->> { "uid" : 10083 } on : shard0001 Timestamp(2000, 0)
          { "uid" : 10083 } -->> { "uid" : 20166 } on : shard0002 Timestamp(3000, 0)
```

しばらく時間がたつと，チャンクの数が3,3,4と均等になっていることがわかります。

![シャーディング有効化後](http://image.gihyo.co.jp/assets/images/dev/serial/01/mongodb/0005/thumb/TH400_004.jpg)
> ※データ数やチャンク数はイメージです。

また、出力の後半に各チャンクに入っているシャードキーの範囲が出力されています。
```
 { "uid" : 10083 } -->> { "uid" : 20166 } on : shard0002 Timestamp(3000, 0)
```
上記の例では、shard0002のチャンクには、uidの範囲が10083≦uid＜20166であるコレクションが格納されていることがわかります。

別の確認方法として，mongosサーバのconfigテーブルを見る方法もあります。

```
mongos> use config
switched to db config
mongos> db.chunks.count()
10
mongos> db.chunks.findOne()
```

#### 各シャードサーバの状態確認
各シャードサーバにmongoシェルで接続すれば、各シャードサーバのコレクションを確認できます。

```
$ bin/mongo localhost:30000/logdb
> db.logs.count()
39503
> exit

$ bin/mongo localhost:30001/logdb
> db.logs.count()
30248
> exit

$ bin/mongo localhost:30002/logdb
> db.logs.count()
30249
> exit
```

----
お疲れ様でした。シャーディングの確認はできましたら、次は[step02](https://github.com/syokenz/marunouchi-mongodb/tree/master/20130925/a-hayashida/step02) 障害発生時の挙動についてです。











