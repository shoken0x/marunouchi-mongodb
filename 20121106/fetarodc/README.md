Configパラメータ解説
=================

オプションの設定の仕方
-----------------

ここを解説します
http://docs.mongodb.org/manual/reference/configuration-options/

```
 options: { config: "mongodb.conf", dbpath: "db/", noscripting: "true", notablescan: "true", nssize: 32, profile: 2 }
```

パラメータ解説
-----------------

### verbose
Default: false

ログに詳細に情報を表示する。

さらに詳細な情報がほしければ、以下のようにvの文字を増やして設定する。

コマンドライン
```
mongod --vervose # ( mongod -v と同じ)
mongod -vv
mongod -vvv
mongod -vvvv
mongod -vvvvv
```

設定ファイル
```
verbose = true # (v = trueと同じ)
vv = true
vvv = true
vvvv = true
vvvvv = true
```

### quiet
Default: false

mongodとmongosのログを少なくする。以下のものを出力する。

* 次のコマンド結果 drop, dropIndex, diagLogging, validate, clean.
* レプリケーションの状態
* 接続受付
* 接続解除

### port
Default: 27017

### bind_ip
Default: All interfaces.
","区切りで複数指定可能

### maxConns 
Default: depends on system limit

OSのulimitやファイルディスクリプタの制限がなければいくらでも作ることができる
少なくとも5以上

動作確認
```
Sat Nov  3 11:57:17 [initandlisten] connection accepted from 192.168.1.42:32934 #1 (1 connection now open)
Sat Nov  3 11:57:31 [initandlisten] connection accepted from 192.168.1.42:32935 #2 (2 connections now open)
Sat Nov  3 11:57:32 [initandlisten] connection accepted from 192.168.1.42:32936 #3 (3 connections now open)
Sat Nov  3 11:57:33 [initandlisten] connection accepted from 192.168.1.42:32937 #4 (4 connections now open)
Sat Nov  3 11:57:33 [initandlisten] connection accepted from 192.168.1.42:32938 #5 (5 connections now open)
Sat Nov  3 11:57:35 [initandlisten] connection accepted from 192.168.1.42:32939 #6 (6 connections now open)
Sat Nov  3 11:57:35 [initandlisten] connection refused because too many open connections: 5
```

### objcheck
Default: false

ユーザのリクエストをvalidateして、不正なBSONオブジェクトの挿入を防ぐ。
オーバーヘッドがあるためデフォルトはfalse

validateはシェルからも実行可能で、db.users.validate(); などと打つ。

### logpath

Default: None. (i.e. /dev/stdout)
ログパス。
logappendを指定しないと上書きしてしまう。
ただしこの動きは近いうちに代わり、古いログはローテーションするようになるかも

###  logappend

Default: false
ログに上書きするかどうか

###  syslog
ログをsyslogに出す。lopathと併用してはダメ。

###  pidfilepath
Default: None.
デフォルトだとPIDファイル作らない

### keyFile
Default: None.
レプリカセットやシャーディングのメンバで認証するための情報
openSSLのコマンドで作るとよい

[root@haruko mongodb-linux-x86_64-2.2.1]# openssl rand -base64 17
RYVwrEwolKmnTgjiNGHyxRk=

詳しくは
http://docs.mongodb.org/manual/administration/replica-sets/#replica-set-security


### nounixsocket

```
# ./bin/mongod --dbpath db --nounixsocket &
# netstat -na | grep 27017
tcp        0      0 0.0.0.0:27017               0.0.0.0:*                   LISTEN

./bin/mongod --dbpath db &
# netstat -na | grep 27017
tcp        0      0 0.0.0.0:27017               0.0.0.0:*                   LISTEN
unix  2      [ ACC ]     STREAM     LISTENING     167023 /tmp/mongodb-27017.sock
```

### unixSocketPrefix
Default: /tmp

### fork
Default: false
バックグラウンドで動かす
--logpath or --syslog が必要

### auth
Default: false
認証を有効にする。

> use admin
> db.addUser("i2bs","secret")
> db.system.users.find()
bin/mongo mydb -u i2bs -p secret

### cpu
Default: false
4秒おきにcpu使用率を記録
```
Sat Nov  3 12:47:16 [snapshotthread] cpu: elapsed:4000  writelock: 0%
Sat Nov  3 12:47:20 [snapshotthread] cpu: elapsed:4000  writelock: 0%
Sat Nov  3 12:47:24 [snapshotthread] cpu: elapsed:4000  writelock: 0%
```

### dbpath
Default: /data/db/

パッケージマネジメントシステムでインストールすると/etc/mongodb.confに書いてあるdbpathを使う


### diaglog
Default: 0

トラブルシューティングで使うようなバイナリログを出す。
出す場所はdbpath

* Value   Setting
* 0 	off. No logging.
* 1 	Log write operations.
* 2 	Log read operations.
* 3 	Log both read and write operations.
* 7 	Log write and some read operations.

mongosniffという専用コマンドでバイナリファイルを読める

mongosniff --source DIAGLOG /data/db/diaglog.4f76a58c

diaglogは内部利用が主で、普通のユーザは使わない。

注意: diaglog = 0と指定する、何も出力されないが、diaglogファイルはできる。
      diaglog自体を指定しなければ、そもそもdiaglogファイルはできない。

###  directoryperdb
データベースごとにデータファイルを作る

動作検証

二つのDBを作る
```
> use test1
> db.col1.insert( { name : "fetaro" } )
> use test2
> db.col2.insert( { name : "syokenz" } )
> exit
```

設定なし

```
# ls db/
_tmp  journal  mongod.lock  test1.0  test1.1  test1.ns  test2.0  test2.1  test2.ns
```

設定あり

```
# ls db/
_tmp  journal  mongod.lock  test1  test2
```

###  journal
Default: (on 64-bit systems) true

Default: (on 32-bit systems) false

trueだとジャーナルを確実に永続化し、一貫性を保つ。

一貫性を保証しなくてもよい場合はfalseでもよい。そのほうがオーバーヘッドがない。

ジャーナル書き込みによるディスクへの影響を減らしたい場合は、

ジャーナルのレベルを変えて、smallfilesをtrueにしてジャーナルファイルのデータ量を減らすとよい。

### journalCommitInterval
Default: 100 (msec)

ジャーナルを書き込む間隔(msec)。減らすとディスクへの負荷が減る
2～300の間で変更可能

###  ipv6
Default: false


### jsonp
Default: false
HTTPのインターフェースを通してJSONPを許可する。これをtrueにする前にセキュリティを考えよう。

JSONPはscriptタグを使用してクロスドメインなデータを取得する仕組み。詳しくはググりましょう。

### noauth
authの逆

### nohttpinterface
Default: false

HTTPインターフェースの無効化。
restのオプションで上書きされる。

### nojournal
journalの逆

### noprealloc
Default: false

データファイルを分割しなくなる。スタートアップが早くなることがあるが、普通の操作が遅くなることがあるかも

### noscripting
Default: false

スクリプトエンジンを無効にする（？？？）

### notablescan
Default: false

テーブルスキャンするオペレーションを禁止する（？？？）

### nssize
Default: 16 (MByte)

ネームスペースファイルのデフォルトサイズを変える。既存のものには影響なし。

16Mだと12000のネームスペースに有効。MAXは12G

### profile
Default: 0

プロファイラのレベル。以下のレベルを指定可能

0  Off. No profiling.
1 	On. Only includes slow operations.
2 	On. Includes all operations.

http://www.mongodb.org/display/DOCS/Database+Profiler

動作検証
設定なし
```
> db.system.profile.find()
→何も出力はない
```

設定あり（レベルを２に指定して、mongos shellから以下のコマンドを打つといろいろでる。）
```
> db.system.profile.find()
{ "ts" : ISODate("2012-11-04T02:33:51.438Z"), "op" : "insert", "ns" : "logdb.logs", "keyUpdates" : 0, "numYield" : 0, "lockStats" : { "timeLockedMicros" : { "r" : NumberLong(0), "w" : NumberLong(7) }, "timeAcquiringMicros" : { "r" : NumberLong(0), "w" : NumberLong(1) } }, "millis" : 0, "client" : "127.0.0.1", "user" : "" }
{ "ts" : ISODate("2012-11-04T02:33:51.438Z"), "op" : "insert", "ns" : "logdb.logs", "keyUpdates" : 0, "numYield" : 0, "lockStats" : { "timeLockedMicros" : { "r" : NumberLong(0), "w" : NumberLong(8) }, "timeAcquiringMicros" : { "r" : NumberLong(0), "w" : NumberLong(2) } }, "millis" : 0, "client" : "127.0.0.1", "user" : "" }
```

### quota
Default: false
データベースファイルごとにデータ数に制限をかける。

### quotaFiles
Default: 8

データベールごとにデータベースファイル数を制限する。

データベースファイルが８個だと容量はどうなるか？

データベースファイルは64Mがスタートで、倍倍で容量が増えていく。らしい。
http://www.slideshare.net/mdirolf/inside-mongodb-the-internals-of-an-opensource-database

つまり、８個ファイルがあるということはほぼ16G

64M + 128M + ・・・ + 8192M = 64 * (2^8 - 1) / (2 - 1) = 16363M ≒ 16G

動作確認

クオータを1に設定して以下のように挿入しまくると、やがてquota exceededが出ます。
```
> for(var i=1; i<=100000000; i++) db.logs.insert({"uid":i, "value":Math.random()*100000})
quota exceeded
```

### rest
Default: false

restインターフェースを有効にする。

http://192.168.1.27:28017/(DB名)/とかでアクセスできます。

詳しくは

http://www.mongodb.org/display/DOCS/Http+Interface#HttpInterface-SimpleRESTInterface

###  repair
Default: false

サーバがクラッシュした時にデータ等をリペアする。fsckに似てる。

実行するとリペアして終わりなので、その後mongodを別に立ち上げる必要あり。

詳しくは参照

http://www.mongodb.org/pages/viewpage.action?pageId=7831701


### repairpath
Default: dbpath

リペアするDBパスを指定



### slowms
Default: 100 [msrc]

DBのプロファイラがクエリが"slow"と判断する閾値。

* プロファイラがOFFの場合、全ての"slow"なクエリをログに出力（？？？）
* プロファイラがONの場合、system.profile collectionに出力（？？？）

動作確認

値が10の場合
```
Sun Nov  4 12:33:35 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:33 18ms
Sun Nov  4 12:33:35 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:35 14ms
Sun Nov  4 12:33:35 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:32 17ms
Sun Nov  4 12:33:35 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:33 18ms
Sun Nov  4 12:33:36 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:25 18ms
Sun Nov  4 12:33:36 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:14 17ms
Sun Nov  4 12:33:36 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:10 18ms
Sun Nov  4 12:33:36 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:13 43ms
Sun Nov  4 12:33:36 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:22 42ms
Sun Nov  4 12:33:36 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:18 30ms
Sun Nov  4 12:33:37 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:34 14ms
Sun Nov  4 12:33:37 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:20 18ms
```
値が20の場合
```
Sun Nov  4 12:34:14 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:31 50ms
Sun Nov  4 12:34:14 [conn1] insert logdb.logs keyUpdates:0 locks(micros) w:38 27ms
Sun Nov  4 12:34:15 [conn1] insert logdb.logs keyUpdates:0  63ms
```


#smallfiles
Default: false

データファイルサイズを小さくする。設定すると
* データファイルの最大サイズは512Mになる
* ジャーナルファイルは1Gから128Mになる

もし、データの大きさが小さいならsmallfilesを設定したほうがパフォーマンスが上がる。

動作検証

設定前
```
#ls -lh db
 64M logdb.0
128M logdb.1
256M logdb.2
```

設定後
```
#ls -lh db
 16M logdb.0
 32M logdb.1
 64M logdb.2
```

### syncdelay
Default: 60 [sec]

この設定値は、ディスクへの書き込みをflash(保留しているデータを書き込む)の最大時間。

この時間内はディスクが壊れるとデータを破損する可能性がある。

多くの場合、実際のディスクへの書き込み間隔はもっと小さい。

0に設定するとmongodは即時ディスク書き込みをするが、パフォーマンスは低下する。

journalを設定している場合、journalCommitIntervalの時間内であれば、すべての書き込みは保証される。


### sysinfo
Default: false

以下のような物理ページ数などの情報を出力する。出力するだけで終わる（DBはスタートしない）。

```
# bin/mongod --sysinfo
Sun Nov  4 12:51:06 sysinfo:
Sun Nov  4 12:51:06   page size: 4096          # ページサイズ
Sun Nov  4 12:51:06   _SC_PHYS_PAGES: 980711   # ページ数
Sun Nov  4 12:51:06   _SC_AVPHYS_PAGES: 726548 # 利用可能なページ数
```

###upgrade
Default: false

dbpathで指定されたデータファイルのフォーマットを最新版にアップデートする。

古いフォーマットの時にだけ有効。

mongosにこのオプションを渡すと、config databaseのフォーマットをアップデートする。

Note: 勝手にアップデートされてしまうので、普通はこのオプションは使うべきではない。


### traceExceptions
Default: false

diagnosticを使っているときに、例外をトレースする。一般ユーザは使わない。内部利用。

# Replication Options

### replSet

    Default: <none>

    Form: <setname>

    Use this setting to configure replication with replica sets. Specify a replica set name as an argument to this set. All hosts must have the same set name.

    See also

    “Replication,” “Replica Set Administration,” and “Replica Set Configuration“

### oplogSize

    Specifies a maximum size in megabytes for the replication operation log (e.g. oplog.) mongod creates an oplog based on the maximum amount of space available. For 64-bit systems, the oplog is typically 5% of available disk space.

    Once the mongod has created the oplog for the first time, changing oplogSize will not affect the size of the oplog.

### fastsync

    Default: false

    In the context of replica set replication, set this option to true if you have seeded this replica with a snapshot of the dbpath of another member of the set. Otherwise the mongod will attempt to perform a full sync.

    Warning

    If the data is not perfectly synchronized and mongod starts with fastsync, then the secondary or slave will be permanently out of sync with the primary, which may cause significant consistency problems.

### replIndexPrefetch

    New in version 2.2.

    Default: all

    Values: all, none, and _id_only

    You must use replIndexPrefetch in conjunction with replSet.

    By default secondary members of a replica set will load all indexes related to an operation into memory before applying operations from the oplog. You can modify this behavior so that the secondaries will only load the _id index. Specify _id_only or none to prevent the mongod from loading any index into memory.

# Master/Slave Replication

### master

    Default: false

    Set to true to configure the current instance to act as master instance in a replication configuration.

### slave

    Default: false

    Set to true to configure the current instance to act as slave instance in a replication configuration.

### source

    Default: <>

    Form: <host>:<port>

    Used with the slave setting to specify the master instance from which this slave instance will replicate

### only

    Default: <>

    Used with the slave option, the only setting specifies only a single database to replicate.

### slavedelay

    Default: 0

    Used with the slave setting, the slavedelay setting configures a “delay” in seconds, for this slave to wait to apply operations from the master instance.

### autoresync

    Default: false

    Used with the slave setting, set autoresync to true to force the slave to automatically resync if the is more than 10 seconds behind the master. This setting may be problematic if the --oplogSize oplog is too small (controlled by the --oplogSize option.) If the oplog not large enough to store the difference in changes between the master’s current state and the state of the slave, this instance will forcibly resync itself unnecessarily. When you set the autoresync option, the slave will not attempt an automatic resync more than once in a ten minute period.

# Sharding Cluster Options

### configsvr

    Default: false

    Set this value to true to configure this mongod instance to operate as the config database of a shard cluster. When running with this option, clients will not be able to write data to any database other than config and admin. The default port for :program:`mongod` with this option is ``27019 and mongod writes all data files to the /configdb sub-directory of the dbpath directory.

### shardsvr

    Default: false

    Set this value to true to configure this mongod instance as a shard in a partitioned cluster. The default port for these instances is 27018. The only affect of shardsvr is to change the port number.

### noMoveParanoia

    Default: false

    When set to true, noMoveParanoia disables a “paranoid mode” for data writes for chunk migration operation. See the chunk migration and moveChunk command documentation for more information.

    By default mongod will save copies of migrated chunks on the “from” server during migrations as “paranoid mode.” Setting this option disables this paranoia.

### configdb

    Default: None.

    Format: <config1>,<config2><:port>,<config3>

    Set this option to specify a configuration database (i.e. config database) for the sharded cluster. You must specify either 1 configuration server or 3 configuration servers, in a comma separated list.

    This setting only affects mongos processes.

### test

    Default: false

    Only runs unit tests and does not start a mongos instance.

    This setting only affects mongos processes and is for internal testing use only.

### chunkSize

    Default: 64

    The value of this option determines the size of each chunk of data distributed around the sharded cluster. The default value is 64 megabytes. Larger chunks may lead to an uneven distribution of data, while smaller chunks may lead to frequent and unnecessary migrations. However, in some circumstances it may be necessary to set a different chunk size.

    This setting only affects mongos processes. Furthermore, chunkSize only sets the chunk size when initializing the cluster for the first time. If you modify the run-time option later, the new value will have no effect. See the “Modify Chunk Size” procedure if you need to change the chunk size on an existing sharded cluster.

### localThreshold
    New in version 2.2.

    localThreshold affects the logic that program:mongos uses when selecting replica set members to pass reads operations to from clients. Specify a value to localThreshold in milliseconds. The default value is 15, which corresponds to the default value in all of the client drivers.

    This setting only affects mongos processes.

    When mongos receives a request that permits reads to secondary members, the mongos will:

            find the member of the set with the lowest ping time.

            construct a list of replica set members that is within a ping time of 15 milliseconds of the nearest suitable member of the set.

            If you specify a value for localThreshold, mongos will construct the list of replica members that are within the latency allowed by this value.

            The mongos will select a member to read from at random from this list.

    The ping time used for a set member compared by the --localThreshold setting is a moving average of recent ping times, calculated, at most, every 10 seconds. As a result, some queries may reach members above the threshold until the mongos recalculates the average.

    See the Member Selection section of the read preference documentation for more information.
