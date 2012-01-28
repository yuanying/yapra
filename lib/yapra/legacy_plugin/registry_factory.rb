require 'yapra/legacy_plugin'
require 'yapra/inflector'

# RegistryFactory is factory class for LegacyPluginRegistry.
#
# LegacyPluginRegistry is created by mode.
#
# If mode is compatible, this factory create a CompatibeModeRegistry.
class Yapra::LegacyPlugin::RegistryFactory
  attr_reader :plugin_paths
  attr_reader :registry_class

  # plugin_paths :: directory paths which are contains legacy plugins.
  # mode :: 'compatible' / 'advance'
  def initialize plugin_paths, mode = 'compatible'
    registry_name = "Yapra::LegacyPlugin::#{Yapra::Inflector.camelize(mode)}ModeRegistry"
    @registry_class = Yapra.load_class_constant(registry_name)
    raise "'#{mode}' mode is not supported." unless @registry_class

    @plugin_paths = plugin_paths
  end

  def create pipeline
    registry = registry_class.new(plugin_paths, pipeline)
    pipeline.legacy_plugin_registry = registry
    registry
  end
end