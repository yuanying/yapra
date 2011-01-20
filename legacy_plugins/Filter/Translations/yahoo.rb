## Translate input strings by Yahoo Honyaku -- Soutaro Matsumoto

def yahoo(config, data)
  begin
    require 'rubygems'
  rescue LoadError
  end
  require 'mechanize'


  config = (config || { "translation" => "en=>ja" })

  trans = case config["translation"]
          when "en=>ja" then "EJ"
          when "kr=>ja" then "KJ"
          when "cn=>ja" then "CJ"
          when "ja=>en" then "JE"
          when "ja=>kr" then "JK"
          when "ja=>cn" then "JC"
          else
            return data
          end
  
  data.collect {|d|
    if d && d =~ /\S/
      agent = defined?(Mechanize) ? Mechanize.new : WWW::Mechanize.new
      start = agent.get("http://honyaku.yahoo.co.jp/")
      form = start.forms.last
      
      form.radiobuttons.each {|radio| radio.checked = (radio.value =~ /#{trans}/) ? true : false }
      form.fields.name("text").first.value = d
      
      result = agent.submit(form)
      result.forms.name("textFormEntry").fields.name("trn_text").value
    else
      d.to_s
    end
  }

end
