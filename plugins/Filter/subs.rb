def subs(config,data)
  reg = Regexp.new(config["regex"])
  to = config["to"]
  attribute = config['attribute']
  data.map! do |i|
    if attribute
      if i.respond_to?(attribute) && i.respond_to?("#{attribute}=")
        i.__send__("#{attribute}=", i.__send__("#{attribute}").gsub(reg, to))
      end
    else
      i = i.gsub(reg,to)
    end
    i
  end
  return data
end