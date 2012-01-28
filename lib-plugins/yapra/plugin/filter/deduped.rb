require 'yapra/plugin/base'
require 'fileutils'
require 'pathname'
require 'digest/md5'

module Yapra::Plugin::Filter
  # Filter::Deduped - Plugin to get Deduped entries -- original by emergent
  #
  # Plugin to get Deduped entries
  # Cache path can be set.
  #
  # - module: Filter::Deduped
  #   config:
  #    path: /tmp/cache/hoge
  #
  class Deduped < Yapra::Plugin::Base
    def run(data)
      cacheroot = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'cache'))
      cachepath = Pathname.new(config['path']) || cacheroot
      if cachepath.relative?
        cachepath = cacheroot + cachepath
      end

      unless File.exists?(cachepath)
        FileUtils.mkdir_p(cachepath)
      end

      attribute = config['attribute']

      @cache_paths = []
      deduped_data = data.select {|d|
        v = d.link rescue d.to_s
        if attribute && d.respond_to?(attribute)
          v = d.__send__(attribute).to_s
        end
        hashpath = File.join(cachepath.to_s, Digest::MD5.hexdigest(v))
        if File.exists?(hashpath)
          false
        else
          begin
            File.open(hashpath, "wb").write(v)
            @cache_paths << hashpath
            true
          rescue
            false
          end
        end
      }
      return deduped_data
    end

    def on_error(ex)
      logger.debug('error is occured.')
      FileUtils.rm(@cache_paths, {:force => true})
    end
  end
end