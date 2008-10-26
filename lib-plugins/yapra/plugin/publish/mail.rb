require 'yapra/version'
require 'yapra/plugin/base'

module Yapra::Plugin::Publish
  class Mail < Yapra::Plugin::Base
    def initialize
      @session = nil
    end

    def run(data)
      prepare

      unless config['mail']
        config['mail'] = {}
      end
      subject_prefix  = config['mail']['subject_prefix'] || ''
      from            = encode_field(config['mail']['from'] || 'yapra@localhost')
      to              = encode_field(config['mail']['to']   || 'me@localhost')

      open_session
      
      data.each do |item|
        date = item.date || item.dc_date || Time.now
        content = item.content_encoded || item.description || 'from Yapra.'
        content = [content].pack('m')
        if config['mail']['from_template']
          from = encode_field(apply_template(config['mail']['from_template'], binding))
        end
        if config['mail']['to_template']
          to = encode_field(apply_template(config['mail']['to_template'], binding))
        end
        subject = (subject_prefix + item.title).gsub(/\n/, '').chomp
        logger.debug("try append item: #{subject}")
        boundary = "----_____====#{Time.now.to_i}--BOUDARY"
        attachments = create_attachments(item, config)
        send_item(apply_template(mail_template, binding),
                  {'date' => date, 'from' => from, 'to' => to})

        sleep config['wait']
      end
      close_session
      
      data
    end

    protected
    def prepare;
      config['wait'] = config['wait'] || 1
    end

    def open_session;        end # template
    def close_session;       end # template
    def send_item(msg, opt); end # template

    def encode_field field
      field.gsub(/[^\x01-\x7f]*/) {|x|
        x.scan(/.{1,10}/).map {|y|
          "=?UTF-8?B?" + y.to_a.pack('m').chomp + "?="
        }.join("\n ")
      }
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
From: <%=from %>
To: <%=to %>
Date: <%=date.rfc2822 %>
MIME-Version: 1.0
X-Mailer: Yapra <%=Yapra::VERSION::STRING %>
Subject: <%=encode_field(subject) %>
Content-Type: multipart/mixed; boundary="<%=boundary -%>"

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
