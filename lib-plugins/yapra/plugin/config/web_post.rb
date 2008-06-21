require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Config
  # Config::WebPost -- Yuanying
  # 
  #     post to web page with WWW::Mechanize agent.
  # 
  #     - module: Config::WebPost
  #       config:
  #         url: http://www.pixiv.net/index.php
  #         params:
  #           pixiv_id: yuanying
  #           pass: password-dayo
  #
  class WebPost < Yapra::Plugin::MechanizeBase
    def run(data)
      agent.post(config['url'], config['params'])
      data
    end
  end
end