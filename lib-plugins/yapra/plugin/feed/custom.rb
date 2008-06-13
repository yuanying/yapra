## - module: Feed::Custom
##   config:
##     url: 'http://www.fraction.jp/'
##     extract_xpath:
##       capture: '//div'
##       split: '//div[@class="test"]'
##       description: '//div'
##       link: '//li[2]'
##       title: '//p'
##     apply_template_after_extacted:
##       content_encoded: '<div><%= title %></div>'
##
require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Feed
  class Custom < Yapra::Plugin::MechanizeBase
    def run(data)
      page    = agent.get(config['url'])
      root    = page.root
      
      xconfig = config['extract_xpath']
      
      if xconfig['capture']
        root = root.at(xconfig['capture'])
      end
      split = xconfig['split']
      xconfig.delete('capture')
      xconfig.delete('split')
      
      root.search(split).each do |element|
        item = RSS::RDF::Item.new
        
        extract_attribute_from element, item

        data << item
      end
      
      data
    end
  end
end
