require 'yapra/plugin/base'

module Yapra::Plugin::Filter
  # = Filter::ApplyTemplate -- Yuanying
  # 
  # apply template and set to attribute.
  #
  # example:
  # 
  #     - module: Filter::ApplyTemplate
  #       config:
  #         content_encoded: '<div><%= title %></div>'
  #
  class ApplyTemplate < Yapra::Plugin::Base
    def run(data)
      regexp = nil
      if config['regexp']
        regexp = Regexp.new(config['regexp'])
      else
        regexp = /^(https?|ftp)(:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+)$/
      end
      
      data.map! do |item|
        url = item
        if item.respond_to?('link')
          url = item.link
        end

        if regexp =~ url
          unless(item.instance_of?(RSS::RDF::Item))
            new_item = RSS::RDF::Item.new
            new_item.title = item.title rescue item.to_s
            new_item.date = item.date rescue Time.now
            new_item.description = item.description rescue item.to_s
            new_item.link = item.link rescue '#'
            item = new_item
          end
          
          if plugin_config
            plugin_config.each do |k, template|
              value = apply_template template, binding
              set_attribute_to item, k, value
            end
          end
        end
        item
      end
      
      data
    end
  end
end
