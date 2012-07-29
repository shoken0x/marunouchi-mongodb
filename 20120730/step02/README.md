#MongoDB-Ruby driverのインストール手順（Windows版)

##Rubyのインストール

Ruby Installerでインストールするのが簡単です。
（普通のrubyを入れる場合、zlibやopensslを入れる必要があり面倒ですが、これなら不要です）

1. http://rubyinstaller.org/downloads/　にアクセス。
1. Ruby 1.9.3-p194のをクリック
1. インストらーに従ってインストール

##環境変数の設定

1. PATHに「C:\Ruby193\bin」を追加
1.  コマンドプロンプトで
> $ ruby -v  
> ruby 1.9.3p194 (2012-04-20) [i386-mingw32] ←バージョンが出ることを確認  
> 
> $ irb  
> irb(main):001:0> require 'openssl'  
> => true　←trueになることを確認  

##MongoDB Ruby driverのインストール

1. Mongo DBインストール
> $ gem install mongo  
> Fetching: bson-1.6.4.gem (100%)  
> Fetching: mongo-1.6.4.gem (100%)  
> Successfully installed bson-1.6.4  
> Successfully installed mongo-1.6.4  
> 2 gems installed  
> Installing ri documentation for bson-1.6.4...  
> Installing ri documentation for mongo-1.6.4...  
> Installing RDoc documentation for bson-1.6.4...  
> Installing RDoc documentation for mongo-1.6.4...  

2. 確認
> $irb  
> irb(main):001:0> require 'mongo'  
> => true　←trueになることを確認  

※)以下のメッセージが出ることがあります。
<pre>
**Notice: C extension not loaded. This is required for optimum MongoDB Ruby driv
er performance.
You can install the extension as follows:
gem install bson_ext

If you continue to receive this message after installing, make sure that the
bson_ext gem is in your load path and that the bson_ext and mongo gems are of
the same version.
</pre>
これはC Extentionという高速アクセスのためのドライバがないためです。
今回スピードは関係ないので無視でよいです。

気になる人は、ruby起動時に -W0というオプションを付けることで、
メッセージを抑止できます。
> $ ruby -W0 test.rb

