シャーディングの設定手順
=================
----
# 概要図
[MongoDB 1.6にはシャーディングとレプリカセットが追加された InfoQより 引用](http://www.infoq.com/jp/news/2010/10/MongoDB-1.6)

![overview](http://www.infoq.com/resource/news/2010/08/MongoDB-1.6/en/resources/mongodb2.png)

----
# 登場人物
[MongoDB 1.6にはシャーディングとレプリカセットが追加された InfoQより 引用](http://www.infoq.com/jp/news/2010/10/MongoDB-1.6)

### mongod(shards)
> メインのデータベースプロセス。１つのシャードを表し、自動フェイルオーバーを提供するためのレプリカセットを構成する。mongodプロセスのうちの１つが、レプリカセットのマスタとなる。マスタがダウンした場合は、他のサーバにマスタの役割が移譲される。

### mongos
> ルーティングプロセス。単一のサーバであるかのように、シャードされたデータベースとクライアントを連携させる。必要があれば複数のmongosサーバをたてることができる。それらは状態を共有しない。

### config servers
> 各構成サーバは、システムにどんなシャードが存在しているかといったような、クラスタのメタデータを含んでいる。保護のために複数の構成サーバがあり、１つがダウンしたら、構成サーバは読み取り専用モードになる。ただし、シャードは読み書きモードで動作し続ける。


----
# 用語集
[Shardingの紹介 MongoDB公式マニュアルより 引用](http://www.mongodb.org/pages/viewpage.action?pageId=5537937)

### shard
> それぞれのshardは1つ以上のサーバで構成され、mongodプロセス (mongodはMongoDBのデータベースプロセスのコアです) を使いデータを保存します。プロダクション環境においては、可用性を高め、自動フェイルオーバー機能を有効にするために1つのshardに対し複数のサーバを用意しそこにReplicationを構築します。この複数のサーバ/mongodプロセスのセットは、 replica set から成ります。

### replica sets
> 各ノードメンバーに対してフェイルオーバーやリカバリーの機能を自動で提供します。1-7台までをサポートします。
[Replica Set Configuration - MongoDB公式マニュアル](http://www.mongodb.org/display/DOCSJP/Replica+Set+Configuration)

### shardキー


### Chunk








