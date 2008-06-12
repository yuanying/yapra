require 'logger'
require 'yapra'
require 'yapra/inflector'

class Yapra::Base
  UPPER_CASE = /[A-Z]/
  
  attr_accessor :logger
  attr_reader :env
  attr_reader :pipeline
  
  def initialize global_config
    
    if global_config.kind_of?(Hash)
      @env      = global_config['global'] || {}
      @pipeline = global_config['pipeline'] || []
    elsif global_config.kind_of?(Array)
      @env      = {}
      @pipeline = global_config
    else
      raise 'config file is invalid!'
    end
    
    create_logger
  end
  
  def execute data=[]
    execute_plugins pipeline, data
  end
  
  def execute_plugins command_array, data=[]
    command_array.inject(data) do |data, command|
      self.logger.info("exec plugin #{command["module"]}")
      execute_plugin(command, data.clone)
    end
  end
  
  def execute_plugin command, data=[]
    if class_based_plugin?(command['module'])
      run_class_based_plugin command, data
    else
      run_legacy_plugin command, data
    end
  end
  
  protected
  def class_based_plugin? command_name
    UPPER_CASE =~ command_name.split('::').first[0, 1]
  end
  
  def run_class_based_plugin command, data
    require Inflector.underscore(command['module'])
    plugin              = eval("#{command['module']}.new", TOPLEVEL_BINDING, __FILE__, 13)
    plugin.yapra        = self if plugin.respond_to?('yapra=')
    plugin.execute(command, data)
  end
  
  def run_legacy_plugin command, data
    LegacyPlugin.new(yapra, command['module']).run(command['config'], data)
  end
  
  def create_logger
    if env['log'] && env['log']['out']
      if env['log']['out'].index('file://') > 0
        self.logger = Logger.new(URI.parse(env['log']['out']).path)
      else
        self.logger = Logger.new(eval(env['log']['out'].upcase))
      end
    else
      self.logger = Logger.new(STDOUT)
    end
    
    if env['log'] && env['log']['level']
      self.logger.level = eval("Logger::#{config['level'].upcase}")
    end
  end
end
