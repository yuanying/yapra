require 'yapra'
require 'yapra/runtime'
require 'yapra/inflector'
require 'yapra/legacy_plugin/base'

class Yapra::Pipeline
  attr_reader :yapra, :context
  attr_writer :logger
  attr_accessor :legacy_plugin_registry
  
  UPPER_CASE = /[A-Z]/
  
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
  
  # start pipeline from commands.
  # 
  # example:
  # 
  #     pipeline.run([
  #       {
  #         'module' => 'Config::agent',
  #         'config' => {
  #           'user_agent_alias' => 'Windows IE 6'
  #         }
  #       },
  #       {
  #         'module' => 'RSS::load',
  #         'config' => {
  #           'uri' => 'http://www.example.com/hoge.rdf'
  #         }
  #       },
  #       {
  #         'module' => 'print'
  #       }
  #     ])
  def run pipeline_command, data=[]
    @plugins = []
    begin
      pipeline_command.inject(data) do |data, command|
        execute_plugin(command, data.clone)
      end
    rescue => ex
      @plugins.each do |plugin|
        begin
          plugin.on_error(ex) if plugin.respond_to?('on_error')
        rescue => exx
          self.logger.error("error is occured when error handling: #{exx.message}")
        end
      end
      raise ex
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
    data = legacy_plugin_registry.get(command['module'])._yapra_run_as_legacy_plugin(command['config'], data)
    return data
  end
  
  def run_class_based_plugin command, data
    self.logger.debug("evaluate plugin as class based")
    load_error_stack = []
    plugin_class = nil
    @module_name_prefix.each do |prefix|
      yapra_module_name = "#{prefix}#{command['module']}"
      begin
        plugin_class      = Yapra.load_class_constant(yapra_module_name)
        break if plugin_class
      rescue LoadError, NameError => ex
        load_error_stack << ex
      end
    end
    raise_load_error(load_error_stack, command) unless plugin_class
    
    plugin = initialize_plugin(plugin_class, command)
    @plugins << plugin
    data = plugin.run(data)
    return data
  end
  
  def raise_load_error load_error_stack, command
    load_error = LoadError.new("#{command['module']} module is not found.")
    backtrace = load_error.backtrace || []
    load_error_stack.each do |e|
      backtrace << "#{e.class.name} in '#{e.message}'"
      backtrace = backtrace + e.backtrace
    end
    load_error.set_backtrace(backtrace)
    raise load_error
  end
  
  def initialize_plugin plugin_class, command
    plugin                = plugin_class.new
    plugin.yapra          = yapra if plugin.respond_to?('yapra=')
    plugin.pipeline       = self  if plugin.respond_to?('pipeline=')
    plugin.plugin_config  = command['config'] if plugin.respond_to?('plugin_config=')
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
