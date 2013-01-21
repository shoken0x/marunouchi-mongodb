GridFSハンズオン
==================

# GridFS基本のき

GridFSについて初めて触る人向けのチュートリアルです

## GridFSとは



## なぜOSのファイルシステムではなく、データベースでファイルを管理するのか



## GrindFSのメリット

MongoDBのドキュメントサイズの16MB制限

### 検証

サンプルファイル作成
```
dd if=/dev/zero of=15MB.file bs=1M count=15
dd if=/dev/zero of=16MB.file bs=1M count=16
```

mongo-sizelimit.rb

エラー
```
# ruby mongo-sizelimit.rb
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



##



##
