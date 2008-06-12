require 'yapra/plugin'

module Yapra::Plugin::ContextAware
  attr_accessor :yapra, :pipeline_context, :plugin_config
  
  def config
    unless @config
      @config = {}.update(yapra.env).update(pipeline_context)
      @config.update(plugin_config) unless plugin_config
    end
    @config
  end
end