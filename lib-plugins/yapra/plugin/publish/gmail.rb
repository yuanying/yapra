require 'net/imap'
require 'yapra/plugin/publish/imap'

module Yapra::Plugin::Publish
  # = module: Publish::Gmail -- Yuanying
  #
  # publish entry to imap mail.
  #
  # example:
  #
  #    - module: Publish::Gmail
  #      config:
  #        username: username
  #        password: password
  #        wait: 1
  #        mail:
  #          subject_prefix: '[Yapra]'
  #          from: 'test@example.com'
  #          to: 'test2@example.com'
  #
  class Gmail < Yapra::Plugin::Publish::Imap
    protected
    def prepare
      super
      config['imap_server'] = 'imap.gmail.com'
      config['port']        = 993
      config['ssl']         = true
    end
  end
end
