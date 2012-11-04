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
ログレベル
```
verbose = true
vv = true
vvv = true
vvvvv = true
quiet = true
```

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
