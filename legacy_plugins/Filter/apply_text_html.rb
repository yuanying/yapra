
def apply_text_html(config, data)
  begin
    require 'rubygems'
  rescue LoadError
  end
  require 'hpricot'

  data.collect {|d|
    doc = Hpricot(d.to_s.toutf8)
    texts = []
    doc.traverse_text {|text|
      texts << text.to_s
    }

    data2 = eval_pragger(config, texts)

    result_html = d.to_s.toutf8

    Hash[*texts.zip(data2).flatten].each {|k,v|
      result_html.sub!(k,v)
    }

    result_html
  }
end
