#!/usr/bin/env ruby -wKU
$KCODE='u'
require 'yaml'
require 'optparse'
require 'kconv'
require 'pathname'
require 'base64'

YAPRA_ROOT = File.dirname(__FILE__)

$:.insert(0, *[
  File.join(YAPRA_ROOT, 'plugins'),
  File.join(YAPRA_ROOT, 'legacy_plugins'),
  File.join(YAPRA_ROOT, 'lib')
])

require 'yapra'

config_file = "config.yaml"
opt = OptionParser.new
opt.on("-c", "--configfile CONFIGFILE") {|v| config_file = v }
opt.on("-p", "--plugindir PLUGINDIR") {|v| $:.insert(0, v) }
# opt.on("-u", "--pluginusage PLUGINNAME") {|v| $plugins[v].source.gsub(/^## ?(.*)/){ puts $1 }; exit }
# opt.on("-l", "--listplugin") { $plugins.keys.sort.each{|k| puts k }; exit }
opt.on("-w", "--where") { puts(Pathname.new(__FILE__).parent + "plugin"); exit }
opt.parse!

require 'pp'
pp $:

yapra = Yapra::Base.new(YAML.load(File.read(config_file).toutf8.gsub(/base64::([\w+\/]+=*)/){ Base64.decode64($1) }))
yapra.execute([])
