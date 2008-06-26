## average plugin -- takatoh

def average(config, data)
  sum = data.inject(0.0){|a,b| a + b.to_f }
  return [ sum / data.size ]
end
