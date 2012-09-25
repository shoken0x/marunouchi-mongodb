みんなでクラスタ
=================

さあ！このシステムを４人一組で組んでください！

物理構成図

![物理構成図](https://cacoo.com/diagrams/CQcA9aJslOwzpU6K-EBC21.png)

論理構成図

![論理構成図](https://cacoo.com/diagrams/kyoRpiZSDLv6f2lQ-EBC21.png)

手順

```

■サーバ１
$ mkdir data\ data\node11 data\node21 data\node31

$ start "node11" bin\mongod.exe --replSet rs1 --port 20011 --dbpath=data/node11 --rest
$ start "node21" bin\mongod.exe --replSet rs2 --port 20021 --dbpath=data/node21 --rest
$ start "node31" bin\mongod.exe --replSet rs3 --port 20031 --dbpath=data/node31 --rest

$ bin\mongo localhost:20011
> cfg = {
 _id : "rs1", 
 members : [ 
  { _id : 0, host : "%IP%:20011" }, 
  { _id : 1, host : "%IP%:20012" }, 
  { _id : 2, host : "%IP%:20013" } ] } 
> rs.initiate(cfg)
> rs.status()


■サーバ２
$ mkdir data\ data\node12 data\node22 data\node32
$ start "node12" bin\mongod.exe --replSet rs1 --port 20012 --dbpath=data/node12 --rest
$ start "node22" bin\mongod.exe --replSet rs2 --port 20022 --dbpath=data/node22 --rest
$ start "node32" bin\mongod.exe --replSet rs3 --port 20032 --dbpath=data/node32 --rest

$ bin\mongo localhost:20021
> cfg = {
 _id : "rs2", 
 members : [ 
  { _id : 0, host : "%IP%:20021" }, 
  { _id : 1, host : "%IP%:20022" }, 
  { _id : 2, host : "%IP%:20023" } ] } 
> rs.initiate(cfg)
> rs.status()

■サーバ３
$ mkdir data\ data\node13 data\node23 data\node33
$ start "node13" bin\mongod.exe --replSet rs1 --port 20013 --dbpath=data/node13 --rest
$ start "node33" bin\mongod.exe --replSet rs3 --port 20033 --dbpath=data/node33 --rest
$ start "node23" bin\mongod.exe --replSet rs2 --port 20023 --dbpath=data/node23 --rest

$ bin\mongo localhost:20031
> cfg = {
 _id : "rs3", 
 members : [ 
  { _id : 0, host : "%IP%:20031" }, 
  { _id : 1, host : "%IP%:20032" }, 
  { _id : 2, host : "%IP%:20033" } ] } 
> rs.initiate(cfg)
> rs.status()

■mongosサーバ

$ mkdir data\config
$ start "config" bin\mongod --configsvr --port 10001 --dbpath data\config --rest
$ start "mongos" bin\mongos --configdb duo:10001 --port 10000 --chunkSize 1

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