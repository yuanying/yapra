## Publish::scuttle - to post feed items to scuttle -- emergent
##
## - module: Publish::scuttle
##   config:
##     url: http://your.example.com/scuttle/
##     username: your_username
##     password: your_password
##     opt_tag: pragger
##     no_comment: 1
##
require 'rubygems'
require 'mechanize'
require 'uri'
require 'kconv'

class Scuttle

  def initialize url, username, password, proxy=nil
    @post_url = url + 'api/posts/add?'
    @username = username
    @password = password
    @agent    = WWW::Mechanize.new
    @agent.basic_auth(@username, @password)
    if proxy && proxy.is_a?(Hash) && proxy['proxy_addr'] && proxy['proxy_port']
      @agent.set_proxy(proxy['proxy_addr'], proxy['proxy_port'],
                       proxy['proxy_user'], proxy['proxy_pass'])
    end
  end

  def post url, desc, option=nil
    params = {}
    
    params[:url] = url
    params[:description] = desc

    if option
      params[:extended] = option["summary"]  if option["summary"]
      params[:dt]       = option["datetime"] if option["datetime"]
      params[:tags]     = option["tags"]     if option["tags"]
      params[:replace]  = 'no'               if option["no_replace"]
      params[:shared]   = 'no'               if option["private"]
    end

    req_param = []
    params.each do |k,v|
      req_param << k.to_s.toutf8 + '=' + v.toutf8 if (v.length > 0)
    end
    result = @agent.get(URI.encode(@post_url + req_param.join('&')))
    if result.body =~ /code="done"/
      return true
    end
    false
  end
end

def get_tags entry
  entry.dc_subjects.map do |s| s.content end.join(' ') rescue ''
end

def scuttle config, data
  sleeptime = 3

  if config['sleep']
    sleeptime = config['sleep'].to_i
  end

  data.each {|entry|
    print 'posting ' + entry.title + ': '
    
    tags = get_tags entry
    if config['opt_tag']
      tags = [tags, config['opt_tag']].select{|t| t.length > 0}.join(' ')
    end

    summary = config['no_comment'] ? entry.description : ''

    begin
      agent = Scuttle.new(config['url'], config['username'], config['password'])
      res = agent.post(entry.link, entry.title,
                       'tags' => tags, 'summary' => summary)
                       
      if res then puts 'done' else puts 'failed' end
    rescue
      puts 'exception'
      #raise
    end

    sleep sleeptime
  }
  return data
end

