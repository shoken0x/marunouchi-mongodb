GridFSハンズオン
==================
GridFSについて初めて触る人向けのチュートリアルです

## GridFSとは

任意のサイズのファイルをMongoDBに保存するためのプロトコル。  
すべての公式ドライバとMongoDBのmongofilesツールに実装されている。  

インターフェイスはput, get, deleteに限定。  
更新するためには、いったんdeleteしてからputする。  

chunkと呼ばれる256KBのバイナリデータに分割し、fs.chunksへ保存する。  
ファイルのメタデータは、fs.filesへ保存される。  


## GrindFSのメリット

なぜOSのファイルシステムではなく、データベースでファイルを管理するのか  

* ファイルシステムの作成数制限

・ディレクトリ内のサブディレクトリの制限  
出所:http://sweng.web.fc2.com/linux/centos/centos-maxfile.html  
```
ext3の場合、システムヘッダファイル(/usr/include/linux/ext3_fs.h)に、最大ファイル数が定義されています。
    /*
    * Maximal count of links to a file
    */
    #define EXT3_LINK_MAX 32000
32000という値が設定されています。
```
  
・ファイル数はiノード数が制限  
出所:http://www.atmarkit.co.jp/flinux/rensai/linuxtips/264chkinode.html  
```
　iノードの割当数などを調べるには、-iオプション付きでdfコマンドを実行する。
$ df -i
Filesystem            Inodes   IUsed   IFree IUse% Mounted on
/dev/hda3            7077888  198367 6879521    3% /
/dev/hda2              12048      43   12005    1% /boot
none                   63100       1   63099    1% /dev/shm
```

実運用上では、30万個程度が上限か  
出所:http://bitwalker.dtiblog.com/blog-entry-234.html  
```
実際にやってみると、30 万個を過ぎた頃から ls の結果が表示されるまでの時間がだんだんのびてきた。
70 万個辺りで ls の結果が表示されるまで 1 分程度。
100 万個を過ぎると軽く 2 分以上かかるようになった。
また、この辺りからファイルが作られるスピードが落ちてきた。
I/O ウェイトが 50% 前後まで上昇したり下がったりの繰り返し。
そして、150 万個まで作ったときに、ls が 10 分待っても返ってこないことに気づいた。
Ctrl+C も効かないので kill するしかない。
ただしファイルは問題なく作ることができる。
この後、結局 1300 万個以上作ってみたけど、ls したりしなければ特に問題なし。 
```

* メタデータの管理  
ファイルといっしょに管理したいもの  
・ファイルサイズ  
・作成者  
・パーミッション  
...  


* データの取り扱いのメリット
メタデータといっしょにバックアップ可能


## MongoDBのドキュメントサイズの16MB制限  

### 検証

サンプルファイル作成
```
$ dd if=/dev/zero of=15MB.file bs=1M count=15
$ dd if=/dev/zero of=16MB.file bs=1M count=16
```

[mongo-sizelimit.rb](https://github.com/syokenz/marunouchi-mongodb/blob/master/20130123/GridFS/mongo-sizelimit.rb)

エラー（rubyのbson_c.rb）
```
$ ruby mongo-sizelimit.rb
15MB.file insert to mongo ...
insert success


16MB.file insert to mongo ...
/usr/local/lib/ruby/gems/1.9.1/gems/bson-1.6.2/lib/bson/bson_c.rb:24:in `serialize': Document too large: This BSON documents is limited to 16777216 bytes. (BSON::InvalidDocument)
        from /usr/local/lib/ruby/gems/1.9.1/gems/bson-1.6.2/lib/bson/bson_c.rb:24:in `serialize'
        from /usr/local/lib/ruby/gems/1.9.1/gems/mongo-1.6.2/lib/mongo/collection.rb:972:in `block in insert_documents'
        from /usr/local/lib/ruby/gems/1.9.1/gems/mongo-1.6.2/lib/mongo/collection.rb:971:in `each'
        from /usr/local/lib/ruby/gems/1.9.1/gems/mongo-1.6.2/lib/mongo/collection.rb:971:in `insert_documents'
        from /usr/local/lib/ruby/gems/1.9.1/gems/mongo-1.6.2/lib/mongo/collection.rb:353:in `insert'
        from mongo-sizelimit.rb:19:in `<main>'
```



## GridFS with mongofiles

mongofilesはGridFSを操作するためのコマンドラインツールです。  
MongoDBをインストールするとbinディレクトリの中に入っています。  

```
## ファイル作成
dd if=/dev/zero of=1MB.file bs=1M count=1

## MongoDBにファイルを保存
## -v オプションで詳細出力、 -d オプションでデータベース名を指定
$ mongofiles -v -d gridtest put 1MB.file
Wed Jan 23 16:27:48 creating new connection to:127.0.0.1:27017
Wed Jan 23 16:27:48 BackgroundJob starting: ConnectBG
Wed Jan 23 16:27:48 connected connection!
connected to: 127.0.0.1
added file: { _id: ObjectId('50ff90f4c074ea0c0f78ba4c'), filename: "1MB.file", chunkSize: 262144, uploadDate: new Date(1358926068990), md5: "b6d81b360a5672d80c27430f39153e2c", length: 1048576 }
done!

## MongoDBからファイルを取得
$ mongofiles -v -d gridtest get 1MB.file
Wed Jan 23 16:29:03 creating new connection to:127.0.0.1:27017
Wed Jan 23 16:29:03 BackgroundJob starting: ConnectBG
Wed Jan 23 16:29:03 connected connection!
connected to: 127.0.0.1
done write to: 1MB.file
```

コレクションの中身
```
$ mongo gridtest
MongoDB shell version: 2.2.0
connecting to: gridtest
> show collections
fs.chunks
fs.files
system.indexes
 
## fs.files にファイルのメタデータが保存されている。
> db.fs.files.find()

```


## GrindFS with Ruby

GridFSをRubyから操作してみましょう。  
http://api.mongodb.org/ruby/current/Mongo/Grid.html

```rb
require  'mongo'

@con = Mongo::Connection.new
@db = @con["grindtest"]
@grid = Mongo::Grid.new(@db)
@collection = @db["fs.files"]
@collection.count()
#=> 0

# 任意のメタデータを追加可能
file_id = @grid.put(File.binread("1MB.file"), :filename => "1MB.file", :size => "1MB", :owner => "mongonouchi")
@collection.count()
#=> 1
@grid.get(file_id).filename
#=> "1MB.file"
@grid.delete(file_id)
#=> true

```


参考  
[MongoDB GridFSについて](http://rest-term.com/archives/2962/)