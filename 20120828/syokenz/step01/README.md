シャーディングの設定手順（Mac OSXで動作確認しています）
=================

----
#### 参考URL

[MongoDBのShardingを試してみた。その１](http://d.hatena.ne.jp/matsuou1/20110413/1302710901)

----

# 準備
logディレクトリ、データディレクトリを作成します。

<pre>
$ mkdir -p /tmp/mongodb/log
$ mkdir -p /tmp/mongodb/shard1
$ mkdir -p /tmp/mongodb/shard2
$ mkdir -p /tmp/mongodb/shard3
$ mkdir -p /tmp/mongodb/config
</pre>


----
# 各サーバ起動
shardサーバ、configサーバ、mongosサーバを起動します。

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

#### configサーバ起動
<pre>
$ mongod --configsvr --port 10004 --dbpath /tmp/mongodb/config --logpath /tmp/mongodb/log/config.log --rest &
//mongosサーバ起動
//chunkの動作も見たいので、chunk sizeを1MBに設定し起動する。
$ mongos --configdb localhost:10004 --port 10000 --logpath /tmp/mongodb/log/mongos.log --chunkSize 1&
</pre>

#### 確認
<pre>
$ ps axu |grep [m]ongo |wc -l
//5だったらOK
</pre>









