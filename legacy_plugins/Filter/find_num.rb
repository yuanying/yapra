def find_num(config,data)
  retval = []
  data.each do |text|
    text.gsub(/\d(\d|,)+/) {|i| retval.push(i) }
  end
  return retval
end

