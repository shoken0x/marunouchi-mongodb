MongoDBでアプリをつくろう
=================

## 準備

ruby-gmailのインストール
```
gem install mail --no-ri --no-rdoc
git clone https://github.com/syokenz/ruby-gmail.git
```

Gmail設定の変更
```ruby
class GConf
  LIBPATH='D:\src\git\ruby-gmail\lib' #ruby-gmail/libへのパス
  USERNAME='_@gmail.com'    #Gmailのアドレス
  PASSWORD='xxxx'          #Gmailのパスワード
  IMAGES_DIR='D:\\tmp\\'              #画像を保存するディレクトリ
end
```
#### gmailを取得できるか確認
get_gmail_example01.rb を実行してみる  
確認:標準出力にGmailの内容が出てるか  

get_gmail_example02.rb を実行してみる  
確認:IMAGES_DIRに画像が保存されているか  

#### nginxの確認

## MongoDBにデータをinsert


## RESTでjsonを見てみよう
mognodを起動  

http://localhost:28017 にアクセス  
確認:webコンソールは見えるか  

テストデータのインサート
'''js
use test
for(var i=1; i<=10; i++) db.marunouchi.insert({"stock":i})
'''

http://localhost:28017/test/marunouchi

## viewの作成
画像表示  
条件検索  
リミット、ページング  

## jQueryとか
アニメーション  
ドラッガブル  

