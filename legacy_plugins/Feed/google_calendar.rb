## Read Google Calendar Events -- Soutaro Matsumoto
##
## Read Events from calendars.
## The output will be an array of GooleCalendar::Event.
##
## - module: feed::google_calendar
##   config:
##     mail: your gmail address
##     pass: your password
##     calendars:
##       - the names of
##       - your calendars
##     max: 200

begin
  require 'rubygems'
rescue LoadError
end
require 'gcalapi'
require 'date'

def google_calendar(config, data)
  today = Date.today

  pass = config['pass']
  mail = config['mail']
  calendar_pattern = Regexp.union(*config['calendars'].map{|ptn| /#{ptn}/})
  max = config['max'] || 200

  start_day = today - 30
  end_day = today + 31

  start_time = Time.mktime(start_day.year, start_day.month, start_day.day)
  end_time = Time.mktime(end_day.year, end_day.month, end_day.day)

  srv = GoogleCalendar::Service.new(mail, pass)
  cal_list = GoogleCalendar::Calendar.calendars(srv)

  cal_list.values.select {|cal|
    calendar_pattern =~ cal.title
  }.each {|cal|
    cal.events(:'max-results'=>max,
               :'start-min'=>start_time,
               :'start-max'=>end_time).each {|ev|
      data << ev if ev.st && ev.en && start_time <= ev.st && ev.en <= end_time
    }
  }

  data
end

