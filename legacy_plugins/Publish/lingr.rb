
def lingr(config,data)
  require 'open-uri'
  require 'kconv'
  require 'net/http'
  require 'rexml/document'
  Net::HTTP.version_1_2
  lapi = LingrRoom.new(config['key'],config['room']||'pragger',config['nick']||'praggrTan')

  data.each do |i|
    txt = i.title rescue txt = i.to_s
    lapi.say txt
  end
  return data
end

# Lingr API is from Sasada
# http://www.atdot.net/~ko1/diary/200702.html#d5

class LingrRoom
  class LingrAPIError < RuntimeError; end

  def initialize key, room, nick
    @key = key
    create_session
    enter room, nick
    @active = true
  end

  def post uri, params = {}
    uri = URI.parse("http://www.lingr.com/api/#{uri}")
    Net::HTTP.start(uri.host, uri.port) {|http|
      response = http.post(uri.path, uri.query)
      body = response.body

      if false # ||true
        puts "---------------------------------------------"
        puts response.code
        puts uri
        puts body
        body
      end
      body
    }
  end

  def get uri, params = {}
    open("http://www.lingr.com/api/#{uri}"){|f|
      f.read
    }
  end

  def get_text doc, path
    e = doc.elements[path]
    raise LingrAPIError.new("path not found: #{path} at #{doc}") unless e
    e.get_text
  end

  def request method, uri, params
    doc = REXML::Document.new(__send__(method, uri, params))
    raise LingrAPIError.new("Error: #{doc.to_s}") if get_text(doc, '/response/status') != 'ok'
    doc
  end

  def post_request uri, params = {}
    request :post, uri, params
  end

  def get_request uri, params = {}
    request :get, uri, params
  end

  def create_session
    doc = post_request "session/create?api_key=#{@key}"
    @session = get_text(doc, '/response/session')
  end

  def enter room, nick
    doc = post_request "room/enter?session=#{@session}&id=#{room}&nickname=#{nick}"
    @room_doc = doc
    @ticket = get_text(doc, '/response/ticket')
    @counter = get_text(doc, '/response/room/counter')
  end

  def observe
    doc = get_request "room/observe?session=#{@session}&ticket=#{@ticket}&counter=#{@counter}"
    #
    @counter = get_text(doc, '/response/counter')
    result = []
    doc.elements['/response/messages'].each{|e|
      nick = get_text(e, 'nickname')
      text = get_text(e, 'text')
      result << [nick, text]
    }
    result
  end

  def observe_loop
    while @active
      observe.each{|nick, text|
        puts "#{nick}: #{text}".tosjis
      }
    end
  end

  def say text
    doc = post_request "room/say?session=#{@session}&ticket=#{@ticket}&message=#{URI.encode(text)}"
  end
end

