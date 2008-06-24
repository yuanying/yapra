require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'yapra/legacy_plugin/base'

describe Yapra::LegacyPlugin::Base do
  
  before do
    @pipeline = mock('pipeline', :null_object => true)
  end
  
  describe 'which is initialized by "fixtures/legacy_test_plugin.rb"' do
    before do
      @path = File.join($fixture_dir, 'legacy_plugin', 'legacy_test_plugin.rb')
      @plugin = Yapra::LegacyPlugin::Base.new(@pipeline, @path)
    end
    
    it 'should have _yapra_run_method named "legacy_test_plugin".' do
      @plugin._yapra_run_method.should == 'legacy_test_plugin'
    end
    
    it 'should have plugin source.' do
      @plugin.source.should == File.read(@path)
    end
    
    it 'should recieve message "legacy_test_plugin" when _yapra_run_as_legacy_plugin is called.' do
      config  = mock('config')
      data    = []
      @plugin.stub!(:legacy_test_plugin).and_return(:default_value)
      @plugin.should_receive(:legacy_test_plugin).with(config, data)
      @plugin._yapra_run_as_legacy_plugin(config, data)
    end
  end
end