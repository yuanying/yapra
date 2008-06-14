require 'yapra'
require 'yapra/inflector'
require 'yapra/legacy_plugin/base'

class Yapra::Pipeline
  attr_reader :yapra, :context
  attr_accessor :legacy_plugin_registry
  
  UPPER_CASE = /[A-Z]/
  
  def initialize yapra, pipeline_name
    @yapra              = yapra
    @context            = { 'pipeline_name' => pipeline_name }
    
    @module_name_prefix = construct_module_name_prefix yapra.env
  end
  
  def logger
    @yapra.logger
  end
  
  def run pipeline_command, data=[]
    pipeline_command.inject(data) do |data, command|
      execute_plugin(command, data.clone)
    end
  end
  
  def execute_plugin command, data
    self.logger.info("exec plugin #{command["module"]}")
    if class_based_plugin?(command['module'])
      run_class_based_plugin command, data
    else
      run_legacy_plugin command, data
    end
  end
  
  protected
  def class_based_plugin? command_name
    UPPER_CASE =~ command_name.split('::').last[0, 1]
  end
  
  def run_legacy_plugin command, data
    self.logger.debug("evaluate plugin as legacy")
    legacy_plugin_registry.get(command['module']).run(command['config'], data)
  end
  
  def run_class_based_plugin command, data
    self.logger.debug("evaluate plugin as class based")
    plugin_class = nil
    @module_name_prefix.each do |prefix|
      yapra_module_name = "#{prefix}#{command['module']}"
      plugin_class      = Yapra.load_class_constant(yapra_module_name)
      break if plugin_class
    end
    raise LoadError unless plugin_class
    plugin                = plugin_class.new
    plugin.yapra          = yapra if plugin.respond_to?('yapra=')
    plugin.pipeline       = self  if plugin.respond_to?('pipeline=')
    plugin.plugin_config  = command['config'] if plugin.respond_to?('plugin_config=')
    plugin.run(data)
  end
  
  def construct_module_name_prefix env
    module_name_prefix = [ 'Yapra::Plugin::', '' ]
    if env['module_name_prefix']
      if env['module_name_prefix'].kind_of?(Array)
        module_name_prefix = env['module_name_prefix']
      else
        module_name_prefix = [ env['module_name_prefix'] ]
      end
    end
    module_name_prefix
  end
end
