require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Feed
  # = Feed::Custom
  #
  # generate rss feed from web page.
  #
  # example:
  #
  #     - module: Feed::Custom
  #       config:
  #         url: 'http://www.fraction.jp/'
  #         extract_xpath:
  #           capture: '//div'
  #           split: '//div[@class="test"]'
  #           description: '//div'
  #           link: '//li[2]'
  #           title: '//p'
  #         apply_template_after_extracted:
  #           content_encoded: '<div><%= title %></div>'
  class Custom < Yapra::Plugin::MechanizeBase
    def run(data)
      urls =
        if config['url'].kind_of?(Array)
          config['url']
        else
          [ config['url'] ]
        end
      xconfig = config['extract_xpath']
      wait    = config['wait'] || 1
      capture = xconfig['capture']
      split   = xconfig['split']

      xconfig.delete('capture')
      xconfig.delete('split')

      urls.each do |url|
        logger.debug("Process: #{url}")
        page    = agent.get(url)
        root    = page.root

        if capture
          root = root.at(capture)
        end

        root.search(split).each do |element|
          item = RSS::RDF::Item.new

          extract_attribute_from element, item, binding

          data << item
        end
        sleep wait
      end

      data
    end
  end
end
