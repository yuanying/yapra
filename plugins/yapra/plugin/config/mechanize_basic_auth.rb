## Config::MechanizeBasicAuth -- Yuanying
##
## post to web page with WWW::Mechanize agent.
## 
## - module: Config::MechanizeBasicAuth
##   config:
##     user: yuanying
##     password: password-dayo
##
require 'yapra/plugin/base'

module Yapra::Plugin::Config
  class MechanizeBasicAuth < Yapra::Plugin::Base
    def run(data)
      agent = config['mechanize_agent']
      if agent
        agent.basic_auth(config['user'], config['password'])
      else
        logger.warn('Config::MechanizeAgent is not loaded.')
      end
      data
    end
  end
end