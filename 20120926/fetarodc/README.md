MongoDB レプリケーション(Replica Sets)
=================


make directory

```
mkdir data
mkdir data\1
mkdir data\2
mkdir data\3
mkdir log
```
start mongod

```
start "rep1" bin\mongod.exe --replSet test_rep --port 20001 --dbpath=data/1 --logpath logs\1.log --rest
start "rep2" bin\mongod.exe --replSet test_rep --port 20002 --dbpath=data/2 --logpath logs\2.log --rest
start "rep3" bin\mongod.exe --replSet test_rep --port 20003 --dbpath=data/3 --logpath logs\3.log --rest
```

check

```
tasklist | findstr mongo
mongod.exe                   10712 Console                    1     66,116 K
mongod.exe                    8732 Console                    1     69,344 K
mongod.exe                   11100 Console                    1     68,308 K
```

http://localhost:21001/

make Replica set

```
bin\mondod localhost:20001
rs.initiate()
{
        "info2" : "no configuration explicitly specified -- making one",
        "me" : "kotaro:20001",
        "info" : "Config now saved locally.  Should come online in about a minute.",
        "ok" : 1
}
```

```
rs.conf()
{
        "_id" : "test_rep",
        "version" : 1,
        "members" : [
                {
                        "_id" : 0,
                        "host" : "kotaro:20001"
                }
        ]
}
```

add Replica node
```
test_rep:PRIMARY> rs.add("kotaro:20002")
test_rep:PRIMARY> rs.add("kotaro:20003")
```

if use "localhost" insted of hostname
```
test_rep:PRIMARY> rs.add("localhost:20002")
{
        "errmsg" : "exception: can't use localhost in repl set member names except when using it for all members",
        "code" : 13393,
        "ok" : 0
}
```

check

```
test_rep:PRIMARY> rs.status()
```

insert data to primary

```
for(var i=1; i<=100000; i++) db.logs.insert({"uid":i, "value":Math.floor(Math.random()*100000+1)})
```

check

```
c:\work\mongodb\mongodb>bin\mongo localhost:20002
MongoDB shell version: 2.2.0
connecting to: localhost:20002/test
test_rep:SECONDARY> show dbs
local   4.201171875GB
mydb    0.203125GB
test_rep:SECONDARY>
```

```
test_rep:SECONDARY> show collections
Mon Sep 17 14:27:13 uncaught exception: error: { "$err" : "not master and slaveOk=false", "code" : 13435 }
```

use setSlaveOk command

```
test_rep:SECONDARY> db.getMongo().setSlaveOk()
```

* db.getMongo().setSlaveOk() allow this connection to read from the nonmaster member of a replica pair

```
test_rep:SECONDARY> db.logs.count();
100000
```

fail over

kill 20001

```
c:\work\mongodb\mongodb>bin\mongo localhost:20002
test_rep:SECONDARY> rs.status();
```
recover

```
c:\work\mongodb\mongodb>start "rep1" bin\mongod.exe --replSet test_rep --journal --port 20001 --logappend --logpath logs\1.log --dbpath=data/1
c:\work\mongodb\mongodb>bin\mongo localhost:20002
test_rep:SECONDARY> rs.status();
```


routing

http://www.mongodb.org/display/DOCS/Replica+Sets


start config server and mogos server

start "config" bin\mongod --configsvr --port 10001 --dbpath data\config --rest
start "mongos" bin\mongos --configdb localhost:10001 --port 10000 --chunkSize 1

```
bin\mongo localhost:10000
mongos> use admin
mongos> db.runCommand({addshard:"test_rep/kotaro:20001,kotaro:20002,kotaro:20003"});
{ "shardAdded" : "test_rep", "ok" : 1 }
mongos> db.printShardingStatus();
--- Sharding Status ---
  sharding version: { "_id" : 1, "version" : 3 }
  shards:
        {  "_id" : "test_rep",  "host" : "test_rep/kotaro:20001,kotaro:20002,kotaro:20003" }
  databases:
        {  "_id" : "admin",  "partitioned" : false,  "primary" : "config" }
        {  "_id" : "mydb",  "partitioned" : false,  "primary" : "test_rep" }
```


insert data to primary

```
mongos> user mydb
mongos> for(var i=1; i<=100000; i++) db.logs.insert({"uid":i, "value":Math.floor(Math.random()*100000+1)})
mongos> db.logs.count()
```

kill 20001

```
mongos> db.logs.count()
Mon Sep 17 15:38:33 uncaught exception: count failed: {
        "errmsg" : "exception: socket exception [SEND_ERROR] for 192.168.6.1:20001",
        "code" : 9001,
        "ok" : 0
}
mongos> db.logs.count()
Mon Sep 17 15:38:38 uncaught exception: count failed: {
        "errmsg" : "exception: socket exception [CONNECT_ERROR] for test_rep/kotaro:20001,kotaro:20002,kotaro:20003",
        "code" : 11002,
        "ok" : 0
}
mongos> db.logs.count()
200000
```
