require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'yapra/pipeline'

describe Yapra::Pipeline do
  before do
    require 'yapra/plugin/test/test'
    @pipeline     = Yapra::Pipeline.new('spec test')
    @test_plugin  = Yapra::Plugin::Test::Test.new
  end
  
  it 'execute pipeline from commands.' do
    @pipeline.run([
      {
        'module' => 'Test::Test'
      }
    ])
  end
  
  it 'call run method of plugin, when pipeline is running.' do
    Yapra::Plugin::Test::Test.should_receive(:new).and_return(@test_plugin)
    @test_plugin.should_receive(:run).and_return([])
    @pipeline.run([
      {
        'module' => 'Test::Test'
      }
    ])
  end
  
  it 'call on_error method of plugin, when Error has occured.' do
    Yapra::Plugin::Test::Test.should_receive(:new).and_return(@test_plugin)
    @test_plugin.should_receive(:on_error).and_return(nil)
    lambda {
      @pipeline.run([
        {
          'module' => 'Test::Test'
        },
        {
          'module' => 'Test::RaiseError'
        }
      ])
    }.should raise_error
  end
end