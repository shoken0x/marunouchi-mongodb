require 'mongo'

db_name='test'
coll_name='file_test'

db = Mongo::Connection.new.db(db_name)
coll = db.collection(coll_name)
file01 = "15MB.file"
file02 = "16MB.file"

puts "#{file01} insert to mongo ..."
coll.insert({:filename => file01,
             :image => BSON::Binary.new(File.binread(file01),
                                        BSON::Binary::SUBTYPE_BYTES)
            })
puts "insert success\n\n\n"

puts "#{file02} insert to mongo ..."
coll.insert({:filename => file01,
             :image => BSON::Binary.new(File.binread(file02),
                                        BSON::Binary::SUBTYPE_BYTES)
            })
puts "insert success\n\n\n"

db.connection.close