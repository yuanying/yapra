require 'yapra/legacy_plugin'
require 'yapra/inflector'

module Yapra::LegacyPlugin
  #
  # AdvanceModeRegistry load legacy plugin at one by one.
  #
  class AdvanceModeRegistry
    attr_accessor :legacy_plugins
    attr_accessor :plugin_paths
    attr_accessor :pipeline

    # _paths_ :: Directory paths which contain legacy plugins.
    # _pipeline_ :: Runtime pipline.
    def initialize paths, pipeline
      self.legacy_plugins = {}
      self.plugin_paths = paths.reverse
      self.pipeline = pipeline
    end

    def logger
      Yapra::Runtime.logger
    end

    # load plugin from module name.
    #
    # example:
    #
    #     registry = Yapra::LegacyPlugin::AdvanceModeRegistry.new(paths, pipeline)
    #     feed_load_plugin = registry.get('Feed::load')
    #
    def get module_name
      plugin = legacy_plugins[module_name]
      unless plugin
        plugin_paths.each do |folder|
          file = File.join(folder, (module_name.gsub('::', '/') + '.rb'))
          if File.file?(file)
            plugin = Yapra::LegacyPlugin::Base.new(pipeline, file)
            legacy_plugins[ module_name ] = plugin
            logger.debug "#{module_name} is loaded from #{file}"
            break
          end
        end
      end
      raise "#{module_name} is not registered." unless plugin
      plugin
    end
  end
end