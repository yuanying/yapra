def subs(config,data)
  reg = Regexp.new(config["regex"])
  to = config["to"]
  return data.map {|i| i.gsub(reg,to) }
end

