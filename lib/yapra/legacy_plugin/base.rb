# require 'pathname'
require 'yapra/legacy_plugin'

class Yapra::LegacyPlugin::Base
  attr_reader :source
  attr_reader :_yapra_run_method
  attr_reader :_yapra_pipeline
  
  def initialize(pipeline, plugin_path)
    @_yapra_pipeline     = pipeline
    @_yapra_run_method  = File.basename(plugin_path, '.*')
    instance_eval( @source = File.read(plugin_path).toutf8, plugin_path, 1)
  end
  
  def logger
    Yapra::Runtime.logger
  end
  
  def eval_pragger(command_array, data)
    pipeline.execute_plugins(command_array, data)
  end
  
  def _yapra_run_as_legacy_plugin(config, data)
    self.__send__(self._yapra_run_method, config, data)
  end
end
