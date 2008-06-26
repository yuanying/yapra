## concat two data -- IKeJI
##
## concat two data plugin.
## this plugin is concat two data.
##
## - module: concat
##   config:
##     - module: foo
##     - module: bar
##     - module: baz
##


def concat(config,data)
  data2 = eval_pragger(config,[])
  return data+data2
end

