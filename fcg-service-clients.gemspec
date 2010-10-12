# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fcg-service-clients}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Samuel O. Obukwelu"]
  s.date = %q{2010-10-12}
  s.description = %q{Clients/libraries that are used under site models to interact with FCG services}
  s.email = %q{sam@fcgmedia.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "fcg-service-clients.gemspec",
     "generators/models/model.tt",
     "lib/fcg-service-clients.rb",
     "lib/fcg_service_clients/cattr_inheritable_attrs.rb",
     "lib/fcg_service_clients/client/client.rb",
     "lib/fcg_service_clients/client/fetcher.rb",
     "lib/fcg_service_clients/client/persistence.rb",
     "lib/fcg_service_clients/models/activity.rb",
     "lib/fcg_service_clients/models/event.rb",
     "lib/fcg_service_clients/models/stat.rb",
     "lib/fcg_service_clients/models/user.rb",
     "lib/fcg_service_clients/version.rb",
     "spec/fcg-service-clients_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "tasks/models.thor"
  ]
  s.homepage = %q{http://github.com/joemocha/fcg-service-clients}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A library of clients that interact with the FCG SOA}
  s.test_files = [
    "spec/fcg-service-clients_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<fcg-service-ext>, [">= 0.0.10"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<activemodel>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<typhoeus>, [">= 0.1.31"])
      s.add_runtime_dependency(%q<yajl-ruby>, [">= 0"])
      s.add_runtime_dependency(%q<hashie>, [">= 0.4.0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<fcg-service-ext>, [">= 0.0.10"])
      s.add_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_dependency(%q<activemodel>, [">= 3.0.0"])
      s.add_dependency(%q<typhoeus>, [">= 0.1.31"])
      s.add_dependency(%q<yajl-ruby>, [">= 0"])
      s.add_dependency(%q<hashie>, [">= 0.4.0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<fcg-service-ext>, [">= 0.0.10"])
    s.add_dependency(%q<activesupport>, [">= 3.0.0"])
    s.add_dependency(%q<activemodel>, [">= 3.0.0"])
    s.add_dependency(%q<typhoeus>, [">= 0.1.31"])
    s.add_dependency(%q<yajl-ruby>, [">= 0"])
    s.add_dependency(%q<hashie>, [">= 0.4.0"])
  end
end

