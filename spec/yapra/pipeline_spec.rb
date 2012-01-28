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
    data = []
    Yapra::Plugin::Test::Test.should_receive(:new).and_return(@test_plugin)
    @test_plugin.should_receive(:run).with(data).and_return([])
    @pipeline.run([
      {
        'module' => 'Test::Test'
      }
    ], data)
  end

  it 'transfer previous plugin return object to next plugin.' do
    require 'yapra/plugin/test/test2'
    @test_plugin2  = Yapra::Plugin::Test::Test2.new
    data = []
    modified_data = [ 'modified' ]
    Yapra::Plugin::Test::Test.should_receive(:new).and_return(@test_plugin)
    @test_plugin.should_receive(:run).with(data).and_return(modified_data)
    Yapra::Plugin::Test::Test2.should_receive(:new).and_return(@test_plugin2)
    @test_plugin2.should_receive(:run).with(modified_data)
    @pipeline.run([
      {
        'module' => 'Test::Test'
      },
      {
        'module' => 'Test::Test2'
      }
    ], data)
  end

  it 'call on_error method of plugin, when Error has occured.' do
    Yapra::Plugin::Test::Test.should_receive(:new).and_return(@test_plugin)
    @test_plugin.should_receive(:on_error)
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