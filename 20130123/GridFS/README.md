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

MongoDBのドキュメントサイズの16MB制限  

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
## MongoDBにファイルを保存
## -v オプションで詳細出力、 -d オプションでデータベース名を指定
$ mongofiles -v -d gridtest put 16MB.file

## MongoDBからファイルを取得
$ mongofiles -v -d gridtest get 16MB.file
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

```rb
@grid = Mongo::Grid.new(@db)
# 任意のメタデータを追加可能
file_id = @grind.put(file, :filename => "16MB.file")
```


参考  
[MongoDB GridFSについて](http://rest-term.com/archives/2962/)