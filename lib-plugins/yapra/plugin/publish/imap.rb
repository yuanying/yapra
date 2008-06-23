require 'net/imap'
require 'yapra/version'
require 'yapra/plugin/base'

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
      logger.info('imap login was succeed.')
      imap.examine(mailbox)
      data.each do |item|
        date = item.date || item.dc_date || Time.now
        content = item.content_encoded || item.description || 'from Yapra.'
        content = [content].pack('m')
        if config['mail']['from_template']
          from = apply_template(config['mail']['from_template'], binding)
        end
        if config['mail']['to_template']
          to = apply_template(config['mail']['to_template'], binding)
        end
        logger.debug("try append item: #{date}")
        boundary = "----_____====#{Time.now.to_i}--BOUDARY"
        attachments = create_attachments(item, config)
        imap.append(mailbox, apply_template(mail_template, binding), nil, date)
        #puts apply_template(mail_template, binding)

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
    
    def create_attachments item, config
      attachments = []
      attachment_attributes = config['mail']['attachments']
      if attachment_attributes.kind_of?(String)
        file = item.__send__(attachment_attributes)
        attachments << file if file.kind_of?(WWW::Mechanize::File)
      elsif attachment_attributes.kind_of?(Array)
        attachment_attributes.each do |atc|
          file = item.__send__(atc)
          attachments << file if file.kind_of?(WWW::Mechanize::File)
        end
      end
      attachments
    end
    
    def mail_template
      return <<EOT
From: <%=encode_field(from) %>
To: <%=encode_field(to) %>
Date: <%=date.rfc2822 %>
MIME-Version: 1.0
X-Mailer: Yapra <%=Yapra::VERSION::STRING %>
Subject: <%=encode_field(subject_prefix + item.title) %>
Content-Type: multipart/mixed; boundary="<%=boundary -%>"
Content-Transfer-Encoding: 7bit

This is a multi-part message in MIME format.

--<%=boundary %>
Content-type: text/html; charset=UTF-8
Content-transfer-encoding: base64

<%=content %>

--<%=boundary %>
<% attachments.each do |file| -%>
Content-Type: <%=file.header['Content-Type'] %>;
	name="<%=encode_field(file.filename) %>"
Content-Disposition: attachment;
	filename="<%=encode_field(file.filename) %>"
Content-Transfer-Encoding: base64

<%=[file.body].pack('m') -%>

--<%=boundary %>

<% end -%>
EOT
    end
  end
end