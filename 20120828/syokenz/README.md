シャーディングの設定手順
=================

# 概要図
[MongoDB 1.6にはシャーディングとレプリカセットが追加された InfoQより 引用](http://www.infoq.com/jp/news/2010/10/MongoDB-1.6)

![overview](http://www.infoq.com/resource/news/2010/08/MongoDB-1.6/en/resources/mongodb2.png)

# 登場人物

## mongod(shards)
> メインのデータベースプロセス。１つのシャードを表し、自動フェイルオーバーを提供するためのレプリカセットを構成する。mongodプロセスのうちの１つが、レプリカセットのマスタとなる。マスタがダウンした場合は、他のサーバにマスタの役割が移譲される。

## mongos
> ルーティングプロセス。単一のサーバであるかのように、シャードされたデータベースとクライアントを連携させる。必要があれば複数のmongosサーバをたてることができる。それらは状態を共有しない。

## config servers
> 各構成サーバは、システムにどんなシャードが存在しているかといったような、クラスタのメタデータを含んでいる。保護のために複数の構成サーバがあり、１つがダウンしたら、構成サーバは読み取り専用モードになる。ただし、シャードは読み書きモードで動作し続ける。

[MongoDB 1.6にはシャーディングとレプリカセットが追加された InfoQより 引用](http://www.infoq.com/jp/news/2010/10/MongoDB-1.6)


# 用語集

## shard
> それぞれのshardは1つ以上のサーバで構成され、mongodプロセス (mongodはMongoDBのデータベースプロセスのコアです) を使いデータを保存します。プロダクション環境においては、可用性を高め、自動フェイルオーバー機能を有効にするために1つのshardに対し複数のサーバを用意しそこにReplicationを構築します。この複数のサーバ/mongodプロセスのセットは、 replica set から成ります。

## replica sets


## shardキー


## Chunk



[Shardingの紹介 MongoDB公式マニュアルより 引用](http://www.mongodb.org/pages/viewpage.action?pageId=5537937)





