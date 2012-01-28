## author "emergent"
## description  "post feeds to hatena bookmark"
## this requires hatenabm
## -----
## $ gem install hatenabm
## -----
## example <<EOE
## - module: Publish::hatena_bookmark
##   config:
##     username: your_username
##     password: your_password
##     opt_tag: "imported"
##     no_comment: 1
## EOE
## config({ :username => Field.new("username to login", String, true),
##          :password => Field.new("password to login", String, true),
##          :opt_tag => Field.new("optional tag(s)", String) })
require 'rubygems'
require 'hatenabm'

def hatena_bookmark(config, data)
  sleeptime = config["sleep"] ? config["sleep"].to_i : 2

  opt_tag = config[:opt_tag] || ''
  hbm = HatenaBM.new(:user => config['username'],:pass => config['password'])

  data.each {|entry|
    puts 'posting ' + entry.title + ': '

    tags = entry.dc_subjects.map do |s| s.content end.join(' ') rescue ''
    if config['opt_tag']
      tags = [tags, config['opt_tag']].select{|t| t.length > 0}.join(' ')
    end

    summary = config['no_comment'] ?  '' : entry.description

    hbm.post(
             :title => entry.title,
             :link  => entry.link,
             :tags  => tags,
             :summary => summary
             )
    sleep sleeptime
  }
  return data
end

