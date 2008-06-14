require 'yapra/legacy_plugin'
require 'yapra/inflector'

class Yapra::LegacyPlugin::RegistoryFactory
  attr_accessor :logger
  attr_reader :plugin_paths
  attr_reader :registry_class
  
  def initialize plugin_paths, mode = 'compatible'
    registry_name = "Yapra::LegacyPlugin::#{Yapra::Inflector.camelize(mode)}ModeRegistry"
    @registry_class = Yapra.load_class_constant(registry_name)
    raise "'#{mode}' mode is not supported." unless @registry_class
    
    @plugin_paths = plugin_paths
  end
  
  def create
    registry_class.new(plugin_paths, logger)
  end
end