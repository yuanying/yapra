## Download Nicovideo FLV -- IKeJI
##
## Download from Nicovideo to file
##
## - module: Download::nicovideo
##   config:
##     authfile: nicovideo_auth.yaml
##     dir: ./nicovideo

require 'rubygems'
require 'mechanize'
require 'cgi'

def nicovideo(config,data)
  auth = YAML.load( File.read( config['authfile'] ) )
  agent = WWW::Mechanize.new
  
  page = agent.post("https://secure.nicovideo.jp/secure/login?site=niconico",
      {"mail"=>auth["mail"],"password"=>auth["password"]})
  sleep 3
  data.each do|dat|
    link = dat.link
    next unless link =~ /www\.nicovideo\.jp\/watch\/(.*)/
    id = $1
    next if File.exist?("#{config['dir']}/#{id}.flv")
    begin
      page = agent.get("http://www.nicovideo.jp/api/getflv?v=#{id}")
      sleep 3
      list = CGI.parse(page.body)
      flv = agent.get(link)
      sleep 3
      flv = agent.get(list['url'])
      sleep 3
      File.open("#{config['dir']}/#{id}.flv","w")do |w|
        w.write flv.body
      end
      File.open("#{config['dir']}/list.html","a")do |w|
        w.puts "<h3><a href='#{id}.flv'>#{dat.title}</a></h3><p><a href='#{dat.link}'>#{dat.description}</a>"
      end
    rescue 
      STDERR.puts "an error occurred in downloadng FLV #{id}"
    end
    sleep 3
  end
end
