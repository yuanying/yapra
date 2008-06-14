require 'yapra/legacy_plugin'
require 'yapra/inflector'

module Yapra::LegacyPlugin
  
  class AdvanceModeRegistry
    attr_accessor :legacy_plugins
    attr_accessor :logger
    attr_accessor :plugin_paths
    attr_accessor :pipeline
    
    def initialize paths, pipeline, logger
      self.logger = logger
      self.legacy_plugins = {}
      self.plugin_paths = paths.reverse
      self.pipeline = pipeline
    end
    
    def get module_name
      plugin = legacy_plugins[module_name]
      unless plugin
        plugin_paths.each do |folder|
          file = folder + (module_name.gsub('::', '/') + '.rb')
          if file.file?()
            plugin = Yapra::LegacyPlugin::Base.new(pipeline, file)
            legacy_plugins[ module_name ] = plugin
            logger.debug "#{module_name} is loaded."
            break
          end
        end
      end
      raise "#{module_name} is not registered." unless plugin
      plugin
    end
  end
end