require 'logger'
require 'yapra'
require 'yapra/pipeline'
require 'yapra/config'
require 'yapra/inflector'

class Yapra::Runtime
  attr_reader :logger
  attr_reader :env
  attr_reader :legacy_plugin_registry_factory
  
  def initialize env={}, legacy_plugin_registry_factory=nil
    @env    = env
    @logger = create_logger env
    
    @legacy_plugin_registry_factory        = legacy_plugin_registry_factory
    @legacy_plugin_registry_factory.logger = @logger if @legacy_plugin_registry_factory
  end
  
  def execute pipeline_commands
    pipeline_commands.each do |k, v|
      execute_pipeline k, v, []
    end
  end
  
  def execute_pipeline pipeline_name, command_array, data=[]
    self.logger.info("# pipeline '#{pipeline_name}' is started...")
    pipeline = Yapra::Pipeline.new(self, pipeline_name)
    legacy_plugin_registory = legacy_plugin_registry_factory.create(pipeline) if legacy_plugin_registry_factory
    pipeline.run(command_array, data)
  end
  
  protected
  def create_logger env
    logger = nil
    if env['log'] && env['log']['out']
      if env['log']['out'].index('file://')
        logger = Logger.new(URI.parse(env['log']['out']).path)
      else
        logger = Logger.new(Yapra::Inflector.constantize(env['log']['out'].upcase))
      end
    else
      logger = Logger.new(STDOUT)
    end
    
    if env['log'] && env['log']['level']
      logger.level = Yapra::Inflector.constantize("Logger::#{env['log']['level'].upcase}")
    else
      logger.level = Logger::WARN
    end
    logger
  end
end