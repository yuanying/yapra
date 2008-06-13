require 'mechanize'
require 'yapra/plugin/base'

class Yapra::Plugin::MechanizeBase < Yapra::Plugin::Base
  def agent
    pipeline_context['mechanize_agent'] ||= WWW::Mechanize.new
    pipeline_context['mechanize_agent']
  end
end