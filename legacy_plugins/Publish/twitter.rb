##Publish::twitter  -- itoshi
##
## from: http://itoshi.tv/d/?date=20071123#p01
##
##- module: Publish::twitter
##  config:
##    login: xxxxxx
##    password: xxx
##    check: 30##
##

begin
  require 'rubygems'
rescue LoadError
end
require 'twitter'
require 'kconv'

def twitter(config, data)
  c = Twitter::Client.new(:login=>config["login"], :password=>config["password"])

  posts = c.timeline_for(:me,:count=>config["check"])
  posted_entries = posts.map do |post| post.text.gsub!(/ http.+$/, '') end

  data.reverse.each {|item|
    link  = item.link
    title = item.title.toutf8

    next if posted_entries.include? title

    comment = [title, link].join(' ')
    s = c.status(:post, comment)
    p comment
  }
end
