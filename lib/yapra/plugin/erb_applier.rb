require 'yapra/plugin'
require 'erb'
require 'uri'

module Yapra::Plugin::ErbApplier
  def apply_template template, apply_binding=binding
    if template.index('file://') == 0
      path = URI.parse(template).path
      open(path) do |io|
        template = io.read
      end
    end
    ERB.new(template, nil, '-').result(apply_binding)
  end
end