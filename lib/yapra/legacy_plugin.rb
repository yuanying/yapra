# require 'pathname'
require 'yapra/inflector'

class Yapra::LegacyPlugin
  attr_reader :source
  attr_reader :run_method
  attr_reader :yapra
  
  def initialize(yapra, module_name)
    plugin_path   = nil
    @yapra        = yapra
    @run_method   = module_name.sub(/.*::/,"")
    $:.each do |load_path|
      path = File.join(load_path, "#{module_name.gsub('::', File::SEPARATOR)}.rb")
      if File.file?(path)
        plugin_path = path
        break
      end
    end
    if plugin_path
      instance_eval( @source = File.read(plugin_path).toutf8, plugin_path, 1)
    else
      raise LoadError
    end
  end
  
  def eval_pragger(command_array, data)
    yapra.execute_plugins(command_array, data)
  end
  
  def run(config, data)
    self.__send__(run_method, config, data)
  end
end
