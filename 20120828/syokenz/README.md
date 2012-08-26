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

### Shard

> それぞれのshardは1つ以上のサーバで構成され、mongodプロセス (mongodはMongoDBのデータベースプロセスのコアです) を使いデータを保存します。プロダクション環境においては、可用性を高め、自動フェイルオーバー機能を有効にするために1つのshardに対し複数のサーバを用意しそこにReplicationを構築します。この複数のサーバ/mongodプロセスのセットは、 replica set から成ります。

### Replica sets

> 各ノードメンバーに対してフェイルオーバーやリカバリーの機能を自動で提供します。1-7台までをサポートします。

[Replica Set Configuration - MongoDB公式マニュアル](http://www.mongodb.org/display/DOCSJP/Replica+Set+Configuration)

### Shardキー

> コレクションを分割するために必要な設定です。1つかまたは2つ以上のフィールドを設定します。後から変更できないので、とても重要です。Shardキーの値を持たないドキュメントは保存できません。ただしnullは可能です。

<pre>
例
{ state : 1 }
{ name : 1 }
{ _id : 1 }
{ lastname : 1, firstname : 1 }
</pre>

### Chunk

> chunkは、特定のコレクションの連続した範囲のデータ(ドキュメント)です。（コレクション, 最小キー, 最大キー）の組み合わせでchunkを表現できます。shardキーが K のドキュメントは、「最小キー」<= K < 「最大キー」と言う条件のchunkにマッチします。
chunkは、最大サイズ（標準で200MB）に達すると、そのchunkは2つの新しいchunkに 分割 されます。あるshardが余剰データを持っている場合、chunkがシステムによって他のshardに移動されます。同様に、サーバ(shard)を追加したときchunkは移動します。


<pre>
例
ChunkA [ "a", "k" )
ChunkB [ "k", "{" ) 
//例えばChunkAは [ "a", "k" ), ChunkBが [ "k", "{" ) のレンジを持っていたとすると、
//ShardKeyのイニシャルが"a"から"j"までの値を持つドキュメントはChunkAに、
//"k"から"z"までを持つドキュメントはChunkBに属します。"{" は "z" の次の順序を持つ値です。
//http://doryokujin.hatenablog.jp/entry/20110601/1306858487
</pre>





