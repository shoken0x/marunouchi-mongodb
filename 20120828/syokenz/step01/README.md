シャーディングの設定（Mac OSXで動作確認しています）
=================
### MongoDBのSharding環境を構築し、データを投入してみます。
----
#### 参考URL

[MongoDBのShardingを試してみた。その１](http://d.hatena.ne.jp/matsuou1/20110413/1302710901)

----

# 基本情報
* ポート
 * localhost:10000 => mongos  
 * localhost:10001 => config  
 * localhost:10010 => shard0(shard0000)  
 * localhost:10011 => shard1(shard0001)  
 * localhost:10012 => shard2(shard0002)  
 * 各ノードは、+1000番でWebコンソールが見えます  
 * 例：http://localhost:11001  

* データ入れるdbとcollection
 * db => logdb  
 * collection => logs  

----

# 準備
logディレクトリ、データディレクトリを作成します。

<pre>
$ mkdir -p /tmp/mongodb/log
$ mkdir -p /tmp/mongodb/config
$ mkdir -p /tmp/mongodb/shard0
$ mkdir -p /tmp/mongodb/shard1
$ mkdir -p /tmp/mongodb/shard2
</pre>


----
# 各サーバ起動
shardサーバ、configサーバ、mongosサーバを起動します。

#### shardサーバの起動
<pre>
$ mongod --shardsvr --port 10010 --dbpath /tmp/mongodb/shard0 --logpath /tmp/mongodb/log/shard0.log --rest &
$ mongod --shardsvr --port 10011 --dbpath /tmp/mongodb/shard1 --logpath /tmp/mongodb/log/shard1.log --rest &
$ mongod --shardsvr --port 10012 --dbpath /tmp/mongodb/shard2 --logpath /tmp/mongodb/log/shard2.log --rest &
</pre>

#### shardサーバの確認
<pre>
$ mongo localhost:10001
MongoDB shell version: 2.0.3
connecting to: localhost:10010/test
//connectingできたらOK
</pre>

#### configサーバ、mongosサーバの起動
<pre>
//configサーバ起動
$ mongod --configsvr --port 10001 --dbpath /tmp/mongodb/config --logpath /tmp/mongodb/log/config.log --rest &
//mongosサーバ起動
//chunkの動作も見たいので、chunk sizeを1MBに設定し起動する。
$ mongos --configdb localhost:10001 --port 10000 --logpath /tmp/mongodb/log/mongos.log --chunkSize 1&
</pre>

#### configサーバ、mongosサーバの確認
<pre>
$ ps axu |grep [m]ongo |wc -l
//5だったらOK
</pre>

----
# Shradの追加
#### mongosのadminに接続し、Shardを追加する。
<pre>
$ mongo localhost:10000/admin
MongoDB shell version: 2.0.7
connecting to: localhost:10000/admin
mongos> db  //adminに接続されていることを確認
admin
// addshard
mongos> db.runCommand( { addshard : "localhost:10010" } );
{ "shardAdded" : "shard0000", "ok" : 1 }
mongos> db.runCommand( { addshard : "localhost:10011" } );
{ "shardAdded" : "shard0001", "ok" : 1 }
mongos> db.runCommand( { addshard : "localhost:10012" } );
{ "shardAdded" : "shard0002", "ok" : 1 }
</pre>



#### 追加したshardが正しく追加されているかどうか、確認する。  
・db.runCommand( { listshards : 1 } )  
・db.printShardingStatus()  

<pre>
mongos> db.runCommand( { listshards : 1 } );
{
"shards" : [
{
"_id" : "shard0000",
"host" : "localhost:10010"
},
{
"_id" : "shard0001",
"host" : "localhost:10011"
},
{
"_id" : "shard0002",
"host" : "localhost:10012"
}
],
"ok" : 1
}
</pre>

<pre>
mognos> db.printShardingStatus();
--- Sharding Status ---
sharding version: { "_id" : 1, "version" : 3 }
shards:
{ "_id" : "shard0000", "host" : "localhost:10010" }
{ "_id" : "shard0001", "host" : "localhost:10011" }
{ "_id" : "shard0002", "host" : "localhost:10012" }
databases:
{ "_id" : "admin", "partitioned" : false, "primary" : "config" }
</pre>

----
# mongos経由でデータ投入

<pre>
$ mongo localhost:10000
mongos> use logdb
mongos> for(var i=1; i=100000; i++) db.logs.insert({"uid":i, "value":Math.floor(Math.random()*100000+1)})
//＜＝があるとgithubの表示がおかしくなる。。
mongos> db.logs.count();
100000
</pre>

## Sharding開始のための2ステップ

1. index作成  
注意：dbをadminではなく、対象のdb(今回はlogdb)に変更すること  
<pre>
mongos> use logdb
mongos> db.logs.ensureIndex( { uid : 1 } );  
</pre>

2. sharding有効化  
注意：dbはadmin
<pre>
mongos> use admin
mongos> db.runCommand( { enablesharding : "logdb" });  
mongos> db.runCommand( { shardcollection : "logdb.logs" , key : { uid : 1 } } );
//shardingが開始される
mongos> db.printShardingStatus();
</pre>


## 本当にshardingされているか確認

まずはmongosに接続し、全体logsコレクションの件数を確認する。

<pre>
$ mongo localhost:10000/logdb
> db.logs.count();
100000
</pre>

次に各shardでlogsコレクションの件数を確認する。
<pre>
$ mongo localhost:10010/logdb
> db.logs.count();
39503
$ mongo localhost:10011/logdb
> db.logs.count();
30248
$ mongo localhost:10012/logdb
> db.logs.count();
30249

</pre>

----
お疲れ様でした。シャーディングの確認はできましたら、次は[step02](https://github.com/syokenz/marunouchi-mongodb/tree/master/20120828/syokenz/step02) 障害発生時の挙動についてです。











