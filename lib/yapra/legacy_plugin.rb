# require 'pathname'
require 'yapra/inflector'

class Yapra::LegacyPlugin
  attr_reader :source
  attr_reader :run_method
  attr_reader :yapra
  
  def initialize(yapra, plugin_path)
    @yapra        = yapra
    @run_method   = File.basename(plugin_path, '.*')
    instance_eval( @source = File.read(plugin_path).toutf8, plugin_path, 1)
  end
  
  def eval_pragger(command_array, data)
    yapra.execute_plugins(command_array, data)
  end
  
  def run(config, data)
    self.__send__(run_method, config, data)
  end
end
