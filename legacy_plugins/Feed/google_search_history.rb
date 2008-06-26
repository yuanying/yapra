## get Google search history -- IKeJI
##
## for example you can get your search keyword 'harahetta'
##
## -module: Feed::google_search_history
##  config:
##    user: hoge
##    pass: fuga
##

require 'net/https'
require 'rss/1.0'
require 'rss/2.0'
require 'rss/maker'

def google_search_history(config,data)
  Net::HTTP.version_1_2
  req = Net::HTTP::Get.new('/searchhistory/?output=rss')
  req["Accept-Language"] = "ja"
  req["Accept-Charset"] = "utf-8"
  req.basic_auth config['user'],config['pass']
  ht = Net::HTTP.new("www.google.com",443)
  ht.use_ssl = true
  ht.start do |http|
    while(true)
      response = http.request(req)
      if(response.kind_of? Net::HTTPRedirection )
        req = Net::HTTP::Get.new(response['location'])
        req["Accept-Language"] = "ja"
        req["Accept-Charset"] = "utf-8"
        req.basic_auth config['user'],config['pass']
      else
        break
      end
    end
    rss = nil
    begin
      rss = RSS::Parser.parse(response.body)
    rescue RSS::InvalidRSSError
      rss = RSS::Parser.parse(response.body, false)
    end
    return rss.items rescue []
  end
end

