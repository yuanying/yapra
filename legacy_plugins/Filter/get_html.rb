def get_html(config,data)
  require 'open-uri'
  require 'kconv'

  data.map do |line|
    r = ""
    open(line) {|f| r = f.read.toutf8 }
    r
  end
end

