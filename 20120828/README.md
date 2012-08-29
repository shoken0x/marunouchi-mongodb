Marunouchi.mongo 20120828
=================
みんなでMongoDBについて勉強しましょう。
今回のテーマはシャーディング！

[丸の内MongoDB勉強会 #2 - ATND](http://atnd.org/events/31234)

![marunouchi.mongodb logo](http://www.fedc.biz/~fujisaki/img/mongodb_logo.png)


# 流れ
* 懇親会の出席を取る
* [雲屋株式会社](http://kumoya.com/) 様ご提供のステッカーを配る
* [MongoDB Sharding Overview](https://github.com/syokenz/marunouchi-mongodb/tree/master/20120828/syokenz)
* [シャーディングの設定](https://github.com/syokenz/marunouchi-mongodb/tree/master/20120828/syokenz/step01)
* [障害発生時の挙動](https://github.com/syokenz/marunouchi-mongodb/tree/master/20120828/syokenz/step02)
* [みんなでシャーディング](https://github.com/syokenz/marunouchi-mongodb/tree/master/20120828/syokenz/step03)
* みんなで質問とか、第3回でどんなことをやるかとか
  * 第3回はReplicaSets？、2.2の新機能？
* 懇親会へ

![mm20120730.png](http://www.fedc.biz/~fujisaki/img/mm20120828.jpg)

# 会場で出た質問 => 第３回で勉強しましょう！
- ReplicaSetsでPrimaryがダウンしたら、SecondaryがPrimaryに昇格するが、優先度は設定できるのか
 - priority設定できます。選出基準は、1.priorityが最大、2.primaryとの最終同期が最新、3.votes値が高いで決まるようです。
 - 参考：[〜うまく動かすMongoDB〜仕組みや挙動を理解する](http://doryokujin.hatenablog.jp/entry/20110519/1305737343)の中程
- ReplicaSetsは最低３つのmongodで構成されると聞いているが、２つでも構成可能
- Sharding+ReplicaSetsの構成での挙動で、ReplicaSetsのPrimaryが落ちた場合の挙動はどうなるか
- Sharding環境で大量データinsert後にchunkの移動が起こるが、その際にcount()すると実際のデータよりも多くカウントされてしまう。どのように回避すればよいか。


# 参考資料
* [Mongo sharding @doryokujinさん - slideshare](http://www.slideshare.net/doryokujin/mongo-sharding)  
* [MongoDB公式マニュアル Sharding](http://www.mongodb.org/display/DOCSJP/Sharding)  

# 参加者
1. [@syokenz](http://twitter.com/syokenz)
1. [@fetarodc](http://twitter.com/fetarodc)
1. [@rinrin0108](http://twitter.com/rinrin0108)
1. [@naru0ga](http://twitter.com/naru0ga)
1. [@jovi0608](http://twitter.com/jovi0608)
1. [@nobumin](http://twitter.com/nobumin)
1. naotow
1. [@modsound](http://twitter.com/modsound)
1. [@mikamix](http://twitter.com/mikamix)
1. [@kurofune2002](http://twitter.com/kurofune2002)
1. [@moccos](http://twitter.com/moccos)
1. [@fukata](http://twitter.com/fukata)
1. [@kara_d](http://twitter.com/kara_d)
1. [@joker1007](http://twitter.com/joker1007)
1. [@shin_semiya](http://twitter.com/shin_semiya)
1. [@yokoom](http://twitter.com/yokoom)
1. tkoike
1. ferrylikeboy
1. shigex



# Blog
* [丸の内MongoDB勉強会 #2 やりました - Shoken OpenSource Society](http://shoken.hatenablog.com/entry/2012/08/29/122101)




