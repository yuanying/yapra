## Config::MechanizePost -- Yuanying
##
## post to web page with WWW::Mechanize agent.
## 
## - module: Config::MechanizePost
##   config:
##     url: http://www.pixiv.net/index.php
##     params:
##       pixiv_id: yuanying
##       pass: password-dayo
##
require 'mechanize'
require 'yapra/plugin/base'

module Yapra::Plugin::Config
  class MechanizePost < Yapra::Plugin::Base
    def run(data)
      agent = config['mechanize_agent']
      unless agent
        logger.info('Config::MechanizeAgent is not loaded.')
        agent = WWW::Mechanize.new
      end
      agent.post(config['url'], config['params'])
      data
    end
  end
end