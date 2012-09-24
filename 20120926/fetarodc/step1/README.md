レプリカセットを試す
=================

(Windowsのコマンドプロンプトで実行する用のコマンドを書いています。bashな人はよしなに読み替えてください)

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
※）start "str" はコマンドを別ウインドウで立ち上げて、ウインドウ名に"str"をつけるコマンドです


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


プライマリの障害実験（フェイルオーバ）
-----------------

Primaryのmongod(ポート20001のmongod)のプロセスを殺します。（好きな方法で殺しください)

他のmongod(例えばポート20002のプロセス)にログインして、Primaryが移動したか確認します。

```
$ bin\mongo localhost:20002
> rs.status();
```

webのインターフェースからも確認できます→http://localhost:21002



レプリカセットへの参加（フェイルバック）
-----------------

プロセスを上げるだけ

```
$ start "node1" bin\mongod.exe --replSet rs1 --port 20001 --dbpath=data/node1 --rest
$ bin\mongo localhost:20002
> rs.status();
```

[step2へ](https://github.com/syokenz/marunouchi-mongodb/tree/master/20120926/fetarodc/step2)

