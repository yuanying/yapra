require 'yapra'
require 'yapra/pipeline_base'
require 'yapra/runtime'
require 'yapra/inflector'
require 'yapra/legacy_plugin/base'

class Yapra::Pipeline < Yapra::PipelineBase
  attr_accessor :legacy_plugin_registry

  UPPER_CASE = /[A-Z]/

  # start pipeline from commands.
  #
  # example:
  #
  #     pipeline.run([
  #       {
  #         'module' => 'Config::agent',
  #         'config' => {
  #           'user_agent_alias' => 'Windows IE 6'
  #         }
  #       },
  #       {
  #         'module' => 'RSS::load',
  #         'config' => {
  #           'uri' => 'http://www.example.com/hoge.rdf'
  #         }
  #       },
  #       {
  #         'module' => 'print'
  #       }
  #     ])
  def run pipeline_command, data=[]
    @plugins = []
    begin
      pipeline_command.inject(data) do |data, command|
        execute_plugin(command, data.clone)
      end
    rescue => ex
      @plugins.each do |plugin|
        begin
          plugin.on_error(ex) if plugin.respond_to?('on_error')
        rescue => exx
          self.logger.error("error is occured when error handling: #{exx.message}")
        end
      end
      raise ex
    end
  end

  def execute_plugin command, data
    self.logger.info("exec plugin #{command["module"]}")
    if class_based_plugin?(command['module'])
      run_class_based_plugin command, data
    else
      run_legacy_plugin command, data
    end
  end

  protected
  def class_based_plugin? command_name
    UPPER_CASE =~ command_name.split('::').last[0, 1]
  end

  def run_legacy_plugin command, data
    self.logger.debug("evaluate plugin as legacy")
    data = legacy_plugin_registry.get(command['module'])._yapra_run_as_legacy_plugin(command['config'], data)
    return data
  end

  def run_class_based_plugin command, data
    self.logger.debug("evaluate plugin as class based")
    plugin = load(command['module'])

    # yml pipeline specific.
    plugin.plugin_config  = command['config'] if plugin.respond_to?('plugin_config=')

    @plugins << plugin
    data = plugin.run(data)
    return data
  end

  def raise_load_error load_error_stack, command
    load_error = LoadError.new("#{command['module']} module is not found.")
    backtrace = load_error.backtrace || []
    load_error_stack.each do |e|
      backtrace << "#{e.class.name} in '#{e.message}'"
      backtrace = backtrace + e.backtrace
    end
    load_error.set_backtrace(backtrace)
    raise load_error
  end
end
