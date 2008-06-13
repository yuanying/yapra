# Base class of Yet Another Pragger implementation.
#
# This is initialized with hashed config string, and run pipeline.
#
# == Usage
#
#    Yapra::Base.new(config).execute()
#
# == Config Examples
# 
# === Format 1: Pragger like.
# A simplest. You can run one pipeline without global config.
#
#    - module: Module:name
#      config:
#        a: 3
#    - module: Module:name2
#      config:
#        a: b
#    - module: Module:name3
#      config:
#        a: 88
#
# === Format 2: Python habu like.
# You can run a lot of pipelines with global config.
#
#   global:
#     log:
#       out: stderr
#       level: warn
#
#   pipeline:
#     pipeline1:
#       - module: Module:name
#         config:
#           a: 3
#       - module: Module:name2
#         config:
#           a: b
#
#     pipeline2:
#       - module: Module:name
#         config:
#           a: 3
#       - module: Module:name2
#         config:
#           a: b
#
# === Format 3: Mixed type.
# You can run sigle pipeline with global config.
#
#   global:
#     log:
#       out: stderr
#       level: warn
#
#   pipeline:
#     - module: Module:name
#       config:
#         a: 3
#     - module: Module:name2
#       config:
#         a: b
#
require 'logger'
require 'pathname'
require 'yapra'
require 'yapra/inflector'
require 'yapra/legacy_plugin'

class Yapra::Base
  UPPER_CASE = /[A-Z]/
  
  attr_accessor :legacy_plugins
  attr_accessor :logger
  attr_reader :env
  attr_reader :pipelines
  
  def initialize global_config, legacy_plugin_directory_paths
    if global_config.kind_of?(Hash)
      @env = global_config['global'] || {}
      if global_config['pipeline']
        if global_config['pipeline'].kind_of?(Hash)
          @pipelines = global_config['pipeline']
        elsif global_config['pipeline'].kind_of?(Array)
          @pipelines = { 'default' => global_config['pipeline'] }
        end
      end
      raise 'config["global"]["pipeline"] is invalid!' unless @pipelines
    elsif global_config.kind_of?(Array)
      @env        = {}
      @pipelines  = { 'default' => global_config }
    else
      raise 'config file is invalid!'
    end
    
    create_logger
    load_legacy_plugins(legacy_plugin_directory_paths)
  end
  
  def execute
    self.pipelines.each_key do |k|
      execute_pipeline k, []
    end
  end
  
  def execute_pipeline pipeline_name, data=[]
    self.logger.info("# pipeline '#{pipeline_name}' is started...")
    command_array = self.pipelines[pipeline_name]
    pipeline_context = { 'pipeline_name' => pipeline_name }
    command_array.inject(data) do |data, command|
      execute_plugin(pipeline_context, command, data.clone)
    end
  end
  
  def execute_plugin pipeline_context, command, data=[]
    self.logger.info("exec plugin #{command["module"]}")
    if class_based_plugin?(command['module'])
      run_class_based_plugin pipeline_context, command, data
    else
      run_legacy_plugin command, data
    end
  end
  
  protected
  def class_based_plugin? command_name
    UPPER_CASE =~ command_name.split('::').last[0, 1]
  end
  
  def run_class_based_plugin pipeline_context, command, data
    self.logger.debug("evaluate plugin as class based")
    yapra_module_name       = "Yapra::Plugin::#{command['module']}"
    plugin_class            = load_class_constant(yapra_module_name)
    plugin_class            = load_class_constant(command['module']) unless plugin_class
    raise LoadError unless plugin_class
    plugin                  = plugin_class.new
    plugin.yapra            = self if plugin.respond_to?('yapra=')
    plugin.pipeline_context = pipeline_context if plugin.respond_to?('pipeline_context=')
    plugin.plugin_config    = command['config'] if plugin.respond_to?('plugin_config=')
    plugin.run(data)
  end
  
  def run_legacy_plugin command, data
    self.logger.debug("evaluate plugin as legacy")
    legacy_plugins[command['module']].run(command['config'], data)
  end
  
  def load_class_constant module_name
    require Yapra::Inflector.underscore(module_name)
    Yapra::Inflector.constantize(module_name)
  rescue LoadError
    nil
  rescue NameError
    nil
  end
  
  def load_legacy_plugins paths
    self.legacy_plugins = {}
    paths.each do |folder|
      Pathname.glob(folder + "**/*.rb").sort.each do |file|
        module_name = file.relative_path_from(folder).to_s.gsub("/","::")[0..-4]
        begin
          legacy_plugins[ module_name ] = Yapra::LegacyPlugin.new(self, file)
        rescue LoadError => ex
          logger.warn "#{module_name} can't load, because: #{ex.message}"
        end
      end
    end
  end
  
  def create_logger
    if env['log'] && env['log']['out']
      if env['log']['out'].index('file://')
        self.logger = Logger.new(URI.parse(env['log']['out']).path)
      else
        self.logger = Logger.new(Yapra::Inflector.constantize(env['log']['out'].upcase))
      end
    else
      self.logger = Logger.new(STDOUT)
    end
    
    if env['log'] && env['log']['level']
      self.logger.level = Yapra::Inflector.constantize("Logger::#{env['log']['level'].upcase}")
    end
  end
end
