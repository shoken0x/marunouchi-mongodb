シャーディングの設定手順
=================
参考URL
http://d.hatena.ne.jp/matsuou1/20110413/1302710901
----
MongoDBは、NoSQLデータベースでよく採用されている Consistent Hashing ではなく、RDBMSではおなじみのレンジパーティションを採っている。

----
# 準備
<pre>
$ mkdir -p /tmp/mongodb/log
$ mkdir -p /tmp/mongodb/shard1
$ mkdir -p /tmp/mongodb/shard2
$ mkdir -p /tmp/mongodb/shard3
$ mkdir -p /tmp/mongodb/config
</pre>
