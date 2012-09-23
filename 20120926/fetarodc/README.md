MongoDB レプリケーション(Replica Sets)
=================

概要
=================

ぶっちゃけ以下の公式ＨＰを約しただけですが、、、
http://www.mongodb.org/display/DOCS/Replica+Sets

Replica sets are a form of asynchronous master/slave replication, adding automatic failover and automatic recovery of member nodes.

    A replica set consists of two or more nodes that are copies of each other. (i.e.: replicas)
    The replica set automatically elects a primary (master). No one member is intrinsically primary; that is, this is a share-nothing design.
    Drivers (and mongos) can automatically detect when a replica set primary changes and will begin sending writes to the new primary. (The mongos sharding process does this too.)

Replica sets have several common uses:

    Data Redundancy
    Automated Failover / High Availability
    Distributing read load
    Simplify maintenance (compared to "normal" master-slave)
    Disaster recovery


* レプリカセットは非同期型マスタ／スレーブ構成のレプリケーションをします。また、自動的にフェールオーバとリリカバーできます。
 * レプリカセットは２つ以上のコピーからなります。
 * レプリカセットは自動的にプライマリノードを選出しますが。ただ、shared-nothingのアーキテクチャに基づいているため、本質的にマスターというものは存在しません（構成的にはどれも同じ）。
 * ドライバ(mongosも同様)は自動的にプライマリノードが変わったことを検知し、新しいプライマリノードに更新をかけるようにします（mongos sharding プロセスも同様）。
 
* レプリカセットの用途
 * データ冗長化
 * 自動フェールオーバ／高可用化
 * 