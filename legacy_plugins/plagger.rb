## Interleave Plagger processing -- Soutaro Matsumoto
##
## Invokes Plagger and process the input with your Plagger.
## The input must be an Array of RSS::RDF::Item.
## The output is an Array of RSS::RDF::Item.
## If "debug" is a value evaluated to true, tempolary files for/from Plagger won't be deleted.
## If "input" is not "feed", the input will be ignored.
## If you omit "dir", the default is /var.
## Make sure your system have /var directory and pragger/Plagger can write.
##
## - module: plagger
##   config:
##     input: feed
##     debug: false
##     dir: /var
##     plugins: 
##       - module: Publish::CSV
##         config: 
##           dir: /var
##           filename: a.csv

require 'rbconfig'
require 'open-uri'
require 'rss/1.0'
require 'rss/2.0'
require 'pathname'

raise LoadError unless ENV['PATH'].split(Config::CONFIG['PATH_SEPARATOR']).find {|dir|
  File.executable?(File.join(dir, 'plagger')) || File.executable?(File.join(dir, 'plagger.bat'))
}

def plagger(config, data)
  pla_con = config["plugins"]
  
  if input_option(config) == :feed
    pla_con = [{"module" => "Subscription::Feed", "config"=>{ "url" => "file:#{pla_input(config)}" }}] + pla_con
    eval_pragger([{"module" => "save_rss", "config" => { "filename" => pla_input(config).to_s }}], data)
  end
  
  pla_con.push({"module" => "Publish::Feed",
                 "config" =>
                 {"dir" => "/var",
                   "format" => "RSS",
                   "filename" => pla_output(config).basename.to_s}})
  
  pla_config(config).open("w") {|io| io.write to_plagger_yaml(YAML.dump({ "plugins" => pla_con })) }
  
  system "plagger -c #{pla_config(config)}"
  
  begin
    RSS::Parser.parse(pla_output(config).read).items
  rescue
    []
  ensure
    unless config.has_key?("debug")
      pla_config(config).delete
      pla_input(config).delete
      pla_output(config).delete
    end
  end
end

def pla_dir(config)
  Pathname.new(config.has_key?("dir") ? config["dir"] : "/var")
end

def pla_config(config)
  pla_dir(config) + "pla.yaml"
end

def pla_output(config)
  pla_dir(config) + "pla_output"
end

def pla_input(config)
  pla_dir(config) + "pla_input"
end

def input_option(config)
  opt = config.has_key?("input") ? config["input"] : "nothing"
  case opt
  when "feed" then :feed
  when "nothing" then :nothing
  else
    :nothing
  end
end

def to_plagger_yaml(yaml)
  a = yaml.split(/\n/)
  ret = a[1]+"\n"
  ret + a[2..(a.size-1)].collect {|x| "  "+x }.join("\n")+"\n"
end

