MongoDBでアプリをつくろう
=================

MongoDBのRESTインターフェースを使って、簡単なWEBアプリを作成します。  
[ドキュメント:RESTインターフェース](http://www.mongodb.org/display/DOCS/Http+Interface)  
RESTインターフェースはjsonを返すので、jQueryを使って遊んでみましょう。  

## 準備

ruby-gmailのインストール
```
gem install mail --no-ri --no-rdoc
git clone https://github.com/syokenz/ruby-gmail.git
```

Gmail設定の変更  
[gmail_conf.rb](https://github.com/syokenz/marunouchi-mongodb/blob/master/20121106/syokenz/gmail_conf.rb)
```ruby
class GConf
  LIBPATH='D:\src\git\ruby-gmail\lib'  #ruby-gmail/libへのパス
  USERNAME='_@gmail.com'               #Gmailのアドレス
  PASSWORD='xxxx'                      #Gmailのパスワード
  IMAGES_DIR='D:\\tmp\\'               #画像を保存するディレクトリ
end
```
#### gmailを取得できるか確認
[get_gmail_example01.rb](https://github.com/syokenz/marunouchi-mongodb/blob/master/20121106/syokenz/get_gmail_example01.rb) を実行してみる  
注意:[gmail_conf.rb](https://github.com/syokenz/marunouchi-mongodb/blob/master/20121106/syokenz/gmail_conf.rb)を同じディレクトリに配置すること。
```
ruby get_gmail_example01.rb
```
確認:標準出力にGmailの内容が出てるか  

[get_gmail_example02.rb](https://github.com/syokenz/marunouchi-mongodb/blob/master/20121106/syokenz/get_gmail_example02.rb) を実行してみる  
注意:[gmail_conf.rb](https://github.com/syokenz/marunouchi-mongodb/blob/master/20121106/syokenz/gmail_conf.rb)を同じディレクトリに配置すること。
```
ruby get_gmail_example02.rb
```
確認:IMAGES_DIRに画像が保存されているか  

#### nginxの確認(Mac OS X)
nginxを起動させて、[http://localhost/](http://localhost/) にアクセスしてください。  
※macのhomebrewでインストールすると、localhost:8080がデフォルトポートになっている場合があります

nginx.confを見て、rootディレクトリを確認してください。  
必要があれば、ポートを80に変更してください。  

homebrewでインストールした場合  

起動
```
/usr/local/sbin/nginx
```
停止
```
ps axu | grep [n]ginx #プロセスIDを確認してkill

#homebrewでpgrepをインストールしておくと便利です。
brew install pgrep
pgrep 'nginx' | xargs kill
```
設定ファイル:```/usr/local/etc/nginx/nginx.conf```
```
server {
  listen       80; # 8080から80へ変更
  server_name  localhost;
...

```

rootディレクトリ:```/usr/local/Cellar/nginx/1.2.1/html```
```
mkdir /usr/local/Cellar/nginx/1.2.1/html/mongo
echo 'here is mongo!' > /usr/local/Cellar/nginx/1.2.1/html/mongo/index.html
```

[http://localhost/mongo/](http://localhost/mongo/)にアクセス

#### nginxの確認(Windows)
起動
```
start nginx
```

停止
```
nginx -s quit
```

設定ファイル再読み込み
```
nginx -s reload
```



## RESTでjsonを見てみよう
mognodを起動  
```
# mongod.confのlogpath,dbpath,pidfilepathを環境に合わせて変更
mongod -f mongod.conf
```
[mongod.conf](https://github.com/syokenz/marunouchi-mongodb/blob/master/20121106/syokenz/mongod.conf)
```
#この2つがポイント
rest = true
jsonp = true
```

[http://localhost:28017](http://localhost:28017)にアクセス  
確認:webコンソールは見えるか  

テストデータのインサート
```js
use test
for(var i=1; i<=10; i++) db.marunouchi.insert({"stock":i})
//確認
db.marunouchi.find()
```

#### RESTインターフェース

```js
//find()
curl 'http://localhost:28017/test/marunouchi/'

//find({x:100})
curl 'http://localhost:28017/test/marunouchi/?filter_x=200'

//find().limit(10)
curl 'http://localhost:28017/test/marunouchi/?limit=10'

//count()
curl 'http://localhost:28017/test/$cmd/?filter_count=maru&limit=1'
// => rows[0].nにcount数が入る

//insert
//公式ドキュメントではno supportとあるがpostするとinsertできる
//http://www.mongodb.org/display/DOCS/Http+Interface
curl -d '{x:100, y:200}' 'http://localhost:28017/test/marunouchi/'

```

ソース見たけど、updateは無さそう。  
[https://github.com/mongodb/mongo/blob/master/src/mongo/db/restapi.cpp](https://github.com/mongodb/mongo/blob/master/src/mongo/db/restapi.cpp)



## MongoDBにデータをinsert

ruby用mongoドライバのインストール
```
gem install mongo
```
確認
```rb
$ irb
irb(main):001:0> require 'mongo'
=> true #trueになることを確認
```

[get_gmail_example03.rb](https://github.com/syokenz/marunouchi-mongodb/blob/master/20121106/syokenz/get_gmail_example03.rb) を実行してみる  
注意:[gmail_conf.rb](https://github.com/syokenz/marunouchi-mongodb/blob/master/20121106/syokenz/gmail_conf.rb)を同じディレクトリに配置すること。
```
ruby get_gmail_example03.rb
```
確認
```
$ mongo
> use gmail
> db.attach_images.count()

```

コンテンジェンシープラン
```
mongorestore --collection attach_images --db gmail dump/gmail/
```

## viewの作成

#### 実装する機能
画像表示  

#### こんな機能があるといいかも
条件検索  
リミット、ページング  


