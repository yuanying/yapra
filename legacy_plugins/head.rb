## head plugin -- IKeJI
##
## it looks like linux head command.
## this example is like 'head -n 10'
##
## -module: head
##  config:
##    n: 10
##

def head(config,data)
  return data[0, config['n'].to_i]
end

