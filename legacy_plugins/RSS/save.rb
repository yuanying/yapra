## Save RSS as a file -- IKeJI
## 
## Save RSS as a file.
## Title, Link, and Description of the RSS can be set.
## The input is expected to be an Array of RSS::RDF::Item.
##
## - module: RSS::save
##   config:
##     title: An Title
##     link: http://www.example.com/hoge.rdf
##     description: sample rdf

require "rss/maker"

@count = Time.now.to_i

def save(config,data)
  rss = RSS::Maker.make("1.0") do |maker|
    maker.channel.about = config['about'] || config['link'] || "http://example.net/"
    maker.channel.title = config['title'] || "Pragger output"
    maker.channel.description = config['description'] || ""
    maker.channel.link = config['link'] || "http://example.net/"
    
    data.each do |i|
      if(i.instance_of?(RSS::RDF::Item))
        i.setup_maker(maker)
      else 
        item = maker.items.new_item
        item.title = i.title rescue i.to_s
        item.link = i.link rescue (config['link'] || "http://example.net/") + "\##{@count}"
        item.description = i.description rescue i.to_s
        item.date = i.date rescue Time.now
        @count += 1
      end
    end
  end
  open(config["filename"],"w"){|w| w.puts rss }
  return data
end


