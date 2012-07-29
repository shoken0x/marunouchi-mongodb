require 'mongo'
require 'open-uri'
require 'pp'

# parse it-ebooks page
def parse_html(html)

  return {
    "title" => html.scan(/<h1>(.*)<\/h1>/)[0].join ,
    "author" => html.scan(/<tr><td>By:<\/td><td><b>(.*)<\/b><\/td><\/tr>/)[0].join,
    "year" => html.scan(/<tr><td>Year:<\/td><td><b>(.*)<\/b><\/td><\/tr>/)[0].join,
    "page" => html.scan(/<tr><td>Paperback:<\/td><td><b>(.*) pages<\/b><\/td><\/tr>/)[0].join,
    "file" => {
      "size" => html.scan(/<tr><td>File size:<\/td><td><b>(.*)<\/b><\/td><\/tr>/)[0].join,
      "format" => html.scan(/<tr><td>File format:<\/td><td><b>(.*)<\/b><\/td><\/tr>/)[0].join,
      "url" => "http://it-ebooks.info/go/" + html.scan(/href="\/go\/(.*?)['"]/)[0].join
    }
  }

end

# main

con = Mongo::Connection.new
db = con.db("bookgetter")
coll = db["books"]
coll.remove

for i in 1..10

  html = ""
  open("http://it-ebooks.info/book/#{i.to_s}/"){ |f|
    html << f.read
  }

  book_data = parse_html(html)
  # pp book_data

  coll.insert(book_data)
end

pp coll.find.to_a

