## Yapra::Config::MechanizeAgent -- Yuanying
##
## add WWW::Mechanize agent to context.
## 
## - module: Yapra::Config::MechanizeAgent
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

module Yapra::Config
  class MechanizeAgent < Yapra::Plugin::Base
    Name = 'mechanize_agent'
    
    def run(data)
      config[Name] ||= WWW::Mechanize.new
      mechanize_agent = config[Name]
      
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