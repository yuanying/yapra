require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Feed
  class Load < Yapra::Plugin::MechanizeBase
    def run(data)
      urls = 
        if config['url'].kind_of?(Array)
          config['url']
        else
          [ config['url'] ]
        end
      
      urls.each.do |url|
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
