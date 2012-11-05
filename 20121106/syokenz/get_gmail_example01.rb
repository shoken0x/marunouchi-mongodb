#coding: utf-8
$LOAD_PATH.push('.')
require 'gmail_conf'

$LOAD_PATH.push(GConf::LIBPATH) 
require 'gmail'

MAX_DL_SIZE = 3;

gmail = Gmail.new(GConf::USERNAME,GConf::PASSWORD)

gmail.inbox.emails(:all).each_with_index do |mail,i| #emailsの引数には:all,:read,:unreadがある
  #件名、日付、From、To
  puts "Subject: #{mail.subject}"
  puts "Date: #{mail.date}"
  puts "From: #{mail.from}"
  puts "To: #{mail.to}"

  #本文処理
  if !mail.text_part && !mail.html_part
    puts "body: " + mail.body.decoded.encode("UTF-8", mail.charset)
  elsif mail.text_part
    puts "text: " + mail.text_part.decoded
  elsif mail.html_part
    puts "html: " + mail.html_part.decoded
  end 

  if i+1 == MAX_DL_SIZE
    break
  end
end

gmail.disconnect
