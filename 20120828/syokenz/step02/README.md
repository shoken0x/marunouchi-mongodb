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

# 準備


----
# 各サーバ起動
