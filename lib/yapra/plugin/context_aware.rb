require 'yapra/plugin'

module Yapra::Plugin::ContextAware
  attr_accessor :yapra, :pipeline, :plugin_config
  
  def config
    @config ||= nil
    unless @config
      @config = {}.update(yapra.env).update(pipeline.context)
      @config.update(plugin_config) if plugin_config
    end
    @config
  end
end