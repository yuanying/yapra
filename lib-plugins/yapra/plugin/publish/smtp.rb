require 'net/smtp'
require 'yapra/version'
require 'yapra/plugin/publish/mail'

module Yapra::Plugin::Publish
  # = module: Publish::Smtp -- wtnabe
  # 
  # sending each entry via smtp.
  #
  # example:
  #     - module: Publish::Smtp
  #       config:
  #         username: username
  #         password: password
  #         smtp_server: smtp.example.com
  #         helo: [example.com]
  #         pop_server: [pop.example.com]
  #         authtype: pop | apop | :plain | :cram_md5
  #         port: 25
  #         # or 587
  #         wait: 1
  #         mail:
  #           subject_prefix: '[Yapra]'
  #           from_template: <%=item.author%> <test@example.com>
  #           from: 'test@example.com'
  #           # use for envelope from
  #           to: 'test2@example.com'
  #
  class Smtp < Mail
    def prepare
      super
      config['helo'] = config['helo'] || 'localhost.localdomain'
      if ( config['pop_server'] )
        config['port']     = config['port']     || 25
        config['authtype'] = config['authtype'] || 'pop'
      else
        config['port']     = config['port']     || 587
        config['authtype'] = config['authtype'] || :plain
      end
    end

    def open_session
      if ( config['pop_server'] )
        require 'net/pop'
        apop = (config['authtype'] == 'apop')
        Net::POP3.APOP(apop).auth_only(config['pop_server'], 110, config['username'], config['password'])
        config['username'] = nil
        config['password'] = nil
        config['authtype'] = nil
      end
      logger.info( "Connecting server: #{config['smtp_server']}, port: #{config['port']}, helo_domain: #{config['helo']}, accout: #{config['username']}, authtype: #{config['authtype']}" )
      @session = Net::SMTP.start(config['smtp_server'], config['port'],
                                 config['helo'],        config['username'],
                                 config['password'],    config['authtype'])
    end

    def close_session
      @session.finish
    end

    def send_item(msg, opt)
      @session.send_mail(msg, raw_mail_address(opt['from']), raw_mail_address(opt['to']))
    end
    
    MAIL_ADDRESS_FORMAT = /<([0-9a-z!#\$%\&'\*\+\/\=\?\^\|\-\{\}\.]+@[0-9a-z!#\$%\&'\*\+\/\=\?\^\|\-\{\}\.]+)>/
    def raw_mail_address address
      if MAIL_ADDRESS_FORMAT =~ address
        address = $1
      end
      return address
    end
  end
end
