def create_compare_proc config
  if(config==nil || config["method"] == nil)
    return lambda do |a, b|
      a <=> b
    end
  elsif config["method"].kind_of?(Hash)
    return lambda do |a, b|
      eval_pragger(config["method"],[a])[0] <=> eval_pragger(config["method"],[b])[0]
    end
  else
    return lambda do |a, b|
      method = config['method']
      a = a.respond_to?(method) ? a.__send__(method) : nil
      b = b.respond_to?(method) ? b.__send__(method) : nil
      return a <=> b if a.respond_to?('<=>')
      return b <=> a if b.respond_to?('<=>')
      nil
    end
  end
end

def sort(config,data)
  proc = create_compare_proc(config)
  return data.sort do|a, b|
    proc.call(a, b)
  end
end

