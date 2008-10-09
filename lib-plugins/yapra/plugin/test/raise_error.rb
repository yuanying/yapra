require 'yapra/plugin/base'

module Yapra::Plugin::Test
  class RaiseError < Yapra::Plugin::Base
    def run(data)
      message = config['message'] || 'Error.'
      raise message
    end
  end
end