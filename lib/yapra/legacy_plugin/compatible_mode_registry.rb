require 'pathname'
require 'yapra/legacy_plugin'

module Yapra::LegacyPlugin
  class CompatibleModeRegistry
    attr_accessor :legacy_plugins

    # _paths_ :: Directory paths which contain legacy plugins.
    # _pipeline_ :: Runtime pipline.
    def initialize paths, pipeline
      self.legacy_plugins = {}

      paths.each do |folder|
        folder = Pathname.new(folder)
        Pathname.glob(File.join(folder, "**/*.rb")).sort.each do |file|
          module_name = file.relative_path_from(folder).to_s.gsub("/","::")[0..-4]
          begin
            legacy_plugins[ module_name ] = Yapra::LegacyPlugin::Base.new(pipeline, file)
            logger.debug "#{module_name} is loaded from #{file}"
          rescue LoadError => ex
            logger.warn "#{module_name} can't load, because: #{ex.message}"
          end
        end
      end
    end

    def logger
      Yapra::Runtime.logger
    end

    # load plugin from module name.
    #
    # example:
    #
    #     registry = Yapra::LegacyPlugin::CompatibleModeRegistry.new(paths, pipeline)
    #     feed_load_plugin = registry.get('Feed::load')
    #
    def get module_name
      plugin = legacy_plugins[module_name]
      raise "#{module_name} is not registered." unless plugin
      plugin
    end
  end
end