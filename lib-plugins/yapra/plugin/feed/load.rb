require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Feed
  # = Load RSS from given URLs
  # 
  # Load RSS from given URLs.
  # If URL is an Array, all URLs in the array will be loaded.
  # 
  #     - module: RSS::load
  #       config:
  #         uri: http://www.example.com/hoge.rdf
  #
  class Load < Yapra::Plugin::MechanizeBase
    def run(data)
      urls = 
        if config['url'].kind_of?(Array)
          config['url']
        else
          [ config['url'] ]
        end
      
      urls.each.do |url|
        logger.debug("Process: #{url}")
        source = agent.get(url).body
        rss = nil
        begin
          rss = RSS::Parser.parse(cont)
        rescue
          rss = RSS::Parser.parse(cont, false)
        end
        rss.items.each do |item|
          data << item
        end
      end
      
      data
    end
  end
end
