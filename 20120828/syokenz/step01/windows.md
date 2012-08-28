シャーディングの設定（Windows版）
=================

# 準備
logディレクトリ、データディレクトリを作成します。

<pre>
> mkdir db\shard0
> mkdir db\shard1
> mkdir db\shard2
> mkdir db\config
> mdkir log
</pre>


----
# 各サーバ起動
shardサーバ、configサーバ、mongosサーバを起動します。
(Windowsではバックグラウンドでプロセスを上げる場合、start "(名前)" を使います）

#### shardサーバの起動
<pre>
> start "shard0" bin\mongod --shardsvr --port 10010 --dbpath db\shard0 --rest
> start "shard1" bin\mongod --shardsvr --port 10011 --dbpath db\shard1 --rest
> start "shard2" bin\mongod --shardsvr --port 10012 --dbpath db\shard2 --rest
</pre>

#### shardサーバの確認
<pre>
> bin\mongo localhost:10010
MongoDB shell version: 2.0.3
connecting to: localhost:10010/test
//connectingできたらOK
</pre>

#### configサーバ、mongosサーバの起動
<pre>
//configサーバ起動
> start "config" bin\mongod --configsvr --port 10001 --dbpath db\config  --rest 
//mongosサーバ起動
//chunkの動作も見たいので、chunk sizeを1MBに設定し起動する。
> start "mongos" bin\mongos --configdb localhost:10001 --port 10000 --chunkSize 1
</pre>

#### configサーバ、mongosサーバの確認
<pre>
> tasklist | findstr mongo
//5つプロセスが表示されたらOK
</pre>

#### configサーバ、mongosサーバの停止
> taskkill /F /pid (プロセスID)

#### メモ
windowsでプロセスの停止には、[Process Explorer](http://technet.microsoft.com/ja-jp/sysinternals/bb896653.aspx)が便利とのこと。  
勉強会中に教えてもらいました。


