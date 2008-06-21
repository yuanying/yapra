require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Publish
  # = Publish::OnMemoryDownload -- Yuanying
  # 
  # download web resource and set to item attribute.
  # 
  # example: 
  # 
  #     - module: Publish::OnMemoryDownload
  #       config:
  #         regexp: http://www\.yahoo\.co\.jp/*
  #         attribute: binary_image
  #         auto_suffix: true
  #         before_hook: "agent.get('http://www.yahoo.co.jp/'); sleep 1"
  #         url:
  #           attribute: link
  #           replace: index(\d*?)\.html
  #           to: file\1.zip
  #         referrer:
  #           attribute: link
  #           replace: 'zip'
  #           to: 'html'
  #
  class OnMemoryDownload < Yapra::Plugin::MechanizeBase
    def run(data)
      regexp = nil
      if config['regexp']
        regexp = Regexp.new(config['regexp'])
      else
        regexp = /^(https?|ftp)(:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+)$/
      end
      
      wait = config['wait'] || 3

      data.each do |item|
        url = construct_data(config['url'], item, item.respond_to?('link') ? item.link : item)

        if regexp =~ url
          referrer = construct_data(config['referrer'], item)
          download(item, url, referrer)
          sleep wait
        end
      end
      
      data
    end
    
    protected
    def construct_data(config, item, original=nil)
      if config && config['attribute']
        if item.respond_to?(config['attribute'])
          original = item.__send__(config['attribute'])
        end
      elsif config
        original = item
      end

      if original && config && config['replace']
        original = original.gsub(config['replace'], config['to'] || Time.now.to_s)
      end

      original
    end
    
    def save config, item, page
      set_attribute_to item, config['attribute'], page.body
    end
    
    def download(item, url, referrer)
      if config['before_hook']
        eval(config['before_hook'])
      end
      
      dir = config['dir']
      
      page = agent.get(url, referrer)
      logger.info "Download: #{url}"
      
      save(config, item, page)
      
      if config['after_hook']
        eval(config['after_hook'])
      end
    end
  end
end