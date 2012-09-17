MongoDB レプリケーション(Replica Sets)
=================


make directory

```
$ cd (mongodb install directory)
$ mkdir data
$ mkdir data\node1
$ mkdir data\node2
$ mkdir data\node3
```
start mongod

```
$ start "node1" bin\mongod.exe --replSet rs1 --port 20001 --dbpath=data/node1 --rest
$ start "node2" bin\mongod.exe --replSet rs1 --port 20002 --dbpath=data/node2 --rest
$ start "node3" bin\mongod.exe --replSet rs1 --port 20003 --dbpath=data/node3 --rest
```

check

```
$ tasklist | findstr mongo (Windows)
$ ps -ef | grep mongo (Mac)
mongod.exe                   10712 Console                    1     66,116 K
mongod.exe                    8732 Console                    1     69,344 K
mongod.exe                   11100 Console                    1     68,308 K
```

http://localhost:21001/

make Replica set

```
$ bin\mongo localhost:20001
> rs.initiate()
{
        "info2" : "no configuration explicitly specified -- making one",
        "me" : "kotaro:20001", ←自ホスト名になります
        "info" : "Config now saved locally.  Should come online in about a minute.",
        "ok" : 1
}
```

http://localhost:21001/

```
> rs.status()
```

add Replica node
```
> rs.add("192.168.1.241:20002")
> rs.add("192.168.1.241:20003")
```

※） ＩＰアドレスではなく"localhost" にしてしまうと、以下のようなエラーが出ます
```
> rs.add("localhost:20002")
{
        "errmsg" : "exception: can't use localhost in repl set member names except when using it for all members",
        "code" : 13393,
        "ok" : 0
}
```

check

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
                        "name" : "192.168.1.241:20002",
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
                        "name" : "192.168.1.241:20003",
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

insert data to primary

```
for(var i=1; i<=100000; i++) db.logs.insert({"uid":i, "value":Math.floor(Math.random()*100000+1)})
```

check

```
$ exit 
$ bin\mongo localhost:20002
> show dbs
```

```
> show collections
Mon Sep 17 14:27:13 uncaught exception: error: { "$err" : "not master and slaveOk=false", "code" : 13435 }
```

use setSlaveOk command

```
> db.getMongo().setSlaveOk()
```

* db.getMongo().setSlaveOk() allow this connection to read from the nonmaster member of a replica pair

```
> db.logs.count()
100000
```

fail over

kill 20001

```
$ bin\mongo localhost:20002
> rs.status();
```
recover

```
$ start "rep1" bin\mongod.exe --replSet test_rep --journal --port 20001 --logappend --logpath logs\1.log --dbpath=data/1
$ bin\mongo localhost:20002
> rs.status();
```


routing

http://www.mongodb.org/display/DOCS/Replica+Sets


start config server and mogos server

start "config" bin\mongod --configsvr --port 10001 --dbpath data\config --rest
start "mongos" bin\mongos --configdb localhost:10001 --port 10000 --chunkSize 1

```
$ bin\mongo localhost:10000
> use admin
> db.runCommand({addshard:"test_rep/kotaro:20001,kotaro:20002,kotaro:20003"});
{ "shardAdded" : "test_rep", "ok" : 1 }
> db.printShardingStatus();
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
> user mydb
> for(var i=1; i<=100000; i++) db.logs.insert({"uid":i, "value":Math.floor(Math.random()*100000+1)})
> db.logs.count()
```

kill 20001

```
> db.logs.count()
Mon Sep 17 15:38:33 uncaught exception: count failed: {
        "errmsg" : "exception: socket exception [SEND_ERROR] for 192.168.6.1:20001",
        "code" : 9001,
        "ok" : 0
}
> db.logs.count()
Mon Sep 17 15:38:38 uncaught exception: count failed: {
        "errmsg" : "exception: socket exception [CONNECT_ERROR] for test_rep/kotaro:20001,kotaro:20002,kotaro:20003",
        "code" : 11002,
        "ok" : 0
}
> db.logs.count()
200000
```
