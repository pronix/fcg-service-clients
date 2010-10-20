require 'rubygems'
require 'rake'
require "lib/fcg_service_clients/version"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name            = "fcg-service-clients"
    gem.summary         = %Q{A library of clients that interact with the FCG SOA}
    gem.description     = %Q{Clients/libraries that are used under site models to interact with FCG services}
    gem.email           = "sam@fcgmedia.com"
    gem.homepage        = "http://github.com/joemocha/fcg-service-clients"
    gem.authors         = ["Samuel O. Obukwelu"]
    gem.add_development_dependency "rspec", ">= 1.3"
    gem.add_dependency 'fcg-core-ext', ">= 0.0.5"
    gem.add_dependency 'fcg-service-ext', ">= 0.0.10"
    gem.add_dependency 'activesupport', ">= 3.0.0"
    gem.add_dependency 'activemodel', ">= 3.0.0"
    gem.add_dependency 'typhoeus', ">= 0.1.31"
    gem.add_dependency 'bunny'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    gem.version = FCG::Client::VERSION
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "fcg-service-clients #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require "bundler/version"
# task :build do
#   system "gem build fcg-service-clients.gemspec"
# end
 
task :release => :build do
  system "gem push fcg-service-clients-#{FCG::Client::VERSION}"
end