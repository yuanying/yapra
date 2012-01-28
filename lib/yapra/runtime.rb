require 'logger'
require 'yapra'
require 'yapra/pipeline'
require 'yapra/config'
require 'yapra/inflector'

# = How to use
#
#     require 'yapra/runtime'
#     require 'yapra/config'
#
#     config = YAML.load(config_file)
#     config = Yapra::Config.new(config)
#
#     Yapra::Runtime.logger = Logger.new(STDOUT)
#
#     yapra = Yapra::Runtime.new(config.env)
#     yapra.execute(config.pipeline_commands)
#
# config_file format written in Yapra::Config document.
class Yapra::Runtime
  attr_reader :env
  attr_reader :legacy_plugin_registry_factory
  attr_reader :current_pipeline

  @@logger = Logger.new(STDOUT)

  def initialize env={}, legacy_plugin_registry_factory=nil
    @env    = env

    @legacy_plugin_registry_factory        = legacy_plugin_registry_factory
  end

  # execute pipelines from commands.
  def execute pipeline_commands
    pipeline_commands.each do |k, v|
      execute_pipeline k, v, []
    end
  end

  # execute one pipeline.
  def execute_pipeline pipeline_name, command_array, data=[]
    self.class.logger.info("# pipeline '#{pipeline_name}' is started...")
    pipeline = Yapra::Pipeline.new(pipeline_name, self)
    @current_pipeline = pipeline
    legacy_plugin_registory = legacy_plugin_registry_factory.create(pipeline) if legacy_plugin_registry_factory
    pipeline.run(command_array, data)
    @current_pipeline = nil
  end

  def self.logger
    @@logger
  end

  def self.logger=logger
    @@logger = logger
  end
end