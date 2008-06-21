require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Config
  # Yapra::Config::Agent -- Yuanying
  # 
  # add WWW::Mechanize agent to context.
  # 
  #     - module: Config::Agent
  #       config:
  #         user_agent_alias: Windows IE 6
  #         proxy:
  #           addr: localhost
  #           port: 8080
  #           user: username
  #           password: password
  #
  class Agent < Yapra::Plugin::MechanizeBase

    def run(data)
      
      agent.user_agent_alias = config['user_agent_alias'] || 'Windows IE 6'
      if config['proxy']
        agent.set_proxy(
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