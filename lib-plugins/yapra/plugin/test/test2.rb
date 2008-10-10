require 'yapra/plugin/base'

module Yapra::Plugin::Test
  class Test2 < Yapra::Plugin::Base
    def run(data)
      logger.debug 'test2!!'
      data
    end
    
    def on_error(ex)
      logger.debug 'on error2!!'
    end
  end
end