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
git clone https://github.com/mongodb/mongo
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
