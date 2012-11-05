#coding: utf-8
$LOAD_PATH.push('.')
require 'gmail_conf'

$LOAD_PATH.push(GConf::LIBPATH) #ruby-gmailへのパス
require 'gmail'
require 'mongo'
require 'base64'

MAX_DL_SIZE = 3;

db = Mongo::Connection.new.db('gmail')      #DBに接続
coll = db.collection('attach_images') #Collectionを指定

gmail = Gmail.new(GConf::USERNAME,GConf::PASSWORD)

gmail.inbox.emails(:all).each_with_index do |mail,i| #emailsの引数には:all,:read,:unreadがある
  #件名、日付、From、To
  puts "Subject: #{mail.subject}"
  puts "Date: #{mail.date}"
  puts "From: #{mail.from}"
  puts "To: #{mail.to}"

  #本文処理
  if !mail.text_part && !mail.html_part
    body = mail.body.decoded.encode("UTF-8", mail.charset)
    puts "body: " + body
  elsif mail.text_part
    body = mail.text_part.decoded
    puts "text: " + body
  elsif mail.html_part
    body = mail.html_part.decoded
    puts "html: " + body
  end

  #添付ファイル処理
  mail.attachments.each do | attachment |
    # Attachments は添付ファイルのリストのオブジェクト
    if (attachment.content_type.start_with?('image/'))
      # 添付ファイルが画像ファイルだった場合の処理
      filename = attachment.filename
      begin
        File.open(GConf::IMAGES_DIR + filename, "w+b", 0644) {|f| f.write attachment.body.decoded}
        # MongoDBへinsert
        coll.insert({:created_at => Time.now(),   
                     :subject    => mail.subject,
                     :date       => Time.parse(mail.date.to_s),
                     :from       => mail.from,
                     :to         => mail.to,
                     :body       => body,
                     :image      => Base64.encode64(attachment.body.decoded)
                     #:image      => BSON::Binary.new(attachment.body.decoded, 
                     #                                BSON::Binary::SUBTYPE_BYTES)
        })

      rescue Exception => e
        puts "Unable to save data for #{filename} because #{e.message}"
      end
    end
  end

  if i+1 == MAX_DL_SIZE
    break
  end
end
