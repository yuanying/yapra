## Config::MechanizeBasicAuth -- Yuanying
##
## post to web page with WWW::Mechanize agent.
## 
## - module: Config::MechanizeBasicAuth
##   config:
##     user: yuanying
##     password: password-dayo
##
require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Config
  class MechanizeBasicAuth < Yapra::Plugin::MechanizeBase
    def run(data)
      agent.basic_auth(config['user'], config['password'])
      data
    end
  end
end