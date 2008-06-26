## load lirs file plugin -- takatoh
##
## see http://d.hatena.ne.jp/takatoh/20070308/loadlirs
##
## example
## - module: Feed::load_lirs
##   config: 
##     url: http://example.com/hoge.lirs.gz
##


require 'open-uri'
require 'rss/maker'
require 'zlib'
require 'kconv'

def parse_lirs(record)
  fields = record.chomp.split(",")
  item = RSS::RDF::Item.new
  item.title = fields[6]                                 # Title
  item.link  = fields[5]                                 # URL
item.date  = Time.at(fields[1].to_i + fields[3].to_i)  # Last-Modified (local time)
  return item
end


def lirs(config, data)
  f = open(config["url"])
  lirs = Zlib::GzipReader.wrap(f) {|gz| gz.read }.toutf8
  items = lirs.map {|record| parse_lirs(record) }
  return items
rescue
  puts "LoadError File = #{config["url"]}"
  return []
end

