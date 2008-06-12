require 'yapra/plugin'
require 'yapra/plugin/context_aware'
require 'yapra/plugin/erb_applier'
require 'yapra/plugin/feed_item_operator'

class Yapra::Plugin::Base
  include Yapra::Plugin::ContextAware
  include Yapra::Plugin::FeedItemOperator
  include Yapra::Plugin::ErbApplier
  
end