# require 'pathname'
require 'yapra/legacy_plugin'

class Yapra::LegacyPlugin::Base
  attr_reader :source
  attr_reader :run_method
  attr_reader :pipeline
  
  def initialize(pipeline, plugin_path)
    @pipeline     = pipeline
    @run_method   = File.basename(plugin_path, '.*')
    instance_eval( @source = File.read(plugin_path).toutf8, plugin_path, 1)
  end
  
  def eval_pragger(command_array, data)
    pipeline.execute_plugins(command_array, data)
  end
  
  def run(config, data)
    self.__send__(run_method, config, data)
  end
end
