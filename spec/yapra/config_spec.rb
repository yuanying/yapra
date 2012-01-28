require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'yaml'
require 'yapra/config'

describe Yapra::Config do

  it 'should create logger from env setting' do
    config = Yapra::Config.new(YAML.load_file(File.join($fixture_dir, 'config', 'pragger_like.yml')))
    config.env.update({
      'log' => {
        'out'   => 'stderr',
        'level' => 'debug'
      }
    })
    logger = config.create_logger
    logger.should be_debug
  end

  describe 'which is initialized by pragger like config file' do
    before do
      @config = Yapra::Config.new(YAML.load_file(File.join($fixture_dir, 'config', 'pragger_like.yml')))
    end

    it 'should have empty env.' do
      @config.env.should == {}
    end

    it 'should have one pipeline command which is named "default".' do
      @config.should have(1).pipeline_commands
    end

    it 'should have pipeline command named "default"' do
      @config.pipeline_commands.should have_key('default')
    end
  end

  describe 'which is initialized by python habu like config file' do
    before do
      @habu_like_file = YAML.load_file(File.join($fixture_dir, 'config', 'habu_like.yml'))
      @config = Yapra::Config.new(@habu_like_file)
    end

    it 'should have env hash from habu_like_config_file "global" section.' do
      @config.env.should == @habu_like_file['global']
    end

    it 'should have pipeline_commands from habu_like_config_file "pipeline" section.' do
      @config.pipeline_commands.should == @habu_like_file['pipeline']
    end
  end

  describe 'which is initialized by mixed type config file' do
    before do
      @mixed_type_file = YAML.load_file(File.join($fixture_dir, 'config', 'mixed_type.yml'))
      @config = Yapra::Config.new(@mixed_type_file)
    end

    it 'should have env hash from mixed_type "global" section.' do
      @config.env.should == @mixed_type_file['global']
    end

    it 'should have one pipeline command which is named "default".' do
      @config.should have(1).pipeline_commands
    end

    it 'should have pipeline command named "default"' do
      @config.pipeline_commands.should have_key('default')
    end
  end

end
