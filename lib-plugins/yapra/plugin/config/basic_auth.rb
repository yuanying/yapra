require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Config
  # Config::BasicAuth -- Yuanying
  # 
  # post to web page with WWW::Mechanize agent.
  # 
  #     - module: Config::BasicAuth
  #       config:
  #         user: yuanying
  #         password: password-dayo
  
  class BasicAuth < Yapra::Plugin::MechanizeBase
    def run(data)
      agent.basic_auth(config['user'], config['password'])
      data
    end
  end
end