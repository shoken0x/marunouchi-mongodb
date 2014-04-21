## MongoDBのインストール

* MongoDBをダウンロード
 * 以下のURLからお使いのOSのものをダウンロード
 * https://www.mongodb.org/downloads

* MongoDBを適当なディレクトリに解凍

## MongoDBの起動

* コンソールを起動
 * Windowsならコマンドプロンプト
 * Mac,Linuxならbash等

* MongoDBを解凍したディレクトリに移動

* データディレクトリの作成

    $ mkdir data

* MongoDBの起動

 * bin以下にあるMongoDB本体(mongod)の引数に先ほど作ったデータディレクトリを指定

     (bash) $ bin/mongod --dbpath data

     (Win ) > bin\mongod.exe --dbpath data

* しばらくして以下のようなログが出たら起動成功

    Mon Apr 21 23:57:38 [initandlisten] waiting for connections on port 27017
    Mon Apr 21 23:57:38 [websvr] admin web console waiting for connections on port 28017

### MongoDBに接続

* 別のコンソールを起動

* bin以下にあるMongoDBクライアント(mongo)を起動 

     (bash) $ bin/mongo

     (Win ) > bin\mongo.exe
