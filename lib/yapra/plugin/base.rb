require 'yapra/plugin'
require 'yapra/plugin/context_aware'
require 'yapra/plugin/erb_applier'
require 'yapra/plugin/feed_item_operator'

# Yapra plugin base class.
# 
# Subclass this base is not required to be Yapra plugin.
# But a few utility module is added in this base.
class Yapra::Plugin::Base
  include Yapra::Plugin::ContextAware
  include Yapra::Plugin::FeedItemOperator
  include Yapra::Plugin::ErbApplier
  
  def logger
    Yapra::Runtime.logger
  end
end