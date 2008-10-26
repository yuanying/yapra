require 'net/imap'
require 'yapra/plugin/publish/mail'

module Yapra::Plugin::Publish
  # = module: Publish::Imap -- Yuanying
  # 
  # publish entry to imap mail.
  # 
  # example:
  # 
  #     - module: Publish::Imap
  #       config:
  #         username: username
  #         password: password
  #         imap_server: imap.gmail.com
  #         port: 993
  #         ssl: on
  #         wait: 1
  #         mail:
  #           subject_prefix: '[Yapra]'
  #           from_template: <%=item.author%> <test@example.com>
  #           #from: 'test@example.com'
  #           to: 'test2@example.com'
  #
  class Imap < Mail
    protected
    def prepare
      super
      config['imap_server'] = config['imap_server'] || 'imap.gmail.com'
      config['port']        = config['port'] || 993
      config['ssl']         = ('off' != config['ssl'])
      config['mailbox']     = config['mailbox'] || 'inbox'
    end

    def open_session
      logger.debug("server: #{config['imap_server']}:#{config['port']}, usessl = #{config['ssl']}")
      imap = Net::IMAP.new(config['imap_server'], config['port'], config['ssl'])
      logger.debug(imap.greeting)
      imap.login(config['username'], config['password'])
      logger.info('imap login was succeed.')
      imap.examine(config['mailbox'])
      @session = imap
    end

    def close_session
      @session.disconnect
    end

    def send_item(msg, opt)
      @session.append(config['mailbox'], msg, nil, opt['date'])
    end
  end
end
