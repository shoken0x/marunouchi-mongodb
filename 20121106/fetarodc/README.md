Configパラメータ解説
=================

オプションの設定の仕方
-----------------

ここを解説します
http://docs.mongodb.org/manual/reference/configuration-options/

パラメータ解説
-----------------

### verbose
ログレベル
```
verbose = true
vv = true
vvv = true
vvvvv = true
quiet = true
```

### port
Default: 27017

### bind_ip
Default: All interfaces.
","区切りで複数指定可能

### maxConns 
Default: depends on system limit

OSのulimitやファイルディスクリプタの制限がなければいくらでも作ることができる
少なくとも5以上

動作確認
```
Sat Nov  3 11:57:17 [initandlisten] connection accepted from 192.168.1.42:32934 #1 (1 connection now open)
Sat Nov  3 11:57:31 [initandlisten] connection accepted from 192.168.1.42:32935 #2 (2 connections now open)
Sat Nov  3 11:57:32 [initandlisten] connection accepted from 192.168.1.42:32936 #3 (3 connections now open)
Sat Nov  3 11:57:33 [initandlisten] connection accepted from 192.168.1.42:32937 #4 (4 connections now open)
Sat Nov  3 11:57:33 [initandlisten] connection accepted from 192.168.1.42:32938 #5 (5 connections now open)
Sat Nov  3 11:57:35 [initandlisten] connection accepted from 192.168.1.42:32939 #6 (6 connections now open)
Sat Nov  3 11:57:35 [initandlisten] connection refused because too many open connections: 5
```

### objcheck
Default: false

ユーザのリクエストをチェックして、不正なBSONオブジェクトの挿入を防ぐ。
オーバーヘッドがあるためデフォルトはfalse

### logpath

Default: None. (i.e. /dev/stdout)
ログパス。
logappendを指定しないと上書きしてしまう。
ただしこの動きは近いうちに代わり、古いログはローテーションするようになるかも

###  logappend

Default: false
ログに上書きするかどうか

###  syslog
ログをsyslogに出す。lopathと併用してはダメ。

###  pidfilepath
Default: None.
デフォルトだとPIDファイル作らない

### keyFile
Default: None.
レプリカセットやシャーディングのメンバで認証するための情報
openSSLのコマンドで作るとよい

[root@haruko mongodb-linux-x86_64-2.2.1]# openssl rand -base64 17
RYVwrEwolKmnTgjiNGHyxRk=

詳しくは
http://docs.mongodb.org/manual/administration/replica-sets/#replica-set-security


### nounixsocket

```
# ./bin/mongod --dbpath db --nounixsocket &
# netstat -na | grep 27017
tcp        0      0 0.0.0.0:27017               0.0.0.0:*                   LISTEN

./bin/mongod --dbpath db &
# netstat -na | grep 27017
tcp        0      0 0.0.0.0:27017               0.0.0.0:*                   LISTEN
unix  2      [ ACC ]     STREAM     LISTENING     167023 /tmp/mongodb-27017.sock
```

### unixSocketPrefix
Default: /tmp

### fork
Default: false
バックグラウンドで動かす
--logpath or --syslog が必要

### auth
Default: false
認証を有効にする。

> use admin
> db.addUser("i2bs","secret")
> db.system.users.find()
bin/mongo mydb -u i2bs -p secret

### cpu
Default: false
4秒おきにcpu使用率を記録
```
Sat Nov  3 12:47:16 [snapshotthread] cpu: elapsed:4000  writelock: 0%
Sat Nov  3 12:47:20 [snapshotthread] cpu: elapsed:4000  writelock: 0%
Sat Nov  3 12:47:24 [snapshotthread] cpu: elapsed:4000  writelock: 0%
```

### dbpath
Default: /data/db/

パッケージマネジメントシステムでインストールすると/etc/mongodb.confに書いてあるdbpathを使う

### 