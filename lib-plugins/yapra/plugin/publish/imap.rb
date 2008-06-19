# module: Publish::Imap -- Yuanying
#
# publish entry to imap mail.
#
# example:
#
# - module: Publish::Imap
#   config:
#     username: username
#     password: password
#     imap_server: imap.gmail.com
#     port: 993
#     ssl: on
#     wait: 1
#     mail:
#       subject_prefix: '[Yapra]'
#       from: 'test@example.com'
#       to: 'test2@example.com'
#
require 'net/imap'
require 'yapra/plugin/base'

module Yapra::Plugin::Publish
  class Imap < Yapra::Plugin::Base
    def run(data)
      username  = config['username']
      password  = config['password']
      server    = config['imap_server'] || 'imap.gmail.com'
      port      = config['port'] || 993
      usessl    = ('off' != config['ssl'])
      mailbox   = config['mailbox'] || 'inbox'
      wait      = config['wait'] || 1
      
      unless config['mail']
        config['mail'] = {}
      end
      subject_prefix  = config['mail']['subject_prefix'] || ''
      from            = config['mail']['from'] || 'yapra@localhost'
      to              = config['mail']['to']   || 'me@localhost'
      
      imap = create_imap server, port, usessl
      logger.info(imap.greeting)
      
      imap.login(username, password)
      imap.examine(mailbox)
      data.each do |item|
        date = item.date || item.dc_date || Time.now
        content = item.content_encoded || item.description || 'from Yapra.'
        content = [content].pack('m')
        imap.append("inbox", <<EOF.gsub(/¥n/, "¥r¥n"), nil, date)
From: #{from}
To: #{to}
Date: #{date.rfc2822}
MIME-Version: 1.0
Content-type: text/html; charset=UTF-8
Content-transfer-encoding: base64
X-Mailer: Yapra 0.1
Subject: #{encode_field(subject_prefix + item.title)}

#{content}
EOF
        sleep wait
      end
      imap.disconnect
      
      data
    end
    
    protected
    def create_imap server, port, usessl
      logger.debug("server: #{server}:#{port}, usessl = #{usessl}")
      Net::IMAP.new(server, port, usessl)
    end
    def encode_field field
      #field.gsub(/[　-瑤]\S*\s*/) {|x|
        field.scan(/.{1,10}/).map {|y|
          "=?UTF-8?B?" + y.to_a.pack('m').chomp + "?="
        }.join("\n ")
      #}
    end
  end
end