シャーディングの設定（Windows版）
=================

# 準備
logディレクトリ、データディレクトリを作成します。

<pre>
> mkdir db\shard0
> mkdir db\shard1
> mkdir db\shard2
> mkdir db\config
> mdkir log
</pre>


----
# 各サーバ起動
shardサーバ、configサーバ、mongosサーバを起動します。
(Windowsではバックグラウンドでプロセスを上げる場合、start "(名前)" を使います）

#### shardサーバの起動
<pre>
> start "shard0" bin\mongod --shardsvr --port 10010 --dbpath db\shard0 --logpath log\shard0.log --rest
> start "shard1" bin\mongod --shardsvr --port 10011 --dbpath db\shard1 --logpath log\shard1.log --rest
> start "shard2" bin\mongod --shardsvr --port 10012 --dbpath db\shard2 --logpath log\shard2.log --rest
</pre>

#### shardサーバの確認
<pre>
> bin\mongo localhost:10001
MongoDB shell version: 2.0.3
connecting to: localhost:10010/test
//connectingできたらOK
</pre>

#### configサーバ、mongosサーバの起動
<pre>
//configサーバ起動
> start "config" bin\mongod --configsvr --port 10001 --dbpath db\config --logpath log\config.log --rest &
//mongosサーバ起動
//chunkの動作も見たいので、chunk sizeを1MBに設定し起動する。
> start "mongos" bin\mongos --configdb localhost:10001 --port 10000 --logpath log\mongos.log --chunkSize 1&
</pre>

#### configサーバ、mongosサーバの確認
<pre>
> tasklist | findstr mongo
//5つプロセスが表示されたらOK
</pre>

----
# Shradの追加
#### mongosのadminに接続し、Shardを追加する。
<pre>
> bin\mongo localhost:10000/admin
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
> bin\mongo localhost:10000
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
>bin\mongo localhost:10000/logdb
> db.logs.count();
100000
</pre>

次に各shardでlogsコレクションの件数を確認する。
<pre>
>bin\mongo localhost:10010/logdb
> db.logs.count();
39503
>bin\mongo localhost:10011/logdb
> db.logs.count();
30248
>bin\mongo localhost:10012/logdb
> db.logs.count();
30249

</pre>

----
お疲れ様でした。シャーディングの確認はできましたら、次は[step02](https://github.com/syokenz/marunouchi-mongodb/tree/master/20120828/syokenz/step02) 障害発生時の挙動についてです。













