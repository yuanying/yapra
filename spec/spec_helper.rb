begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$fixture_dir = File.join(File.dirname(__FILE__), '..', 'fixtures') unless $fixture_dir

$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/../lib-plugins')
require 'yapra'
