MongoDB レプリケーション(Replica Sets)
=================

概要
=================

http://www.mongodb.org/display/DOCS/Replica+Sets



レプリカセットを試す
=================

データディレクトリ作成

```
$ cd (mongodb install directory)
$ mkdir data
$ mkdir data\node1
$ mkdir data\node2
$ mkdir data\node3
```

mongod開始

```
$ start "node1" bin\mongod.exe --replSet rs1 --port 20001 --dbpath=data/node1 --rest
$ start "node2" bin\mongod.exe --replSet rs1 --port 20002 --dbpath=data/node2 --rest
$ start "node3" bin\mongod.exe --replSet rs1 --port 20003 --dbpath=data/node3 --rest
```

プロセス確認

```
$ tasklist | findstr mongo 
mongod.exe                   10712 Console                    1     66,116 K
mongod.exe                    8732 Console                    1     69,344 K
mongod.exe                   11100 Console                    1     68,308 K
```

起動確認は以下のURLにアクセスしてもOKです

* http://localhost:21001/
* http://localhost:21002/
* http://localhost:21003/

レプリカセットの作成

```
$ bin\mongo localhost:20001
> rs.initiate()
{
        "info2" : "no configuration explicitly specified -- making one",
        "me" : "kotaro:20001", ←自ホスト名「私の場合は"kotaro"」になります。IPアドレスになってほしいけど、やり方は不明。
        "info" : "Config now saved locally.  Should come online in about a minute.",
        "ok" : 1
}
> rs.add("%HOST%:20002")
> rs.add("%HOST%:20003") 
```

補足１） %HOST%はホスト名。
この部分をループバックインターフェース(127.0.0.1やlocalhost) にしてしまうと、以下のようなエラーが出ます

```
> rs.add("localhost:20002")
{
        "errmsg" : "exception: can't use localhost in repl set member names except when using it for all members",
        "code" : 13393,
        "ok" : 0
}
```

補足２）設定を先に作成してから一気に作る方法もあります


```
> cfg = {
 _id : "rs1", 
 members : [ 
  { _id : 0, host : "%HOST%:20001" }, 
  { _id : 1, host : "%HOST%:20002" }, 
  { _id : 2, host : "%HOST%:20003" } ] } 
> cfg   
(内容確認)
> rs.initiate(cfg)
{
        "info" : "Config now saved locally.  Should come online in about a minute.",
        "ok" : 1
}
```

※%HOST%はホスト名でもIPアドレスでもＯＫです。ループバックインターフェース(127.0.0.1やlocalhost)はだめです。

レプリカセットのステータス確認。成功すると以下のように見えます。

```
> rs.status()
{
        "set" : "rs1",
        "date" : ISODate("2012-09-17T07:18:04Z"),
        "myState" : 1,
        "members" : [
                {
                        "_id" : 0,
                        "name" : "kotaro:20001",
                        "health" : 1,
                        "state" : 1,
                        "stateStr" : "PRIMARY",
                        "uptime" : 321,
                        "optime" : Timestamp(1347866232000, 1),
                        "optimeDate" : ISODate("2012-09-17T07:17:12Z"),
                        "self" : true
                },
                {
                        "_id" : 1,
                        "name" : "kotaro:20002",
                        "health" : 1,
                        "state" : 2,
                        "stateStr" : "SECONDARY",
                        "uptime" : 73,
                        "optime" : Timestamp(1347866232000, 1),
                        "optimeDate" : ISODate("2012-09-17T07:17:12Z"),
                        "lastHeartbeat" : ISODate("2012-09-17T07:18:03Z"),
                        "pingMs" : 0
                },
                {
                        "_id" : 2,
                        "name" : "kotaro:20003",
                        "health" : 1,
                        "state" : 2,
                        "stateStr" : "SECONDARY",
                        "uptime" : 52,
                        "optime" : Timestamp(1347866232000, 1),
                        "optimeDate" : ISODate("2012-09-17T07:17:12Z"),
                        "lastHeartbeat" : ISODate("2012-09-17T07:18:02Z"),
                        "pingMs" : 0
                }
        ],
        "ok" : 1
}
```

動作確認
-----------------

データの挿入

```
(ポート20001のmongodで実行)
> use mydb
> for(var i=1; i<=100000; i++) db.logs.insert({"uid":i, "value":Math.floor(Math.random()*100000+1)}) ←１０万件ほどデータを投入してみる
```

レプリケーションされたことの確認。ポート20002のmongodで確認する。

```
$ exit 
$ bin\mongo localhost:20002  (ポート20002のmongodに接続)
> use mydb
> show collections
Mon Sep 17 14:27:13 uncaught exception: error: { "$err" : "not master and slaveOk=false", "code" : 13435 }
```

何も考えずにshow collectionsするとエラーになります。
なので、setSlaveOk()コマンドを使います。

（db.getMongo().setSlaveOk()の説明: allow this connection to read from the nonmaster member of a replica pair）

```
> db.getMongo().setSlaveOk()
> show collections
> db.logs.count()
100000
```


プライマリの障害実験
-----------------

Primaryのmongod(ポート20001のmongod)のプロセスを殺します。（好きな方法で殺しください)

他のmongod(例えばポート20002のプロセス)にログインして、Primaryが移動したか確認します。

```
$ bin\mongo localhost:20002
> rs.status();
```

webのインターフェースからも確認できます→http://localhost:21002



レプリカセットへの参加
-----------------

プロセスを上げるだけ

```
$ start "node1" bin\mongod.exe --replSet rs1 --port 20001 --dbpath=data/node1 --rest
$ bin\mongo localhost:20002
> rs.status();
```


リクエストの振り分け（mongosとの連携）
-----------------

mongosとconfigサーバの起動

```
$ mkdir data\config
$ start "config" bin\mongod --configsvr --port 10001 --dbpath data\config --rest
$ start "mongos" bin\mongos --configdb %HOST%:10001 --port 10000 --chunkSize 1
```

※%HOST%の部分は自端末のホスト名かIPアドレスです。ただし、ループバックインターフェース（127.0.0.1やlocalhost）はNG

mongosの設定

```
$ bin\mongo localhost:10000
> use admin
> db.runCommand({addshard:"rs1/%HOST%:20001,%HOST%:20002,%HOST%:20003"})
{ "shardAdded" : "rs1", "ok" : 1 } 
> db.printShardingStatus()
--- Sharding Status ---
  sharding version: { "_id" : 1, "version" : 3 }
  shards:
        {  "_id" : "rs1",  "host" : "rs1/kotaro:20001,kotaro:20002,kotaro:20003" }
  databases:
        {  "_id" : "admin",  "partitioned" : false,  "primary" : "config" }
```

※%HOST%の部分はrs.status()で表示されるもの。

フェールオーバの確認。

まずmongosに対してクエリーを投げられることを確認。

```
> user mydb
> db.logs.count()
```

Primaryのmongod(ポート20001のmongod)のプロセスを殺します。（好きな方法で殺しください)

プロセスkill直後に、mongosに対してクエリーを投げるとエラーになりますが

```
> db.logs.count()
Mon Sep 17 15:38:33 uncaught exception: count failed: {
        "errmsg" : "exception: socket exception [SEND_ERROR] for 192.168.6.1:20001",
        "code" : 9001,
        "ok" : 0
}
```

その後しばらくすると成功します

```
> db.logs.count()
100000
```

みんなでクラスタ構築
=================



ざっくり手順
```
$ mkdir data\ data\node11 data\node12 data\node13 data\node21 data\node22 data\node23 data\node31 data\node32 data\node33

$ start "node11" bin\mongod.exe --replSet rs1 --port 20011 --dbpath=data/node11 --rest
$ start "node12" bin\mongod.exe --replSet rs1 --port 20012 --dbpath=data/node12 --rest
$ start "node13" bin\mongod.exe --replSet rs1 --port 20013 --dbpath=data/node13 --rest

$ start "node21" bin\mongod.exe --replSet rs2 --port 20021 --dbpath=data/node21 --rest
$ start "node22" bin\mongod.exe --replSet rs2 --port 20022 --dbpath=data/node22 --rest
$ start "node23" bin\mongod.exe --replSet rs2 --port 20023 --dbpath=data/node23 --rest

$ start "node31" bin\mongod.exe --replSet rs3 --port 20031 --dbpath=data/node31 --rest
$ start "node32" bin\mongod.exe --replSet rs3 --port 20032 --dbpath=data/node32 --rest
$ start "node33" bin\mongod.exe --replSet rs3 --port 20033 --dbpath=data/node33 --rest

$ bin\mongo localhost:20011
> cfg = {
 _id : "rs1", 
 members : [ 
  { _id : 0, host : "duo:20011" }, 
  { _id : 1, host : "duo:20012" }, 
  { _id : 2, host : "duo:20013" } ] } 
> rs.initiate(cfg)
> rs.status()

$ bin\mongo localhost:20021
> cfg = {
 _id : "rs2", 
 members : [ 
  { _id : 0, host : "duo:20021" }, 
  { _id : 1, host : "duo:20022" }, 
  { _id : 2, host : "duo:20023" } ] } 
> rs.initiate(cfg)
> rs.status()

$ bin\mongo localhost:20031
> cfg = {
 _id : "rs3", 
 members : [ 
  { _id : 0, host : "duo:20031" }, 
  { _id : 1, host : "duo:20032" }, 
  { _id : 2, host : "duo:20033" } ] } 
> rs.initiate(cfg)
> rs.status()

$ mkdir data\config
$ start "config" bin\mongod --configsvr --port 10001 --dbpath data\config --rest
$ start "mongos" bin\mongos --configdb duo:10001 --port 10000 --chunkSize 1

$ bin\mongo localhost:10000
> use admin
> db.runCommand({addshard:"rs1/duo:20011,duo:20012,duo:20013"})
> db.runCommand({addshard:"rs2/duo:20021,duo:20022,duo:20023"})
> db.runCommand({addshard:"rs3/duo:20031,duo:20032,duo:20033"})

> db.printShardingStatus();
--- Sharding Status ---
  sharding version: { "_id" : 1, "version" : 3 }
  shards:
        {  "_id" : "rs1",  "host" : "rs1/duo:20011,duo:20012,duo:20013" }
        {  "_id" : "rs2",  "host" : "rs2/duo:20021,duo:20022,duo:20023" }
        {  "_id" : "rs3",  "host" : "rs3/duo:20031,duo:20032,duo:20033" }
  databases:
        {  "_id" : "admin",  "partitioned" : false,  "primary" : "config" }
        {  "_id" : "test",  "partitioned" : false,  "primary" : "rs1" }


> use logdb
> for(var i=1; i<=1000000; i++) db.logs.insert({"uid":i, "value":Math.floor(Math.random()*100000+1)})
> db.logs.count();
> db.logs.ensureIndex( { uid : 1 } );  

> use admin
> db.runCommand( { enablesharding : "logdb" });  
> db.runCommand( { shardcollection : "logdb.logs" , key : { uid : 1 } } );
> db.printShardingStatus();

```
