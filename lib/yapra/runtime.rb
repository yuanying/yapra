require 'logger'
require 'yapra'
require 'yapra/pipeline'
require 'yapra/config'
require 'yapra/inflector'

class Yapra::Runtime
  attr_reader :logger
  attr_reader :config
  attr_reader :legacy_plugin_registory_factory
  
  def initialize config, legacy_plugin_registory_factory=nil
    @config = Yapra::Config.new(config)
    @logger = create_logger @config.env
    @legacy_plugin_registory_factory        = legacy_plugin_registory_factory
    @legacy_plugin_registory_factory.logger = @logger if @legacy_plugin_registory_factory
  end
  
  def execute
    self.config.pipeline_commands.each_key do |k|
      execute_pipeline k, []
    end
  end
  
  def execute_pipeline pipeline_name, data=[]
    self.logger.info("# pipeline '#{pipeline_name}' is started...")
    command_array = self.config.pipeline_commands[pipeline_name]
    legacy_plugin_registory = legacy_plugin_registory_factory.create if legacy_plugin_registory_factory
    
    pipeline = Yapra::Pipeline.new(self, pipeline_name)
    pipeline.legacy_plugin_registry = legacy_plugin_registory
    pipeline.run(command_array, data)
  end
  
  def env
    @config.env
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
    end
    logger
  end
end