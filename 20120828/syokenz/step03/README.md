みんなでシャーディング
=================
### 会場の人たちのIPアドレスを聞いて、シャーディングをしてみましょう。
----
## はまりどころ

### shardingでは、localhostと実IPの混在はできません！  
ループバックアドレス(127.0.0.1)でもだめ。  
mongos起動する際のconfig serverの指定と、shard追加時のaddshardの指定を注意してください。
このエラーが出たら、localhostと実IPが混在していないかを確認してください。
```
"can't use localhost as a shard since all shards need to communicate. 
either use all shards and configdbs in localhost or all in actual IPs host: localhost:xxxxx isLocalHost:0"
```
### 一度別のshardingに所属したノードが同じdbで他のshardingに所属しようとするとエラーとなる
クリーンなmongodを立ち上げるのが吉


----
## shardサーバ係の人の手順

```
//自分のIPを口頭でmongos, configサーバ係へ伝えましょう

//mkdir
$ mkdir /tmp/mongodb/shard20

//port 20000でshardサーバを起動させましょう
$ mongod --shardsvr --port 20000 --dbpath /tmp/mongodb/shard20 --logpath /tmp/mongodb/log/shard20.log --rest &
```

----
## mongos, configサーバ係の人の手順

```
//configサーバのデータを削除してきれいにしましょう
$ rm -rf /tmp/mongodb/config/* 
//configサーバを起動させましょう
$ mongod --configsvr --port 10001 --dbpath /tmp/mongodb/config --logpath /tmp/mongodb/log/config.log --rest &

//mongosサーバを起動させましょう　
$ mongos --configdb {自分の実IP}:10001 --port 10000 --logpath /tmp/mongodb/log/mongos.log --chunkSize 1&
//例：$ mongos --configdb 10.0.2.1:10001 --port 10000 --logpath /tmp/mongodb/log/mongos.log --chunkSize 1&

//隣人のshardを追加してみましょう
$ mongo localhost:10000/admin
mongos> db.runCommand( { addshard : "{隣人のIP}:20000" } );
//例：mongos> db.runCommand( { addshard : "10.0.2.30:20000" } );
```

----
## 確認

```
//mongosからSharding設定が確認できたら成功です。
$ mongo {mongosのIP}:10000/admin
mognos> db.printShardingStatus();
```


