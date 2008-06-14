require 'pathname'
require 'yapra/legacy_plugin'

module Yapra::LegacyPlugin
  class CompatibleModeRegistry
    attr_accessor :legacy_plugins
    attr_accessor :logger
      
    def initialize paths, logger
      self.logger = logger
      self.legacy_plugins = {}
      
      paths.each do |folder|
        Pathname.glob(folder + "**/*.rb").sort.each do |file|
          module_name = file.relative_path_from(folder).to_s.gsub("/","::")[0..-4]
          begin
            legacy_plugins[ module_name ] = Yapra::LegacyPlugin::Base.new(self, file)
          rescue LoadError => ex
            logger.warn "#{module_name} can't load, because: #{ex.message}"
          end
        end
      end
    end
    
    def get module_name
      legacy_plugins[module_name]
    end
  end
end