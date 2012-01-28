require 'mechanize'
require 'kconv'
require 'yapra/plugin/base'

class Yapra::Plugin::MechanizeBase < Yapra::Plugin::Base
  def agent
    pipeline.context['mechanize_agent'] ||= (defined?(Mechanize) ? Mechanize.new : WWW::Mechanize.new)
    pipeline.context['mechanize_agent']
  end

  def extract_attribute_from element, item, binding=nil
    if plugin_config['extract_xpath']
      plugin_config['extract_xpath'].each do |k, v|
        value = nil
        case v.class.to_s
        when 'String'
          value = element.search(v).to_html.toutf8
        when 'Hash'
          ele = element.at( v['first_node'] )
          value = ( ele.nil? ) ? nil : ele.get_attribute( v['attr'] )
        end
        set_attribute_to item, k, value
      end
    end

    if plugin_config['apply_template_after_extracted']
      plugin_config['apply_template_after_extracted'].each do |k, template|
        value = apply_template template, binding
        set_attribute_to item, k, value
      end
    end
  end
end