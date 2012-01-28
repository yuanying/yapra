## Post data to Hatena Graph -- takatoh
##
## hatenaapigraph 0.2.1 is required.
##
## - module: Publish::hatena_graph
##   config:
##     user_id: your-hatena-user-id
##     password: your-password
##     graph_name: the-name-of-graph
##     proxy_host: proxy-host-name   (optional)
##     proxy_port: proxy-port        (optional)
##     proxy_user: proxy-user        (optional)
##     proxy_pass: proxy-password    (optional)

begin
  require 'rubygems'
  gem 'hatenaapigraph', '>=0.2.2'
rescue Exception
end
require 'hatena/api/graph'


def hatena_graph(config, data)
  graph = Hatena::API::Graph.new(config['user_id'], config['password'])
  if config['proxy_host']
    proxy_host = config['proxy_host']
    proxy_port = config['proxy_port']
    proxy_user = config['proxy_user']
    proxy_pass = config['proxy_pass']
    graph.proxy = ::Net::HTTP.Proxy(proxy_host, proxy_port, proxy_user, proxy_pass)
  end
  data.each do |d|
    begin
      graph.post_data(config['graph_name'], :date => d.date, :value => d.value.to_f)
    rescue
      graph.post_data(config['graph_name'], :date => Date.today, :value => d.to_f)
    end
  end
end
