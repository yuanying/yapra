def fresh(config,data)
  t = config['duration']
  t = t.to_i * (60)       if t=~/m$/
  t = t.to_i * (60*60)    if t=~/h$/
  t = t.to_i * (60*60*24) if t=~/d$/
  data.delete_if do |i|
    i.date < (Time.now - t)
  end
end
