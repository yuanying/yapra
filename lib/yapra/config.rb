# = Config Examples
# 
# == Format 1: Pragger like.
# A simplest. You can run one pipeline without global config.
#
#    - module: Module:name
#      config:
#        a: 3
#    - module: Module:name2
#      config:
#        a: b
#    - module: Module:name3
#      config:
#        a: 88
#
# == Format 2: Python habu like.
# You can run a lot of pipelines with global config.
#
#   global:
#     log:
#       out: stderr
#       level: warn
#
#   pipeline:
#     pipeline1:
#       - module: Module:name
#         config:
#           a: 3
#       - module: Module:name2
#         config:
#           a: b
#
#     pipeline2:
#       - module: Module:name
#         config:
#           a: 3
#       - module: Module:name2
#         config:
#           a: b
#
# == Format 3: Mixed type.
# You can run sigle pipeline with global config.
#
#   global:
#     log:
#       out: stderr
#       level: warn
#
#   pipeline:
#     - module: Module:name
#       config:
#         a: 3
#     - module: Module:name2
#       config:
#         a: b
#
require 'yapra'

class Yapra::Config
  attr_reader :env
  attr_reader :pipeline_commands
  
  def initialize config={}
    if config.kind_of?(Hash)
      @env = config['global'] || {}
      if config['pipeline']
        if config['pipeline'].kind_of?(Hash)
          @pipeline_commands = config['pipeline']
        elsif config['pipeline'].kind_of?(Array)
          @pipeline_commands = { 'default' => config['pipeline'] }
        end
      end
      raise 'config["global"]["pipeline"] is invalid!' unless @pipeline_commands
    elsif config.kind_of?(Array)
      @env        = {}
      @pipeline_commands  = { 'default' => config }
    else
      raise 'config file is invalid!'
    end
  end
  
end