require 'yapra/plugin/publish/on_memory_download'

module Yapra::Plugin::Publish
  # = Publish::FileDownload -- Yuanying
  #
  # download file with WWW::Mechanize.
  #
  # example:
  #
  #     - module: Publish::FileDownload
  #       config:
  #         regexp: http://www\.yahoo\.co\.jp/*
  #         dir: '/Users/yuanying/Downloads/'
  #         auto_suffix: true
  #         before_hook: "agent.get('http://www.yahoo.co.jp/'); sleep 1"
  #         url:
  #           attribute: link
  #           replace: index(\d*?)\.html
  #           to: file\1.zip
  #         filename:
  #           attribute: title
  #           replace: 'Yahoo'
  #           to: ''
  #         referrer:
  #           attribute: link
  #           replace: 'zip'
  #           to: 'html'
  #
  class FileDownload < Yapra::Plugin::Publish::OnMemoryDownload

    protected
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

    def save config, item, page
      filename = construct_data(config['filename'], item)
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