require 'yapra'
require 'yapra/inflector'
require 'yapra/legacy_plugin/base'

class Yapra::PipelineBase
  attr_reader :yapra, :context
  attr_writer :logger
  
  def initialize pipeline_name, yapra=Yapra::Runtime.new
    @logger             = nil
    @yapra              = yapra
    @context            = { 'pipeline_name' => pipeline_name }
    
    @module_name_prefix = construct_module_name_prefix yapra.env
  end
  
  def name
    self.context[ 'pipeline_name' ]
  end
  
  def logger
    return @logger || Yapra::Runtime.logger
  end
  
  def load command
    plugin_name = command['module']
    load_error_stack = []
    plugin_class = nil
    @module_name_prefix.each do |prefix|
      yapra_module_name = "#{prefix}#{plugin_name}"
      begin
        plugin_class      = Yapra.load_class_constant(yapra_module_name)
        break if plugin_class
      rescue LoadError, NameError => ex
        load_error_stack << ex
      end
    end
    raise_load_error(load_error_stack, command) unless plugin_class
    
    plugin = initialize_plugin( plugin_class )
    
    plugin
  end
  
  protected
  def initialize_plugin plugin_class
    plugin                = plugin_class.new
    plugin.yapra          = yapra if plugin.respond_to?('yapra=')
    plugin.pipeline       = self  if plugin.respond_to?('pipeline=')
    
    plugin
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
