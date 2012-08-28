障害発生時の挙動
=================
### MongoDBのSharding環境にて、各サーバが停止した場合の挙動について検証してみます。
----
#### 参考URL

[MongoDBのShardingを試してみた。その３ 障害発生時の挙動について](http://d.hatena.ne.jp/matsuou1/20110419/1303231639)

----

# ポート一覧
localhost:10000 => mongos  
localhost:10001 => config  
localhost:10010 => shard0(shard0000)  
localhost:10011 => shard1(shard0001)  
localhost:10012 => shard2(shard0002)  

----
# mongosサーバをおとしてみる
* ログをtailしましょう
<pre>
$ tail -f /tmp/mongodb/log/mongos.log
</pre>

* mongosサーバを落としてみましょう
<pre>
$ ps axu |grep mongos
$ kill -2 xxxx
</pre>

* mongosサーバに接続できますか？
<pre>
$ mongo localhost:10000/logdb
</pre>

* 各シャードに接続できますか？
<pre>
$ mongo localhost:10010
$ mongo localhost:10011
$ mongo localhost:10012
</pre>

# まとめ
<pre>
//MongoDBのShardingを試してみた。その３ 障害発生時の挙動について より引用
想定通り、mongosサーバに接続できなくなりました。
各shardには問題なく接続でき、クエリの実行も可能ですが、複数shardをまたがるようなクエリの実行は出来なくなります。
下手な構成な場合は単一障害点となりうるので、基本的にはwebサーバやアプリサーバなど実際にアプリケーションが動作するサーバで
実行させて、プロセスの死活監視を行い、障害が発生したらプロセスの再起動を行う感じの運用になるのではないでしょうか。
mongosは、単なるルーティングプロセスでデータの管理はしないので、復旧時に特に気を使う必要はないかと思います。
</pre>


----
# shardサーバをおとしてみる
* ログをtailしましょう
<pre>
$ tail -f /tmp/mongodb/log/mongos.log
</pre>

* 3つ目のshardサーバ(shard0002)を落としてみましょう
<pre>
$ ps axu |grep shard2
$ kill -2 xxxx
</pre>

* mongosサーバに接続できますか？
<pre>
$ mongo localhost:10000/logdb
</pre>

* countできますか？
<pre>
> use logdb
> db.logs.count()
</pre>

* shard0000に入っているような若いuidで検索できますか？
<pre>
> use logdb
> db.logs.find({"uid":1})
</pre>

* insertできますか？
<pre>
> db.logs.insert({"uid":99999999, "value":99999999})
</pre>

* db.runCommand( { listshards : 1 } ), db.printShardingStatus()ではどう見える？
<pre>
$ mongo localhost:10000/logdb
> use admin
> db.runCommand( { listshards : 1 } );
> db.printShardingStatus();
</pre>


# まとめ
* shard環境では、targetedとglobalの２つのタイプのクエリに分けられます。
* 実行可能なクエリの例
  * shard keyを指定して、落ちているshard以外のshardの検索
  * shard keyを指定して、落ちているshard以外のshardのアップデート
  * インサート
* 実行不可能なクエリの例
  * shard keyを指定して、落ちているshardのデータの検索
  * shard keyを指定しない検索
* db.runCommand( { listshards : 1 } ), db.printShardingStatus()で障害は検知できない。
* エラーはmongosのログに出る

<pre>
//MongoDBのShardingを試してみた。その３ 障害発生時の挙動について より引用
shard障害が発生すると、障害shardを参照するクエリは実行エラーとなるが、問題ないshardへのshard keyを使用したクエリは実行可能。
アプリへの影響が大きいので、基本的にはReplica set を構成し、冗長化を行うべきです。
</pre>

#### 参考
[MongoDB公式マニュアル Sharding Introduction](http://www.mongodb.org/display/DOCS/Sharding+Introduction#ShardingIntroduction-OperationTypes)


----
# configサーバをおとしてみる
* ログをtailしましょう
<pre>
$ tail -f /tmp/mongodb/log/mongos.log
</pre>
<pre>
$ tail -f /tmp/mongodb/log/config.log
</pre>

* configサーバを落としてみましょう
<pre>
$ ps axu |grep configsvr
$ kill -2 xxxx
</pre>

* shardの追加・削除はできますか？
<pre>
$ mkdir /tmp/mongodb/shard3
$ mongod --shardsvr --port 10013 --dbpath /tmp/mongodb/shard3 --logpath /tmp/mongodb/log/shard3.log &
$ mongo localhost:10000/admin
> db.runCommand( { addshard : "localhost:100013" } );
</pre>

* db.runCommand( { listshards : 1 } ), db.printShardingStatus()ではどう見える？
<pre>
$ mongo localhost:10000/logdb
> use admin
> db.runCommand( { listshards : 1 } );
> db.printShardingStatus();
</pre>

# まとめ

<pre>
//MongoDBのShardingを試してみた。その３ 障害発生時の挙動について より引用
configサーバ障害が発生すると、システムのメタデータはリードオンリーになるため、shardの追加、削除などは出来なくなります。
システムは機能し続けますが、chunkの分割や移動は行われなくなるため、このタイミングで大量のデータロードを行うとmigrateできないために、アンバランスなshardができてしまう可能性があります。（マニュアルより。。。）
また、configサーバが落ちている場合は、クラスタのメタデータが必要なためmongosサーバが起動できません。
configサーバと同時にmongosサーバも落ちた場合は、先にconfigサーバ復旧後にmongosサーバを復旧させる必要があります。
マニュアルでは、ダメージは大きくないよと記載されていますが、意外なところで思わぬバグ等を踏む可能性もあるので、可能な限り早く復旧しましょう。
</pre>


