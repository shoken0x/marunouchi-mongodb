# -*- coding: utf-8 -*-
require 'mongo'

con = Mongo::Connection.new #MongoDBに接続
db = con.db("mydb")         #DBを指定
coll = db["mycoll"]         #Collectionを指定

#collにDoccumentの挿入
coll.insert( { "name" => "fujisaki", "age" => 30 } )
coll.insert( { "name" => "watanabe", "age" => 29 } )
coll.insert( { "name" => "hayashida", "age" => 24 } )

#collの中のDocumentをループで回す
coll.find.each { |doc|
  p doc
}

#collを削除する
coll.remove()
