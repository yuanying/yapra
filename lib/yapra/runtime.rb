require 'yapra'
require 'yapra/pipeline'
require 'yapra/config'
require 'yapra/inflector'

class Yapra::Runtime
  attr_reader :env
  attr_reader :legacy_plugin_registry_factory
  
  def initialize env={}, legacy_plugin_registry_factory=nil
    @env    = env
    
    @legacy_plugin_registry_factory        = legacy_plugin_registry_factory
  end
  
  def execute pipeline_commands
    pipeline_commands.each do |k, v|
      execute_pipeline k, v, []
    end
  end
  
  def execute_pipeline pipeline_name, command_array, data=[]
    self.class.logger.info("# pipeline '#{pipeline_name}' is started...")
    pipeline = Yapra::Pipeline.new(self, pipeline_name)
    legacy_plugin_registory = legacy_plugin_registry_factory.create(pipeline) if legacy_plugin_registry_factory
    pipeline.run(command_array, data)
  end
  
  def self.logger
    @@logger
  end
  
  def self.logger=logger
    @@logger = logger
  end
end