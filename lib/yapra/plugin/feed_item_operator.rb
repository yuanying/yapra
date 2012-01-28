require 'yapra/plugin'

module Yapra::Plugin::FeedItemOperator
  LOCAL_VAL_RE = /[a-z_][0-9A-Za-z_]/

  def set_attribute_to item, k, value
    raise NameError unless LOCAL_VAL_RE =~ k
    unless item.respond_to?("#{k}=")
      item.instance_eval %Q{
        def #{k}
          @#{k}
        end
        def #{k}= v
          @#{k} = v
        end
      }, __FILE__, __LINE__

    end
    item.__send__("#{k}=", value)
  end
end