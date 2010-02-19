## author "emergent"
## descr  "post feed(s) to mixi diary"
## 
## example <<EOE
## when posting one diary per one feed 
## - module: publish::mixi_diary_writer
##   config:
##     username: test@test.com
##     password: ********
## 
## when posting merged feeds to one diary
## - module: publish::mixi_diary_writer
##   config:
##     username: test@test.com
##     password: ********
##     title: "フィード一覧"
##     merge_feeds: 1
## EOE
## config({ :username => Field.new("username to login", String, true),
##          :password => Field.new("password to login", String, true),
##          :merge_feeds => Field.new("aggregate feeds to one diary", String),
##          :title => Field.new("title when merge_feeds is on", String) })

require 'rubygems'
require 'mechanize'
require 'kconv'

class MixiDiaryWriter

  def initialize username=nil, password=nil
    @id = nil
    @username = username
    @password = password
    @agent = defined?(Mechanize) ? Mechanize.new : WWW::Mechanize.new
  end

  def login username=@username, password=@password
    if username == nil || password == nil
      return
    else
      @username = username
      @password = password
    end
    @agent.post('http://mixi.jp/login.pl', 
                { 'email' => @username,
                  'password' => @password,
                  'next_url' => '/home.pl' })
    @home_page = @agent.get('http://mixi.jp/home.pl')
  end

  def edit title, content
    if /add_diary\.pl\?id=(\d+)/ =~ @home_page.body
      @id = $1
    end

    @edit_page = @agent.get('http://mixi.jp/add_diary.pl?id='+@id)

    begin
      edit_form = @edit_page.forms.name("diary").first
      edit_form['diary_title'] = title.toeuc
      edit_form['diary_body'] = content.toeuc
      confirm_page = @agent.submit(edit_form)
    
      conf_form = confirm_page.forms[0] # select 'hai'
      @agent.submit(conf_form)
    rescue => e
      puts "Exception when posting diary"
      puts e.message
      puts e.backtrace.join("\n")
    end
  end

  OK_TAGS = 'a|p|strong|em|u|del|blockquote'
  def striptags str
    str.gsub!(/<br.*?>/, "\n")
    str.gsub!(/<[\/]{0,1}(?!(?:(?:#{OK_TAGS})(?:\s|>)))\w+[\s]{0,1}.*?>/, '')
    str
  end
end

def mixi_diary_writer(config, data)
  title = config['title'] || data[0].title
  content = []

  if config['merge_feeds'] #.to_i == 1
    data.each {|item|
      content << {:title => title, :body => ('- <a href="'+item.link+'">'+item.title+"</a>\n"+item.description+"...\n\n" rescue item.to_s)}
    }
  else
    data.each {|d|
      # delete line feed and space at the top of content
      content << {:title => d.title, :body => d.content_encoded.to_s.sub(/^(?:\s+)/, '')}
    }
  end

  mdw = MixiDiaryWriter.new(config['username'], config['password'])

  content.each {|entry|
    mdw.login
    mdw.edit entry[:title], mdw.striptags(entry[:body])
  }

  return data
end
