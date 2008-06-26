## Filter::deduped - Plugin to get Deduped entries -- emergent
## 
## Plugin to get Deduped entries
## Cache path can be set.
##
## - module: Filter::deduped
##   config:
##    path: /tmp/cache/hoge
##
require 'pathname'
require 'digest/md5'

def mkdir_p path
  begin
    Dir.mkdir(path)
  rescue Errno::ENOENT
    mkdir_p Pathname.new(path).parent
    retry
  rescue Errno::EACCES
    raise
  end
  0
end

def deduped config, data
  cacheroot = Pathname(__FILE__).parent.parent.parent.realpath + 'cache'
  cachepath = Pathname.new(config['path']) || root
  if cachepath.relative?
    cachepath = cacheroot + cachepath
  end
  puts '  cache path: ' + cachepath

  if !File.exists?(cachepath)
    begin
      mkdir_p cachepath
    rescue
      puts "could'nt make cache directory"
      return data
    end
  end
  
  deduped_data = data.select {|d|
    hashpath = cachepath.to_s + '/' + Digest::MD5.hexdigest(d.to_s)
    if File.exists?(hashpath)
      false
    else 
      File.open(hashpath, "wb").write(d.to_s) rescue false
    end
  }
  return deduped_data
end
