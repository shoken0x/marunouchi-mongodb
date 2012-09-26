Shardingとの組み合わせ
=================

Shardingとの組み合わせ
-----------------

レプリカセットをShardとして扱うと、mongosにリクエストを投げれば自動的にプライマリノードにリクエストしてくれます

mongosとconfigサーバの起動

```
$ mkdir data\config
$ start "config" bin\mongod --configsvr --port 10001 --dbpath data\config --rest
$ start "mongos" bin\mongos --configdb %IP%:10001 --port 10000 --chunkSize 1
```

※%IP%の部分はループバックインターフェース（127.0.0.1やlocalhost）はNG

mongosの設定

```
$ bin\mongo localhost:10000
> use admin
> db.runCommand({addshard:"rs1/%IP%:20001,%IP%:20002,%IP%:20003"})
{ "shardAdded" : "rs1", "ok" : 1 } 
> db.printShardingStatus()
--- Sharding Status ---
  sharding version: { "_id" : 1, "version" : 3 }
  shards:
        {  "_id" : "rs1",  "host" : "rs1/kotaro:20001,kotaro:20002,kotaro:20003" }
  databases:
        {  "_id" : "admin",  "partitioned" : false,  "primary" : "config" }
```

フェールオーバの確認。

まずmongosに対してクエリーを投げられることを確認。

```
> use logdb
> db.logs.count()
```

Primaryのmongodのプロセスを殺します。（好きな方法で殺しください)

Primaryノードのの確認方法は、Web(http://localhost:21001)からみるとよいでしょう。

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

複数Shardでデータ分散+レプリカ
-----------------

![構成図](https://cacoo.com/diagrams/kyoRpiZSDLv6f2lQ-EBC21.png)

※）この作業をする前に、いったんすべてのプロセスを殺して、dataフォルダを削除することをお勧めします。
　ちなみに、フォルダを丸ごと消したい場合、bashでは「rm -rf data」ですが、Windowsだと「rd /s data」です。


手順
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
  { _id : 0, host : "%IP%:20011" }, 
  { _id : 1, host : "%IP%:20012" }, 
  { _id : 2, host : "%IP%:20013" } ] } 
> rs.initiate(cfg)
> rs.status()

$ bin\mongo localhost:20022
> cfg = {
 _id : "rs2", 
 members : [ 
  { _id : 0, host : "%IP%:20021" }, 
  { _id : 1, host : "%IP%:20022" }, 
  { _id : 2, host : "%IP%:20023" } ] } 
> rs.initiate(cfg)
> rs.status()

$ bin\mongo localhost:20033
> cfg = {
 _id : "rs3", 
 members : [ 
  { _id : 0, host : "%IP%:20031" }, 
  { _id : 1, host : "%IP%:20032" }, 
  { _id : 2, host : "%IP%:20033" } ] } 
> rs.initiate(cfg)
> rs.status()

$ mkdir data\config
$ start "config" bin\mongod --configsvr --port 10001 --dbpath data\config --rest
$ start "mongos" bin\mongos --configdb %IP%:10001 --port 10000 --chunkSize 1

$ bin\mongo localhost:10000
> use admin
> db.runCommand({addshard:"rs1/%IP%:20011,%IP%:20012,%IP%:20013"})
> db.runCommand({addshard:"rs2/%IP%:20021,%IP%:20022,%IP%:20023"})
> db.runCommand({addshard:"rs3/%IP%:20031,%IP%:20032,%IP%:20033"})
> db.printShardingStatus();

> use logdb
> for(var i=1; i<=1000000; i++) db.logs.insert({"uid":i, "value":Math.floor(Math.random()*100000+1)})
> db.logs.count();
> db.logs.ensureIndex( { uid : 1 } );  

> use admin
> db.runCommand( { enablesharding : "logdb" });  
> db.runCommand( { shardcollection : "logdb.logs" , key : { uid : 1 } } );
> db.printShardingStatus();

```

## Bash用
```
mkdir -p /tmp/mongodb/data/config
mkdir -p /tmp/mongodb/log
mkdir -p /tmp/mongodb/data/node12
mkdir -p /tmp/mongodb/data/node13
mkdir -p /tmp/mongodb/data/node14

mkdir -p /tmp/mongodb/data/node21
mkdir -p /tmp/mongodb/data/node22
mkdir -p /tmp/mongodb/data/node23

mkdir -p /tmp/mongodb/data/node31
mkdir -p /tmp/mongodb/data/node32
mkdir -p /tmp/mongodb/data/node33

./bin/mongod --replSet rs1 --port 20011 --dbpath=/tmp/mongodb/data/node11 --logpath=/tmp/mongodb/log/node11 --rest
./bin/mongod --replSet rs1 --port 20012 --dbpath=/tmp/mongodb/data/node12  --logpath=/tmp/mongodb/log/node12 --rest
./bin/mongod --replSet rs1 --port 20013 --dbpath=/tmp/mongodb/data/node13  --logpath=/tmp/mongodb/log/node13 --rest

./bin/mongod --replSet rs2 --port 20021 --dbpath=/tmp/mongodb/data/node21  --logpath=/tmp/mongodb/log/node21 --rest
./bin/mongod --replSet rs2 --port 20022 --dbpath=/tmp/mongodb/data/node22  --logpath=/tmp/mongodb/log/node22 --rest
./bin/mongod --replSet rs2 --port 20023 --dbpath=/tmp/mongodb/data/node23  --logpath=/tmp/mongodb/log/node23 --rest 
  
./bin/mongod --replSet rs3 --port 20031 --dbpath=/tmp/mongodb/data/node31  --logpath=/tmp/mongodb/log/node31  --rest
./bin/mongod --replSet rs3 --port 20032 --dbpath=/tmp/mongodb/data/node32  --logpath=/tmp/mongodb/log/node32  --rest
./bin/mongod --replSet rs3 --port 20033 --dbpath=/tmp/mongodb/data/node33  --logpath=/tmp/mongodb/log/node33  --rest 

./bin/mongod --configsvr --port 10001 --dbpath /tmp/mongodb/data/config --rest &
./bin/mongos --configdb 10.0.2.1:10001 --port 10000 --logpath=/tmp/mongodb/log/mongos --chunkSize 1 &
```


[step3へ](https://github.com/syokenz/marunouchi-mongodb/tree/master/20120926/fetarodc/step3)
