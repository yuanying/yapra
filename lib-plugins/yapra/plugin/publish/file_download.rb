## Publish::FileDownload -- Yuanying
##
## download file with WWW::Mechanize.
## 
## example: 
## 
## - module: Publish::FileDownload
##   config:
##     regexp: http://www\.yahoo\.co\.jp/*
##     dir: '/Users/yuanying/Downloads/'
##     auto_suffix: true
##     before_hook: "agent.get('http://www.yahoo.co.jp/'); sleep 1"
##     url:
##       attribute: link
##       replace: index(\d*?)\.html
##       to: file\1.zip
##     filename:
##       attribute: title
##       replace: 'Yahoo'
##       to: ''
##     referrer:
##       attribute: link
##       replace: 'zip'
##       to: 'html'
##
require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Publish
  class FileDownload < Yapra::Plugin::MechanizeBase
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
    
    def discover_extensions page
      require 'mime/types'
      types = MIME::Types[page.content_type]
      if types.size > 0 && types[0].extensions.size > 0
        return type[0].extensions[0]
      else
        logger.info 'suitable extention is not found.'
        return nil
      end
    rescue LoadError => ex
      logger.warn 'require mime-types is failed.'
    end
    
    def download(item, url, referrer)
      dir = config['dir']
      filename = construct_data(config['filename'], item)
      
      if config['before_hook']
        eval(config['before_hook'])
      end
      page = agent.get(url, referrer)
      logger.info "Download: #{url}"
      if config['after_hook']
        eval(config['after_hook'])
      end
      
      filename = page.filename unless filename
      
      if config['auto_suffix']
        ext = discover_extensions(page)
        filename = "#{filename}.#{ext}" if ext
      end

      path = File.join(dir, filename)
      open(path, 'w') do |io|
        io.write page.body
      end
    end
  end
end