require 'yapra/plugin'

module Yapra::Plugin::FeedItemOperator
  def set_attribute_to item, k, value
    if item.respond_to?("#{k}=")
      item.__send__("#{k}=", value)
    else
      item.instance_eval %Q{
        @#{k} = "#{value}"
        def #{k}
          @#{k}
        end
      }, __FILE__, __LINE__
    end
  end
end