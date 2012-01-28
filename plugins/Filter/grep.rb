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
  regex     = Regexp.new(config["regex"])
  invert    = config["invert"] || false
  attribute = config['attribute']

  data.select do |i|
    if attribute
      invert ^ (regex =~ i.__send__(attribute).to_s)
    else
      invert ^ (regex =~ i.to_s)
    end
  end
end
