begin
  require 'rspec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'rspec'
end

$fixture_dir = File.join(File.dirname(__FILE__), '..', 'fixtures') unless $fixture_dir

$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/../lib-plugins')
require 'yapra'
