require 'mechanize'
require 'kconv'
require 'yapra/plugin/base'

class Yapra::Plugin::MechanizeBase < Yapra::Plugin::Base
  def agent
    pipeline.context['mechanize_agent'] ||= WWW::Mechanize.new
    pipeline.context['mechanize_agent']
  end
  
  def extract_attribute_from element, item
    if config['extract_xpath']
      config['extract_xpath'].each do |k, v|
        value = element.search(v).to_html.toutf8
        set_attribute_to item, k, value
      end
    end

    if config['apply_template_after_extracted']
      config['apply_template_after_extracted'].each do |k, template|
        value = apply_template template, binding
        set_attribute_to item, k, value
      end
    end
  end
end