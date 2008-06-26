## Load plugin from uri and evaluate it -- Soutaro Matsumoto
##
## Load plugiin from uri and evaluate it.
## If you omit "name", the last component of the uri will be used as the name of plugin.
##
## - module: plugin_from_uri
##   config:
##     uri: http://some_host/some_path
##     name: super_plugin
##     config:
##       ** configuration for the plugin **

require 'open-uri'
require 'uri'

def plugin_from_uri(config, data)
  uri = URI(config["uri"])
  name = config["name"] || uri.path.split("/").last.gsub(/\..*$/,'')
  
  body = open(uri.to_s) {|io| io.read}
  
  plugin = Class.new(Plugin)
  plugin.class_eval {
    def initialize()
    end
  }
  plugin.class_eval(body, uri.to_s, 1)
  
  plugin.new().send(name, config["config"], data)
end

