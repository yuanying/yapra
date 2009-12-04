$:.unshift('lib')
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'rake/contrib/sshpublisher'
require 'fileutils'
require 'yapra/version'
include FileUtils
NAME              = "yapra"
AUTHOR            = "yuanying"
EMAIL             = "yuanying at fraction dot jp"
DESCRIPTION       = "Yet another pragger implementation."
RUBYFORGE_PROJECT = "yapra"
HOMEPATH          = "http://#{RUBYFORGE_PROJECT}.rubyforge.org"
BIN_FILES         = %w( yapra )
VERS              = Yapra::VERSION::STRING

REV = File.read(".svn/entries")[/committed-rev="(d+)"/, 1] rescue nil
CLEAN.include ['**/.*.sw?', '*.gem', '.config' ,'pkg']
RDOC_OPTS = [
  '--title', "#{NAME} documentation",
  "--charset", "utf-8",
  "--opname", "index.html",
  "--line-numbers",
  "--main", "README.mdown",
  "--inline-source",
]

Dir['tasks/**/*.rake'].each { |rake| load rake }

task :default => [:spec]
task :package => [:clean]

spec = Gem::Specification.new do |s|
  s.name              = NAME
  s.version           = VERS
  s.platform          = Gem::Platform::RUBY
  s.has_rdoc          = true
  s.extra_rdoc_files  = ["README.mdown", "ChangeLog"]
  s.rdoc_options     += RDOC_OPTS + ['--exclude', '^(examples|extras)/']
  s.summary           = DESCRIPTION
  s.description       = DESCRIPTION
  s.author            = AUTHOR
  s.email             = EMAIL
  s.homepage          = HOMEPATH
  s.executables       = BIN_FILES
  s.rubyforge_project = RUBYFORGE_PROJECT
  s.bindir            = "bin"
  s.require_paths     << "lib-plugins"
  s.autorequire       = ""
  s.test_files        = Dir["test/test_*.rb"]

  s.add_dependency('mechanize', '>=0.7.6')
  #s.required_ruby_version = '>= 1.8.2'

  s.files = %w(README.mdown ChangeLog Rakefile LICENCE) +
    Dir.glob("{bin,doc,fixtures,legacy_plugins,lib,lib-plugins,plugins,spec,tasks,website,script}/**/*") + 
    # Dir.glob("ext/**/*.{h,c,rb}") +
    # Dir.glob("examples/**/*.rb") +
    # Dir.glob("tools/*.rb")

  s.extensions = FileList["ext/**/extconf.rb"].to_a
end

Rake::GemPackageTask.new(spec) do |p|
  p.need_tar = true
  p.gem_spec = spec
end

task :install do
  name = "#{NAME}-#{VERS}.gem"
  sh %{rake package}
  sh %{sudo gem install pkg/#{name}}
end

task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end


Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'html'
  rdoc.options += RDOC_OPTS
  rdoc.template = "resh"
  #rdoc.template = "#{ENV['template']}.rb" if ENV['template']
  if ENV['DOC_FILES']
    rdoc.rdoc_files.include(ENV['DOC_FILES'].split(/,\s*/))
  else
    rdoc.rdoc_files.include('README', 'ChangeLog')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.rdoc_files.include('ext/**/*.c')
  end
end

desc "Publish to RubyForge"
task :rubyforge => [:rdoc, :package] do
  require 'rubyforge'
  Rake::RubyForgePublisher.new(RUBYFORGE_PROJECT, 'yuanying').upload
end

desc 'Package and upload the release to gemcutter.'
task :release => [:clean, :package] do |t|
  v = ENV["VERSION"] or abort "Must supply VERSION=x.y.z"
  abort "Versions don't match #{v} vs #{VERS}" unless v == VERS
  pkg = "pkg/#{NAME}-#{VERS}"

  files = [
    "#{pkg}.tgz",
    "#{pkg}.gem"
  ].compact

  puts "Releasing #{NAME} v. #{VERS}"
  sh %{gem push #{pkg}.gem}
end
