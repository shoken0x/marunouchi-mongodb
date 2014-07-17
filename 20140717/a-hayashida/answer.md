0系の人の答えの手順

```

■host1
$ sudo su -
# mkdir /data0 /data0/node11 /data0/node21 /data0/node31
# mongod --replSet rs1 --port 20011 --dbpath /data0/node11 --rest --nojournal
# mongod --replSet rs2 --port 20021 --dbpath /data0/node21 --rest --nojournal
# mongod --replSet rs3 --port 20031 --dbpath /data0/node31 --rest --nojournal

$ mongo localhost:20011
> cfg = {
 _id : "rs1", 
 members : [ 
  { _id : 0, host : "%host1-IP%:20011" }, 
  { _id : 1, host : "%host2-IP%:20012" }, 
  { _id : 2, host : "%host3-IP%:20013" } ] } 
> rs.initiate(cfg)
> rs.status()


■host2
$ sudo su -
# mkdir /data0 /data0/node12 /data0/node22 /data0/node32
# mongod --replSet rs1 --port 20012 --dbpath /data0/node12 --rest --nojournal
# mongod --replSet rs2 --port 20022 --dbpath /data0/node22 --rest --nojournal
# mongod --replSet rs3 --port 20032 --dbpath /data0/node32 --rest --nojournal

$ mongo localhost:20022
> cfg = {
 _id : "rs2", 
 members : [ 
  { _id : 0, host : "%host1-IP%:20021" }, 
  { _id : 1, host : "%host2-IP%:20022" }, 
  { _id : 2, host : "%host3-IP%:20023" } ] } 
> rs.initiate(cfg)
> rs.status()

■host3
$ sudo su -
# mkdir /data0 /data0/node13 /data0/node23 /data0/node33
# mongod --replSet rs1 --port 20013 --dbpath /data0/node13 --rest --nojournal
# mongod --replSet rs2 --port 20023 --dbpath /data0/node23 --rest --nojournal
# mongod --replSet rs3 --port 20033 --dbpath /data0/node33 --rest --nojournal

$ mongo localhost:20033
> cfg = {
 _id : "rs3", 
 members : [ 
  { _id : 0, host : "%host1-IP%:20031" }, 
  { _id : 1, host : "%host2-IP%:20032" }, 
  { _id : 2, host : "%host3-IP%:20033" } ] } 
> rs.initiate(cfg)
> rs.status()

■host0(mongosサーバ)
$ sudo su -
# mkdir /data0/config
# mongod --configsvr --port 10001 --dbpath /data0/config --rest
# mongos --configdb %IP%:10001 --port 10000 --chunkSize 1

$ mongo localhost:10000
> use admin
> db.runCommand({addshard:"rs1/%host1-IP%:20011,%host2-IP%:20012,%host3-IP%:20013"})
> db.runCommand({addshard:"rs2/%host1-IP%:20021,%host2-IP%:20022,%host3-IP%:20023"})
> db.runCommand({addshard:"rs3/%host1-IP%:20031,%host2-IP%:20032,%host3-IP%:20033"})
> db.printShardingStatus();

> use logdb
> for(var i=1; i<=100000; i++) db.logs.insert({"uid":i, "value":Math.floor(Math.random()*100000+1)})
> db.logs.count();
> db.logs.ensureIndex( { uid : 1 } );  

> use admin
> db.runCommand( { enablesharding : "logdb" });  
> db.runCommand( { shardcollection : "logdb.logs" , key : { uid : 1 } } );
> db.printShardingStatus();

```


1系の人の答えの手順

```

■host1
$ sudo su -
# mkdir /data1 /data1/node11 /data1/node21 /data1/node31
# mongod --replSet rs1 --port 20111 --dbpath /data1/node11 --rest --nojournal
# mongod --replSet rs2 --port 20121 --dbpath /data1/node21 --rest --nojournal
# mongod --replSet rs3 --port 20131 --dbpath /data1/node31 --rest --nojournal

$ mongo localhost:20111
> cfg = {
 _id : "rs1", 
 members : [ 
  { _id : 0, host : "%host1-IP%:20111" }, 
  { _id : 1, host : "%host2-IP%:20112" }, 
  { _id : 2, host : "%host3-IP%:20113" } ] } 
> rs.initiate(cfg)
> rs.status()


■host2
$ sudo su -
# mkdir /data1 /data1/node12 /data1/node22 /data1/node32
# mongod --replSet rs1 --port 20112 --dbpath /data1/node12 --rest --nojournal
# mongod --replSet rs2 --port 20122 --dbpath /data1/node22 --rest --nojournal
# mongod --replSet rs3 --port 20132 --dbpath /data1/node32 --rest --nojournal

$ mongo localhost:20122
> cfg = {
 _id : "rs2", 
 members : [ 
  { _id : 0, host : "%host1-IP%:20121" }, 
  { _id : 1, host : "%host2-IP%:20122" }, 
  { _id : 2, host : "%host3-IP%:20123" } ] } 
> rs.initiate(cfg)
> rs.status()

■host3
$ sudo su -
# mkdir /data1 /data1/node13 /data1/node23 /data1/node33
# mongod --replSet rs1 --port 20113 --dbpath /data1/node13 --rest --nojournal
# mongod --replSet rs2 --port 20123 --dbpath /data1/node23 --rest --nojournal
# mongod --replSet rs3 --port 20133 --dbpath /data1/node33 --rest --nojournal

$ mongo localhost:20133
> cfg = {
 _id : "rs3", 
 members : [ 
  { _id : 0, host : "%host1-IP%:20131" }, 
  { _id : 1, host : "%host2-IP%:20132" }, 
  { _id : 2, host : "%host3-IP%:20133" } ] } 
> rs.initiate(cfg)
> rs.status()

■host0(mongosサーバ)
$ sudo su -
# mkdir /data1/config
# mongod --configsvr --port 10101 --dbpath /data1/config --rest
# mongos --configdb %IP%:10101 --port 10100 --chunkSize 1

$ mongo localhost:10100
> use admin
> db.runCommand({addshard:"rs1/%host1-IP%:20111,%host2-IP%:20112,%host3-IP%:20113"})
> db.runCommand({addshard:"rs2/%host1-IP%:20121,%host2-IP%:20122,%host3-IP%:20123"})
> db.runCommand({addshard:"rs3/%host1-IP%:20131,%host2-IP%:20132,%host3-IP%:20133"})
> db.printShardingStatus();

> use logdb
> for(var i=1; i<=100000; i++) db.logs.insert({"uid":i, "value":Math.floor(Math.random()*100000+1)})
> db.logs.count();
> db.logs.ensureIndex( { uid : 1 } );  

> use admin
> db.runCommand( { enablesharding : "logdb" });  
> db.runCommand( { shardcollection : "logdb.logs" , key : { uid : 1 } } );
> db.printShardingStatus();

```
