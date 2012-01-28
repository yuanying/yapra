## Send Message Plugin -- Soutaro Matsumoto
##
## it invoke ruby method
##
## -module: send_msg
##  config:
##    method: to_s
##    params: 16
##

def send_msg(config, data)
  method = config['method'] || nil
  params = config['params'] || []

  data.collect {|x|
    method ? x.send(method, *params) : x
  }
end
