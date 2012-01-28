require 'yapra/plugin/base'

module Yapra::Plugin::Test
  # module: Test::AppendEntry -- Yuanying
  #
  # append entry to data array.
  #
  # example:
  #
  #     - module: Test::AppendEntry
  #       config:
  #         title: 'title'
  #         description: 'description.'

  class AppendEntry < Yapra::Plugin::Base
    def run(data)
      item = RSS::RDF::Item.new
      plugin_config.each do |k, v|
        set_attribute_to item, k, v
      end
      data << item
      data
    end
  end
end