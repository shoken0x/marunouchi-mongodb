MongoDB Sharding Tips
=================
----
- localhostと実IPの混在はできない。ループバックアドレス(127.0.0.1)でもだめ。mongos起動する際のconfig serverの指定も注意
- 一度shardに属したmongodは、他のshardと混在することはできない、config serverにメタデータを保持している。下記コマンドが必要。
<pre>
db.runCommand( { removeshard : "localhost:10001" } ); 
</pre>

- Shardの削除  
  Shardが完全に削除される前に、そのshardに保存されている全てのchunkを残りのshardに移動させなければなりません。'removeshard' コマンドは全てのchunkが移動されるまで "draining" 状態になっています。shardの削除を行うには次のコマンドを発行します：
- sharding環境を再構築する  
dbを削除
  <pre>
　 use logdb
　 db.dropDatabase()
  </pre>
shardを削除
　<pre>　
    db.runCommand( { removeshard : "localhost:10001" } );  
  </pre>

- 各shardingしているmongodに直接データを入れても、mongos経由で参照できる
- shardサーバが落ちると、mongosのログに出る
- よく使うコマンド
<pre>
db.printShardingStatus()
db.printShardingSizes()
</pre>

----
## 参考リンク

- [Sharding を使いこなすための5つのTips](http://doryokujin.hatenablog.jp/entry/20110601/1306858487)

- [〜うまく動かすMongoDB〜仕組みや挙動を理解する](http://doryokujin.hatenablog.jp/entry/20110519/1305737343)
<pre>
■自動Sharding
例えばShard Keyに"name"を指定したとします。すると始めはざっくりと「ア行はShard0」に「カ行はShard1」といった具合に振り分けルールを決定します。この「ア行に属するデータ集合」のことをChunk呼びます。各ChunkはShard Keyの値に対して他とかぶらない範囲をもっておりその範囲に属するデータはそのChunkの中に入っていきます。そしてChunkの中にデータが詰まりすぎた場合はそのChunkを等分割してChunkサイズを均等に保とうとします。先ほどの例でいうと、[あ,い,う,え,お]の範囲を持っていたChunkが[あ,い,う]と[え,お]というChunkに分割されます。@kuwa_tw氏が触れているデフォルトのChunkサイズは200MBです。つまり200MB以上のデータがそのChunk内に入ってきた場合に分割が行われることになります。データが大量に入ってきている状態の裏で、Chunkの細胞分裂が絶えず行われているのです。
実はデフォルトのChunkサイズは200MBなのですが、Sharding開始時では64MBに下げられています。そしてある程度のデータサイズとなった場合に200MBに変更されます（変更されないという話も聞きますが…）。もちろんこのデフォルトのChunkサイズは変更を行うことができます。mongosを起動するときにオプションとして --chunkSize [MB] を設定してやれば良いのです。
mongos --port 10000 --configdb host1:10001 --chunkSize 500
ここで --chunkSizeを1[MB]に設定してやるとchunkはデフォルトよりも遙かに速いペースで分割されていきます。ただ分割されるといっても、物理的な分割が行われているわけではないことに注意してください。しかしchunkSizeを1に設定すると後述するChunkの移動が絶えず行われるような状態に陥り、様々な問題を引き起こすので注意してください。
■自動Balancing
ShardKeyを適切に設定しなかったり、大量のデータ挿入で振り分けルールの設定が追いつかなかった場合にはShard間でデータの偏りが生じてしまいます。これはどう頑張っても避けられない問題でもあります。しかしMongoDBはデータの偏りがある程度大きくなった時点で偏りの大きいShardから少ないShardへChunkの移動を行うことによってそれに立ち向かってくれます。しかも自動で。
</pre>

- [[mongodb]MongoDBでシャーディング、レプリケーション ](http://d.hatena.ne.jp/HowHigh/20111118/p1)

- [technote - MongoDB](http://rest-term.com/technote/index.php/MongoDB)
<pre>
Sharding Administrationによると、データは各シャード間のチャンク差が 8 を超えるまでは primary shard(shard0000) にのみ保持され分散は行われない。実運用ではこのバランシング機能によってチャンク移動が起こることは極力避けたいため(シャード間のデータ転送は高コスト)、最適なチャンクサイズをあらかじめ設定しておくか、あるいはバランシング機能自体をオフにする必要がある。
</pre>

- [ReplicaSetとかShardingとかためしてみる(Sharding編)](http://d.hatena.ne.jp/tm8r/20110511/1305122040)  

- [chunkを手動で移動する](http://d.hatena.ne.jp/tm8r/20110519/1305820734)  

- [MongoDB公式ドキュメント　シャーディング](http://www.mongodb.org/display/DOCSJP/Sharding)

- [デフォルトのTCPポートについて Production Notes - MongoDB](http://www.mongodb.org/display/DOCS/Production+Notes#ProductionNotes-TCPPortNumbers)
<pre>
Standalone mongod : 27017
mongos : 27017
shard server (mongod --shardsvr) : 27018
config server (mongod --configsvr) : 27019
web stats page for mongod : add 1000 to port number (28017, by default)
</pre>

- [MongoDBのShardingを試してみた。その１](http://d.hatena.ne.jp/matsuou1/20110413/1302710901)  
- [MongoDBのShardingを試してみた。その２ Migration中の挙動について](http://d.hatena.ne.jp/matsuou1/20110415/1302873577)  
- [MongoDBのShardingを試してみた。その３ 障害発生時の挙動について](http://d.hatena.ne.jp/matsuou1/20110419/1303231639)  
