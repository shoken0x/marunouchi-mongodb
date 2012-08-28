シャーディングの設定手順（Mac OSXで動作確認しています）
=================

----
#### 参考URL

[MongoDBのShardingを試してみた。その１](http://d.hatena.ne.jp/matsuou1/20110413/1302710901)

----

#### 準備
<pre>
$ mkdir -p /tmp/mongodb/log
$ mkdir -p /tmp/mongodb/shard1
$ mkdir -p /tmp/mongodb/shard2
$ mkdir -p /tmp/mongodb/shard3
$ mkdir -p /tmp/mongodb/config
</pre>


----
#### shardサーバ起動
<pre>
$ mongod --shardsvr --port 10001 --dbpath /tmp/mongodb/shard1 --logpath /tmp/mongodb/log/shard1.log --rest &
$ mongod --shardsvr --port 10002 --dbpath /tmp/mongodb/shard2 --logpath /tmp/mongodb/log/shard2.log --rest &
$ mongod --shardsvr --port 10003 --dbpath /tmp/mongodb/shard3 --logpath /tmp/mongodb/log/shard3.log --rest &
</pre>

#### 確認
<pre>
$ mongo localhost:10001
MongoDB shell version: 2.0.3
connecting to: localhost:10001/test
//connectingできたらOK
</pre>







