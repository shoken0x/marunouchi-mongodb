レプリカセットを試す
=================

(Windowsのコマンドプロンプトで実行する用のコマンドを書いています。bashな人はよしなに読み替えてください)

データディレクトリ作成

```
$ cd (mongodb install directory)
$ mkdir data data\node1 data\node2 data\node3
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
> cfg = {
 _id : "rs1", 
 members : [ 
  { _id : 0, host : "%IP%:20001" }, 
  { _id : 1, host : "%IP%:20002" }, 
  { _id : 2, host : "%IP%:20003" } ] } 
> cfg   
(内容確認)
> rs.initiate(cfg)
{
        "info" : "Config now saved locally.  Should come online in about a minute.",
        "ok" : 1
}
```

※)%IP%の部分はループバックインターフェース(localhostや127.0.0.1)ではなく、NICについているIPを指定してください。
　ループバックインターフェースでもレプリカセットは組めますが、後のshardingとの連携ができません。

※) rs.addコマンドを使う方法もありますが、この方法だとホスト名でメンバが登録されてしまっていまいちなので、今回は使っていません。

レプリカセットのステータス確認。

```
> rs.status()
{
        "set" : "rs1",
        "date" : ISODate("2012-09-25T15:06:25Z"),
        "myState" : 1,
        "members" : [
                {
                        "_id" : 0,
                        "name" : "%IP%:20001",
                        "health" : 1,
                        "state" : 1,
                        "stateStr" : "PRIMARY",
                        "uptime" : 132,
                        "optime" : Timestamp(1348585543000, 1),
                        "optimeDate" : ISODate("2012-09-25T15:05:43Z"),
                        "self" : true
                },
                {
                        "_id" : 1,
                        "name" : "%IP%:20002",
                        "health" : 1,
                        "state" : 3,
                        "stateStr" : "RECOVERING",
                        "uptime" : 42,
                        "optime" : Timestamp(0, 0),
                        "optimeDate" : ISODate("1970-01-01T00:00:00Z"),
                        "lastHeartbeat" : ISODate("2012-09-25T15:06:25Z"),
                        "pingMs" : 532
                },
                {
                        "_id" : 2,
                        "name" : "%IP%:20003",
                        "health" : 1,
                        "state" : 2,
                        "stateStr" : "SECONDARY",
                        "uptime" : 42,
                        "optime" : Timestamp(1348585543000, 1),
                        "optimeDate" : ISODate("2012-09-25T15:05:43Z"),
                        "lastHeartbeat" : ISODate("2012-09-25T15:06:24Z"),
                        "pingMs" : 0
                }
        ],
        "ok" : 1
}
```

動作確認
-----------------

データの挿入(１０万件ほどデータを投入してみる)

(PRIMARYのmongodで実行)
```
> use mydb
> for(var i=1; i<=100000; i++) db.logs.insert({"uid":i, "value":Math.floor(Math.random()*100000+1)}) 
> db.logs.count()
100000
> db.logs.find()
```

レプリケーションされたことの確認。

Secondaryに入りなおす
```
$ exit 
$ bin\mongo localhost:20002
```

データの確認
```
> use mydb
> db.logs.count()
Wed Sep 26 00:22:52 uncaught exception: count failed: { "errmsg" : "not master", "note" : "from execCommand", "ok" : 0 }
```

何も考えずにshow collectionsするとエラーになります。
なので、setSlaveOk()コマンドを使います。

```
> db.getMongo().setSlaveOk()
> db.logs.count()
100000
> db.logs.find()
```

ちなみに、secondaryには書き込みはできません。
```
> db.logs.insert({"uid":100001, "value":123})
not master
```
※）setSlaveOk()の説明: allow this connection to read from the nonmaster member of a replica pair


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

