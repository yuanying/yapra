require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'yapra/legacy_plugin/registry_factory'

describe Yapra::LegacyPlugin::RegistryFactory do
  before do
    @pipeline = double('pipeline').as_null_object
  end
  
  it 'should create advance mode registry from string "advance"' do
    factory = Yapra::LegacyPlugin::RegistryFactory.new([], 'advance')
    factory.create(@pipeline).class.should == Yapra::LegacyPlugin::AdvanceModeRegistry
  end
  
  it 'should create compatible mode registry from string "compatible"' do
    factory = Yapra::LegacyPlugin::RegistryFactory.new([], 'compatible')
    factory.create(@pipeline).class.should == Yapra::LegacyPlugin::CompatibleModeRegistry
  end
end