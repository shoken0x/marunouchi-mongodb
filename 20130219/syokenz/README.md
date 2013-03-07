MongoDB 2.4 新機能紹介
=================
#はじめに
このページは、MongoDB 2.4 リリースノートの内容を元に書いています。
- http://docs.mongodb.org/manual/release-notes/2.4/

#コンテンツ
- 全文検索機能
- ケルベロス認証のサポート（サブスクリプション版のみ）
- JavaScriptエンジンをV8へ変更
- GeoJSONを使用した球面地理空間インデックス
- インデックス構築の自動再開（resume機能）
- ハッシュドシャードキーを用いたシャーディング


## 全文検索機能

2.4の目玉機能！ ついにインデックス付き全文検索をサポート！  
だけど、本番環境では使っちゃだめ！  とリリースノートに書いてあります。  
```
Warning:  Do not enable or use text indexes on production systems.
```
しかも日本語は未対応。。。    
  
ソースを確認したところ、tokenizer.cppがEnglishしか実装されていない模様。（2013/02/19）  
https://github.com/mongodb/mongo/blob/r2.4.0-rc0/src/mongo/db/fts/tokenizer.cpp  
https://github.com/mongodb/mongo/blob/r2.4.0-rc0/src/mongo/db/fts/tokenizer_test.cpp


ソースはsrc/mongo/db/ftsの中です  
https://github.com/mongodb/mongo/tree/r2.4.0-rc0/src/mongo/db/fts


### インデクシング処理
大きく分けて3つの処理  
1. Tokenizerで形態素解析  
2. Stop Word Filtering で不要な単語を除去  
3. Stemming処理  
※Stemmingとは
```
検索エンジンで検索語の語幹を解釈する手法。例えばsing（歌う）という検索語を入力した場合でも、
singer（歌手）やsinging（歌うこと）などのキーワードとマッチングさせること。
日本語ではまだ実用化されていない（と思う、多分）。
ステム（stem）とは「木の幹、草の茎（くき）」のことで、語尾が変化しても変化しない根幹部分。
```
出所: http://www.sem-seminar.com/glossary/e_stemming.html

![Full Text Search](http://blog.codecentric.de/files/2013/01/600x302xmongo_fts_2.png.pagespeed.ic.qA4D7gJtDY.png)  
図の出所: http://blog.codecentric.de/en/2013/01/text-search-mongodb-stemming/

### ハンズオン
textSearchEnabledをtrueに  
```
mongod --setParameter textSearchEnabled=true
```
または
```
> db.adminCommand( { setParameter: 1, textSearchEnabled: true } )
```

textインデックス作成
```
> db.txt.ensureIndex( {txt: "text"} )
```
確認
```
> db.txt.getIndices()
```

データ挿入、検索
```
> db.txt.insert({txt: "I'm still waiting"})
> db.txt.insert({txt: "I waited for hours"})
> db.txt.insert({txt: "He waits"})
```

```
> db.txt.runCommand("text", {search: "wait"})
{
        "queryDebugString" : "wait||||||",
        "language" : "english",
        "results" : [
                {
                        "score" : 1,
                        "obj" : {
                                "_id" : ObjectId("51234979bacbee4cbabca604"),
                                "txt" : "He waits"
                        }
                },
                {
                        "score" : 0.75,
                        "obj" : {
                                "_id" : ObjectId("5123496abacbee4cbabca602"),
                                "txt" : "I'm still waiting"
                        }
                },
                {
                        "score" : 0.75,
                        "obj" : {
                                "_id" : ObjectId("51234974bacbee4cbabca603"),
                                "txt" : "I waited for hours"
                        }
                }
        ],
        "stats" : {
                "nscanned" : 3,
                "nscannedObjects" : 0,
                "n" : 3,
                "nfound" : 3,
                "timeMicros" : 105
        },
        "ok" : 1
}
```

クエリに正規表現を使用可能    
複数のフィールドを重み付けして検索できるScore Hit方式    
マニュアルより  
```js
db.collection.ensureIndex( { content: "text",
                             "users.profiles": "text",
                             comments: "text",
                             keywords: "text",
                             about: "text" },
                           { name: "TextIndex",
                             weights:
                             { content: 10,
                               "user.profiles": 2,
                               keywords: 5,
                               about: 5 } } )
```
TextIndexというインデックスを指定し、重み付けが可能    
- content field that has a weight of 10,
- users.profiles that has a weight of 2,
- comments that has a weight of 1,
- keywords that has a weight of 5, and
- about that has a weight of 5.


日本語も試してみましょう    


## ケルベロス認証のサポート（サブスクリプション版のみ）
- サブスクリプション版のみサポート
- mongodの認証で利用可能
- mongodの起動時にパラメータで指定する
-- env KRB5_KTNAME=/opt/etc/mongodb.keytab
-- authenticationMechanisms=GSSAPI

## JavaScriptエンジンをV8へ変更
デフォルトJavaScriptエンジンをSpiderMonkeyからV8へスイッチ  
mongo shellからdb.serverBuildInfo()で確認できます  
```
> db.serverBuildInfo()
```

または interpreterVersion()で確認できます  
```
> interpreterVersion()
```

## GeoJSONを使用した球面地理空間インデックス
2.4から球面地理空間（ Spherical Geospatial ）インデックスのindex typeが2dsphereになりました  
ノーマルインデックスと併用可能に  
```js
> db.collection.ensureIndex( { type: 1, geo: "2dsphere" } )
```

GeoJSONに対応  
http://geojson.org/geojson-spec.html  
今のところPoint, LineString, Polygonだけ  
それぞれで今までのクエリーオペレータ（ $within , $box, $near 等）で検索可能  
新オペレータ $geoIntersects  
引数に{ $geometry : “GeoJSON document” }を指定  
 “GeoJSON document”と交差したオブジェクトを返す  
```js
> db.collection.find( {
  $geoIntersects: { $geometry: { "type": "Point", "coordinates": [ 40, 5 ] }
} } ) 
```

### ハンズオン
GeoJSONオブジェクトでLineStringをいくつか保存して、交差する直線を検索してみよう

```js
db.gjson.ensureIndex( { geo: "2dsphere" } );

db.gjson.insert({"name": "tate05", geo:{ "type": "LineString", "coordinates": [ [ 5, 5 ], [ 5, 0 ] ] }});
db.gjson.insert({"name": "tate10", geo:{ "type": "LineString", "coordinates": [ [ 10, 10 ], [ 10, 0 ] ] }});
db.gjson.insert({"name": "tate15", geo:{ "type": "LineString", "coordinates": [ [ 15, 15 ], [ 15, 0 ] ] }});
db.gjson.insert({"name": "tate20", geo:{ "type": "LineString", "coordinates": [ [ 20, 20 ], [ 20, 0 ] ] }});


db.gjson.find({geo:{ "$geoIntersects": { "$geometry": { "type": "LineString", "coordinates": [ [ 0, 20 ], [ 13, 20 ] ]}} }} );
db.gjson.find({geo:{ "$geoIntersects": { "$geometry": { "type": "LineString", "coordinates": [ [ 0, 20 ], [ 20, 20 ] ]}} }} );



```

## インデックス構築の自動再開（resume機能）
インデックス構築中にmongodを停止してしまった場合でも、次回起動後に自動的に再開  
2.4以前だと、mongodを停止する前にインデックス構築を終える必要があった  
noIndexBuildRetryオプションで無効にできる  
デフォルトではインデックス構築の自動再開は有効    

ただし、Index構築中はロックされるので注意が必要。  

## ハッシュドシャードキーを用いたシャーディング
シャードキーをハッシュ化することでデータの偏りを防ぐことが可能に  
例えば、シャードキーがメールアドレスだった場合  
アルファベットごとに偏りが生まれ、均等なレンジ指定が難しくなる  
例：携帯のメールアドレス帳  
シャードキー、つまりメールアドレスをハッシュ化することで、ランダムな文字列となり、ほぼ均等に分けることが可能  
シャーディングの設定を容易にすることと、データを均等に分散させることを目的に導入された機能  


## 参考リンク
日本語音声付きの動画、全文検索機能とハッシュドシャードキーに関して解説  
http://www.youtube.com/watch?v=KVEFsib7ouo   

