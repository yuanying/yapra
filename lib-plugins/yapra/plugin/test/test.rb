require 'yapra/plugin'

module Yapra::Plugin::Test
  class Test
    def run(data)
      puts 'test!!'
      data
    end
    
    def on_error(ex)
      puts 'on error!!'
    end
  end
end