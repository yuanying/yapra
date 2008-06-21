require 'pathname'
require 'yapra/legacy_plugin'

module Yapra::LegacyPlugin
  class CompatibleModeRegistry
    attr_accessor :legacy_plugins
      
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
    
    def get module_name
      plugin = legacy_plugins[module_name]
      raise "#{module_name} is not registered." unless plugin
      plugin
    end
  end
end