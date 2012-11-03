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

ユーザ