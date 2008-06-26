## Read data from stdin -- Soutaro Matsumoto

def stdin(config, data)
  stdin_data = readlines
  (config || { "input" => "concat" })["input"] == "nothing" ? stdin_data : data + stdin_data
end
