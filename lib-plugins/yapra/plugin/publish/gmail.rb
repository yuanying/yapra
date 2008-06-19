# module: Publish::Gmail -- Yuanying
#
# publish entry to imap mail.
#
# example:
#
# - module: Publish::Gmail
#   config:
#     username: username
#     password: password
#     wait: 1
#     mail:
#       subject_prefix: '[Yapra]'
#       from: 'test@example.com'
#       to: 'test2@example.com'
#
require 'net/imap'
require 'yapra/plugin/base'

module Yapra::Plugin::Publish
  class Gmail < Yapra::Plugin::Base
    protected
    def create_imap server, port, usessl
      Net::IMAP.new('imap.gmail.com', 993, true)
    end
  end
end