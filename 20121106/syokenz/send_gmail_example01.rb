#coding: utf-8
$LOAD_PATH.push('.')
require 'gmail_conf'

$LOAD_PATH.push(GConf::LIBPATH) 
require 'gmail'


gmail = Gmail.new(GConf::USERNAME,GConf::PASSWORD)

email = gmail.generate_message do
  to "syokenz@gmail.com"
  subject "Send From Ruby!!"
  body "Spent the day on the road..."
end
gmail.deliver(email)

gmail.disconnect
