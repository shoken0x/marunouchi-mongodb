ソースコードリーディング入門
=================
MongoDBのソースコードをちょっとだけ読んでみよう


## ソースコードの準備

githubからcloneする
```
git clone https://github.com/mongodb/mongo.git
```

必要があれば、tagをチェックアウト
```
git checkout -b r2.2.0
```

## 全体感の把握
https://github.com/mongodb/mongo
```
mongo / 
┬─buildscripts   
├─debian          
├─distsrc　        
├─docs　           
├─jstest　　       
├─rpm              
├─site_scons     
├─src                
...
└─
```
```
src / mongo
┬─base              
├─bson              
├─client             
├─db                 
├─dbtests           
├─platform         
├─s                    
├─scripting         
├─shell               
├─tools               
├─unittest           
├─util                  
├─SConscript       
├─pch.cpp           
├─pch.h              
├─server.h          
└─targetver.h      
```



このサイトが参考になる。  
MongoDB Class List
http://mediabox.grasp.upenn.edu/roswiki/doc/unstable/api/mongodb/html/annotated.html


## ツールの確認

### git grep

使い方
```
git grep "検索単語"
```

.gitconfig
```
[color]	
	ui = true
[grep]
	lineNumber = true
[alias]	
	g = grep -H --heading --break
```

オプション
```
    -e : 検索に正規表現を使用する。省力可能。
    -i / --ignore-case : 大文字小文字を区別せずマッチします
    -I : バイナリファイルを無視します
    -w / --word-regexp : 検索文字が単語としてマッチする時のみマッチするようになります。このオプションが指定されているとき a は abc にマッチしません
    -v / --invert-match : 実際にマッチした単語がない行も表示します
    -h / -H : マッチしたファイル名を行頭に表示するか否かの指定です。
    --full-name : ファイル名を表示する時、詳細なファイルパスを出力するようにします(デフォルトでは basename のみ)
    -E / --extended-regexp : 検索に POSIX の拡張正規表現を利用します
    -G / --basic-regexp : 検索に POSIX の標準正規表現を利用します
    -P / --perl-regexp : 検索に Perl の正規表現を利用します
    -F / --fixed-strings : 検索に正規表現を利用しません
    -n / --line-number : マッチしたファイル名の後ろにマッチした行数を表示します
    -l / --files-with-matches / --name-only : マッチしたファイルのファイル名だけを表示します
    -L / --files-without-match : マッチしなかったファイル名だけを表示します

```

## 実践

### ソースコードから起動オプションの挙動を理解する

目的
```
前回の丸の内MongoDB勉強会で不明な起動オプションがいくつかあった。
ドキュメントを読んでも理解できない部分があったので、ソースコードを読んで処理を理解する。
```

### 不明な起動オプションその1：noscripting

#### まずはgrepしてみる

```cpp
git grep "noscripting"
...cpp
src/mongo/db/db.cpp:882:        if (params.count("noscripting")) {
...
```
db.cppが引っかかった。  
`TIPS`booleanをとる起動オプションではif文がポイントとなる  
  
src/mongo/db/db.cppを見てみる  
```cpp
        if (params.count("noscripting")) {
            scriptingEnabled = false;
        }
```
`scriptingEnabled`を検索、db.cppにあった。  
src/mongo/db/db.cpp
```cpp
        if ( scriptingEnabled ) {
            ScriptEngine::setup();
            globalScriptEngine->setCheckInterruptCallback( jsInterruptCallback );
            globalScriptEngine->setGetInterruptSpecCallback( jsGetInterruptSpecCallback );
        }
```
`ScriptEngine::setup();`に着目。grepしてみる。
```cpp
git grep "ScriptEngine::setup();"
...
src/mongo/scripting/engine_none.cpp:21:    void ScriptEngine::setup() {
src/mongo/scripting/engine_spidermonkey.cpp:1406:    void ScriptEngine::setup() {
src/mongo/scripting/engine_v8.cpp:342:    void ScriptEngine::setup() {
...
```
v2.2ではjsエンジンはspidermonkeyなので、engine_spidermonkey.cppを見てみる。  
src/mongo/scripting/engine_spidermonkey.cpp
```cpp
    void ScriptEngine::setup() {
        spidermonkey::globalSMEngine = new spidermonkey::SMEngine();
        globalScriptEngine = spidermonkey::globalSMEngine;
    }
```
`globalScriptEngine`に着目。grepしてみる。  
`TIPS`検索単語の前後にスペースを入れると、変数として使用されている箇所に引っかかる
```
git grep " globalScriptEngine "  
...cpp
src/mongo/db/dbeval.cpp:57:        if ( ! globalScriptEngine ) {
...
```
dbeval.cppを読む。よくわからないので、"mongodb eval"でググってみる。  
db.eval()というshellから使えるコマンドがある。これは、引数にJavaScriptをとって評価するメソッド。  
わかった！

#### でもあわてずに実証してみる
noscriptingのデフォルトはfalse  
参考：[MongoDB全設定値解説](https://github.com/syokenz/marunouchi-mongodb/tree/master/20121106/fetarodc#noscripting)  
デフォルトで起動した場合の挙動
```
$ mongo
> db.eval(function() { return 3+3; } )
6
```

`noscripting=true`で起動した場合の挙動
```
$ mongo
> db.eval(function() { return 3+3; } )
Tue Dec 18 19:11:01 uncaught exception: { "errmsg" : "db side execution is disabled", "ok" : 0 }
```

### 不明な起動オプションその2：notablescan
