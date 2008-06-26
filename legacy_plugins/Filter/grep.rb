## Filter input by given regular expression -- IKeJI
## 
## Filter input by given regular expression.
## The test will be done with the result of to_s method of the input.
## invert option will invert results(-v option of UNIX grep command).
##
## - module: grep
##   config:
##     regex: "[あ-ん]"
##     invert: false

def grep(config,data)
  regex = Regexp.new(config["regex"])
  invert = config["invert"] || false
  data.select {|i| invert ^ (regex =~ i.to_s) }
end
