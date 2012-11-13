MongoDB全設定値解説
=================

このページは以下の本家のHP(ver 2.2.1時点)を解説します

http://docs.mongodb.org/manual/reference/configuration-options/

また、以下の環境に依存したオプションは省略させていただきます。（そこまで間に合いませんでした。。。）
* Replication Options
* Master/Slave Replication
* Sharding Cluster Options

概要
-----------------
mongodとmongosの設定方法は、コマンドライン引数か、もしくは設定ファイルでできます。

引数と設定ファイルの両方に同じ設定があった場合、設定ファイルが優先されます。

### コマンドライン引数の場合
```
bin/mongod --dbpath /data/db/ --verbose
```

### 設定ファイルの場合
```
verbose = true      #真偽値の場合は true|false
dbpath = /data/db/
```

### 設定ファイルの読み込み
```
mongod --config /etc/mongodb.conf
mongod -f /etc/mongodb.conf
mongos --config /srv/mongodb/mongos.conf
mongos -f /srv/mongodb/mongos.conf
```

### オプションの確認
ログに以下のようにどのオプションが設定されて起動されたかが出ます
```
Sun Nov  4 13:16:00 [initandlisten] options: { config: "mongodb.conf", dbpath: "db/", verbose: true }
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

mongodとmongosのログを少なくする。

以下のものを出力する。

* 次のコマンド結果 drop, dropIndex, diagLogging, validate, clean.
* レプリケーションの状態
* 接続受付
* 接続解除

### port
Default: 27017

待ち受けるポート番号。

### bind_ip
Default: 全てのネットワークインターフェース

待ち受けるインターフェース。

","区切りで複数指定可能。127.0.0.1を指定すればローカルからしかアクセスできなくなる。

### maxConns 
Default: OSの限界値

最大接続数。

OSのulimitやファイルディスクリプタの制限がなければいくらでも作ることができる。少なくとも5以上。

動作検証（5に設定した場合）
```
Sat Nov  3 11:57:17 [initandlisten] connection accepted from 192.168.1.42:32934 #1 (1 connection now open)
Sat Nov  3 11:57:31 [initandlisten] connection accepted from 192.168.1.42:32935 #2 (2 connections now open)
Sat Nov  3 11:57:32 [initandlisten] connection accepted from 192.168.1.42:32936 #3 (3 connections now open)
Sat Nov  3 11:57:33 [initandlisten] connection accepted from 192.168.1.42:32937 #4 (4 connections now open)
Sat Nov  3 11:57:33 [initandlisten] connection accepted from 192.168.1.42:32938 #5 (5 connections now open)
Sat Nov  3 11:57:35 [initandlisten] connection accepted from 192.168.1.42:32939 #6 (6 connections now open)
Sat Nov  3 11:57:35 [initandlisten] connection refused because too many open connections: 5   #←6つめの接続は拒否されている 
```

### objcheck
Default: false

ユーザのリクエストをvalidateして、不正なBSONオブジェクトの挿入を防ぐ。

オーバーヘッドがあるためデフォルトはfalse。ちなみに、validateはmongo shellからも実行可能で、db.users.validate()と打つとできる。

### logpath
Default: None. (標準出力に出る)

ログの出力先。

logappendを指定しないと上書きしてしまう。ただしこの動きは近いうちに代わり、古いログはローテーションするようになるかも

###  logappend
Default: false

ログに追記する。

###  syslog
Default: false

ログをsyslogに出す。

lopathと併用してはダメ。

###  pidfilepath
Default: None

PIDファイルのパス。指定しないとPIDファイルを作らない。

### keyFile
Default: None

レプリカセットやシャーディングにて、メンバを認証する鍵ファイルを指定する。

鍵はopenSSLのコマンドで作るとよい。

```
# openssl rand -base64 100
G8Y2WXumW+voUQoIZWLCakKUDel8n/Z9DNMhLvRg17TuLXqgzjtQ6TkWuxQAPVoK
gjD4CS26K/Y4lkCUvFkp7iE2ymeZ3a3NPIZBq3jFdsL6XRzs16wlOOfaak5rPrK/
q/yyVQ==
```

詳しくは
http://docs.mongodb.org/manual/administration/replica-sets/#replica-set-security


### nounixsocket
Default: false

Unixソケットを使わない。

ローカルであればTCPではなくUNIXソケットを使うことができ、パフォーマンスが向上する（？）

動作検証

指定しない場合
```
./bin/mongod --dbpath db &
# netstat -na | grep 27017
tcp        0      0 0.0.0.0:27017               0.0.0.0:*                   LISTEN
unix  2      [ ACC ]     STREAM     LISTENING     167023 /tmp/mongodb-27017.sock  #←UNIXソケットができる
```

指定した場合
```
# ./bin/mongod --dbpath db --nounixsocket &
# netstat -na | grep 27017
tcp        0      0 0.0.0.0:27017               0.0.0.0:*                   LISTEN
```

### unixSocketPrefix
Default: /tmp

Unixソケットファイルの配置場所

### fork
Default: false

バックグラウンドで動かす。

ログが標準出力に出ないので、logpathかsyslogの指定が必要。Windowsにはない。

### auth
Default: false

認証を有効にする。

認証を有効にした後、adminのデータベースにユーザ情報を入れれば、ユーザ認証できる。
noauthが同時に設定されていた場合でもauthが優先され認証が有効になる。

認証設定例
```js
mongo
> use admin
> db.addUser("i2bs","secret")
> db.system.users.find()

//接続時に認証情報を渡す
mongo  -u i2bs -p secret
> db.coll_test.find()
> { "_id" : ObjectId("4f7f2252dd482d417bfa7f43"), "x" : 1 }

//接続時に認証情報を渡さないとクエリ時にエラー
mongo
> db.coll_test.find()
error: {
        "$err" : "unauthorized db:test lock type:-1 client:127.0.0.1",
        "code" : 10057
}
>

```

### cpu
Default: false

4秒おきにcpu使用率を記録。

ログに以下のような出力。
```
Sat Nov  3 12:47:16 [snapshotthread] cpu: elapsed:4000  writelock: 0%
Sat Nov  3 12:47:20 [snapshotthread] cpu: elapsed:4000  writelock: 0%
Sat Nov  3 12:47:24 [snapshotthread] cpu: elapsed:4000  writelock: 0%
```

### dbpath
Default: /data/db/

DBファイルを格納するディレクトリのパス。

パッケージマネジメントシステムでインストールすると/etc/mongodb.confに書いてあるdbpathを使うので注意。

### diaglog
Default: 0

トラブルシューティングで使うようなバイナリログを出す。

出す場所はdbpath（ログではない）。ログレベルは以下の通り

* 0 	off. No logging.
* 1 	Log write operations.
* 2 	Log read operations.
* 3 	Log both read and write operations.
* 7 	Log write and some read operations.

mongosniffという専用コマンドでバイナリファイルを読める

```
mongosniff --source DIAGLOG /data/db/diaglog.4f76a58c
```

diaglogは開発者の内部利用が主で、普通のユーザは使わない。

注意: diaglog = 0と指定する、何も出力されないが、diaglogファイルはできる。（diaglog自体を指定しなければ、そもそもdiaglogファイルはできない。）

###  directoryperdb
Default: false

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

一貫性を保証しなくてもよい場合はfalseでもよい。そのほうがオーバーヘッドがない。ジャーナル書き込みによるディスクへの影響を減らしたい場合は、ジャーナルのレベルを変えて、smallfilesをtrueにしてジャーナルファイルのデータ量を減らすとよい。

### journalCommitInterval
Default: 100 (msec)

ジャーナルを書き込む間隔(msec)。

減らすとディスクへの負荷が減る。2～300の間で変更可能。

###  ipv6
Default: false

IPv6を有効にする。

### jsonp
Default: false

HTTPのインターフェースを通してJSONPを許可する。

これをtrueにする前にセキュリティを考えよう。JSONPはscriptタグを使用してクロスドメインなデータを取得する仕組み。詳しくはググりましょう。

### noauth
authの逆

authと同時に設定されていた場合、authが優先され認証が有効になる。
認証はデフォルトで無効にされているので、存在意義が不明な設定項目。いつ使うの？

### nohttpinterface
Default: false

HTTPインターフェースの無効化。
restのオプションで上書きされる。

### nojournal
journalの逆

### noprealloc
Default: false

データファイルを分割しない。

スタートアップが早くなることがあるが、普通の操作が遅くなることがあるかも

### noscripting
Default: false

db.eval()を無効にする
```
> db.eval("print('test')")
Wed Nov  7 17:40:34 uncaught exception: { "errmsg" : "db side execution is disabled", "ok" : 0 }
```

参考:  
[http://www.mongodb.org/display/DOCS/Server-side+Code+Execution](http://www.mongodb.org/display/DOCS/Server-side+Code+Execution)  
[http://docs.mongodb.org/manual/faq/developers/#how-does-mongodb-address-sql-or-query-injection](http://docs.mongodb.org/manual/faq/developers/#how-does-mongodb-address-sql-or-query-injection)

ソース見た  
mongo/db/db.cpp

```cpp
        if (params.count("noscripting")) {
            scriptingEnabled = false;
        }
....
        if ( scriptingEnabled ) {
            ScriptEngine::setup();
            globalScriptEngine->setCheckInterruptCallback( jsInterruptCallback );
            globalScriptEngine->setGetInterruptSpecCallback( jsGetInterruptSpecCallback );
        }

...
```

mongo/db/dbeval.cpp

```cpp
bool dbEval(const string& dbName, BSONObj& cmd, BSONObjBuilder& result, string& errmsg) {
...
        if ( ! globalScriptEngine ) {
            errmsg = "db side execution is disabled";
            return false;
        }
...
```


### notablescan
Default: false

テーブルスキャンするオペレーションを禁止する（？？？）

### nssize
Default: 16 (MByte)

ネームスペースファイルのデフォルトサイズ。

設定後に作成されるものだけに影響するので、既存のファイルには影響なし。

16Mだと12000のネームスペースに有効。MAXは12G。

### profile
Default: 0

プロファイラのレベル。

以下のレベルを指定可能

* 0  Off. No profiling.
* 1 	On. Only includes slow operations.
* 2 	On. Includes all operations.

詳しくは　http://www.mongodb.org/display/DOCS/Database+Profiler

動作検証

設定なし
```
> db.system.profile.find()
→何も出力はない
```

２に設定
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


### smallfiles
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

