MongoDBをカスタムビルドしてみよう
=================

## ドキュメント
http://www.mongodb.org/display/DOCS/Building


## Linux（CentOS 5.4 64bitで確認）
必要なライブラリ  
- gcc-c++
- glibc-devel
- scons

```
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm
yum --enablerepo=rpmforge -y install git-core gcc-c++ glibc-devel scons
```

## Mac OSX (10.6 snow leopardで確認)
必要なライブラリ  
- Xcode  
- scons 

```
port install scons
```

## build（Linux、Mac共通）
```
git clone https://github.com/mongodb/mongo.git
cd mongo
git checkout -b r2.2.0
scons -h # オプションの確認
scons all
```

初回ビルドはcore 2 duo 2.4Ghzで30分程度かかる。  
一度ビルドしたら、targetを指定することでビルド時間を短くできる。  
http://www.mongodb.org/display/DOCS/scons

```
scons all         #build all
scons mongod      #build mongod (this is the default target if none is specified)
scons mongo       #build the shell
scons mongoclient #build just the client library (builds libmongoclient.a on Unix)
scons test        #build the unit test binary test
```
Options
```
--d        #debug build; all this does is turns optimization off
--dd       #debug build with _DEBUG defined (extra asserts, checks, etc.)
--release  #release build
--32       #force 32 bit
--64       #force 64 bit
--clean    #cleans the target specified
--mute     #suppress compile and link command lines
--usesm    #use spider monkey for javascript
--usev8    #use v8 for javascript
```

ビルドが成功すると、buildディレクトリ以下にバイナリが作成されます。

## Version表示を変更してみよう

カスタムビルドがわかるように、mongod起動時に表示されるバージョン情報を変更してみよう

### 修正するファイル

[src/mongo/util/version.cpp](https://github.com/mongodb/mongo/blob/master/src/mongo/util/version.cpp)

```cpp
...
    /* Approved formats for versionString:
     *      1.2.3
     *      1.2.3-pre-
     *      1.2.3-rc4 (up to rc9)
     *      1.2.3-rc4-pre-
     * If you really need to do something else you'll need to fix _versionArray()
     */
    const char versionString[] = "2.2.2-pre-";
...
```

### ビルド

```
scons mongod
```

### 確認

ビルドしたmongodを起動させます。
Macの場合、以下のパスにビルドされています。

```
./build/darwin/normal/mongo/mongod
```

## RESR APIに機能を追加してみよう

REST APIにremoveを実装してみよう

### 修正するファイル

[src/mongo/db/restapi.cpp](https://github.com/mongodb/mongo/blob/master/src/mongo/db/restapi.cpp)

```cpp
...
if ( method == "GET" ) {
  responseCode = 200;
  html = handleRESTQuery( fullns , action , params , responseCode , ss  );
}
else if ( method == "POST" ) {
  responseCode = 201;
  handlePost( fullns , MiniWebServer::body( rq ) , params , responseCode , ss  );
}
else {
  responseCode = 400;
  headers.push_back( "X_err: bad request" );
  ss << "don't know how to handle a [" << method << "]";
  out() << "don't know how to handle a [" << method << "]" << endl;
}
...
```

### 参考にするファイル

insert, updateなどのメソッドが定義されている。  
[src/mongo/client/dbclient.cpp](https://github.com/mongodb/mongo/blob/master/src/mongo/client/dbclient.cpp)

```cpp
...
    void DBClientBase::remove( const string & ns , Query obj , bool justOne ) {
        int flags = 0;
        if( justOne ) flags |= RemoveOption_JustOne;
        remove( ns, obj, flags );
    }
...
```

### 確認

ビルド後、restオプションをつけて起動する

```
./build/darwin/normal/mongo/mongod --rest
```

### 使うコマンド

コンソールからcurlでアクセス

```
# find
curl http://localhost:28017/test/mongonouchi/
# insert
curl -d "{x:100}" http://localhost:28017/test/mongonouchi/
## ↑ここまではオリジナルで実装されている

# remove
curl -X DELETE -d "{x:100}" http://localhost:28017/test/mongonouchi/

```
