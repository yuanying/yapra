## Filter::EntryFullText -- Yuanying
##
## get the entry full text from page with WWW::Mechanize.
## 
## - module: Filter::EntryFullText
##   config:
##     regexp: http://www\.pixiv\.net/*
##     extract_xpath:
##       title: '//title/text()'
##       dc_creator: "//div[@id='profile']/div/text()"
##       author: "//div[@id='profile']/div/text()"
##       description: "//div[@id='content2']"
##     apply_template_after_extacted:
##       content_encoded: '<div><%= title %></div>'
##
require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Feed
  class EntryFullText < Yapra::Plugin::MechanizeBase
    def run(data)
      regexp = nil
      if config['regexp']
        regexp = Regexp.new(config['regexp'])
      else
        regexp = /^(https?|ftp)(:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+)$/
      end
      
      data.map! do |item|
        url = item
        if item.respond_to?('link')
          url = item.link
        end

        if regexp =~ url
          page = agent.get(url)
          sleep 1

          unless(item.instance_of?(RSS::RDF::Item))
            new_item = RSS::RDF::Item.new
            new_item.title = item.title rescue item.to_s
            new_item.date = item.date rescue Time.now
            new_item.description = item.description rescue item.to_s
            new_item.link = item.link rescue '#'
            item = new_item
          end

          extract_attribute_from page.root, item

        end
        item
      end
      
      data
    end
  end
end
