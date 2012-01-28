## filter::invert
##
## Apply filter of config: section and invert the result.
##
## - module: filter::invert
##   config:
##     - module: grep
##       config:
##         regex: "理系の人々"
##

def invert(config, data)
  data - eval_pragger(config, data)
end
