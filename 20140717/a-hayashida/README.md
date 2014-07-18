みんなでクラスタ
=================

さあ！このシステムを４人一組で組んでください！

ヒントは[こちら](https://github.com/syokenz/marunouchi-mongodb/tree/master/20120926/fetarodc/step2#%E8%A4%87%E6%95%B0shard%E3%81%A7%E3%83%87%E3%83%BC%E3%82%BF%E5%88%86%E6%95%A3%E3%83%AC%E3%83%97%E3%83%AA%E3%82%AB)

環境への繋ぎ方
-----------------

※）接続用のKeyPairは当日お渡しします。

各自の担当hostに接続してください。

```
$ ssh [担当hostのIP]
```

※）まずは、各hostのmongodに接続が可能かどうか確認しましょう。（# mongo --host [IP] --port [PORT]）

物理構成図
-----------------

![物理構成図](https://cacoo.com/diagrams/CQcA9aJslOwzpU6K-EBC21.png)

論理構成図
-----------------

![論理構成図](https://cacoo.com/diagrams/kyoRpiZSDLv6f2lQ-EBC21.png)


障害実験
-----------------

* mongosへ問い合わせをしながら、どれか一台のmongodのマシンのNICを止めて落としてみましょう。
* そのマシンを復活させてみましょう。

個人的に試してみたい方へ
-----------------
玉川さん謹製レプリカセットお試しキットは[こちら](https://bitbucket.org/tamagawa_ryuji/mongodb_replicaset_playground_on_vagrant)

答えの手順は[コチラ](https://github.com/syokenz/marunouchi-mongodb/blob/master/20140717/a-hayashida/answer.md)
