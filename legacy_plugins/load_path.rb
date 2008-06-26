## Add path to $LOAD_PATH -- gtaka555
##
## Add path to $LOAD_PATH plugin.
##
## - module: load_path
##   config:
##     path:
##       - /home/foo/ruby/lib/1
##       - /home/foo/ruby/lib/2
##       - /home/foo/ruby/lib/3
##

def load_path(config, data)
  return data  unless config.key?('path')

  config['path'].each {|path|
    $LOAD_PATH << path
  }

  data
end
