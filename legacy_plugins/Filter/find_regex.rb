def find_regex(config,data)
  retval = []
  reg = Regexp.new(config["regex"])
  data.each do |text|
    text.gsub(reg) {|i| retval.push(i) }
  end
  return retval
end

