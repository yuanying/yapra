## Write Google Calendar Events -- Soutaro Matsumoto
## 
## Write Events on given Calendar.
## The input must be an array of GooleCalendar::Event.
##
## - module: publish::google_calendar
##   config:
##     mail: your gmail address
##     pass: your password
##     calendar: the name of calendar

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
  calendar_name = /#{config['calendar']}/

  start_day = today - 30
  end_day = today + 31
  
  start_time = Time.mktime(start_day.year, start_day.month, start_day.day)
  end_time = Time.mktime(end_day.year, end_day.month, end_day.day)
  
  srv = GoogleCalendar::Service.new(mail, pass)
  cal_list = GoogleCalendar::Calendar.calendars(srv)
  calendar = cal_list.values.find {|cal| calendar_name =~ cal.title }
  
  if calendar
    calendar.events(:'start-min' => start_time, :'start-max' => end_time).each {|event|
      event.destroy!
    }
    
    data.each {|event|
      begin
        new_event = calendar.create_event
        new_event.title = event.title
        new_event.desc = event.desc
        new_event.where = event.where
        new_event.st = event.st
        new_event.en = event.en
        new_event.allday = event.allday
        new_event.save!
      rescue
      end
    }
  end

  data
end

