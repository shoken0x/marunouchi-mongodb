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