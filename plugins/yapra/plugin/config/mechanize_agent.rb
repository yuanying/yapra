## Yapra::Config::MechanizeAgent -- Yuanying
##
## add WWW::Mechanize agent to context.
## 
## - module: Config::MechanizeAgent
##   config:
##     user_agent_alias: Windows IE 6
##     proxy:
##       addr: localhost
##       port: 8080
##       user: username
##       password: password
##
require 'mechanize'
require 'yapra/plugin/base'

module Yapra::Plugin::Config
  class MechanizeAgent < Yapra::Plugin::Base

    def run(data)
      pipeline_context['mechanize_agent'] ||= WWW::Mechanize.new
      mechanize_agent = pipeline_context['mechanize_agent']
      
      mechanize_agent.user_agent_alias = config['user_agent_alias'] || 'Windows IE 6'
      if config['proxy']
        mechanize_agent.set_proxy(
          config['proxy']['addr'],
          config['proxy']['port'],
          config['proxy']['user'],
          config['proxy']['password']
        )
      end
      
      return data
    end
  end
end