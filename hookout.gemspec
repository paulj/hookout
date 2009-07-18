# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hookout}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Jones"]
  s.date = %q{2009-07-18}
  s.default_executable = %q{hookout}
  s.description = %q{Hookout allows you to expose your web hook applications to the web via Reverse HTTP.}
  s.email = %q{pauljones23@gmail.com}
  s.executables = ["hookout"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["Rakefile", "README.rdoc", "VERSION.yml", "bin/hookout", "lib/hookout", "lib/hookout/rack_adapter.rb", "lib/hookout/reversehttp_connector.rb", "lib/hookout/runner.rb", "lib/hookout/thin_backend.rb", "lib/hookout.rb", "lib/rack", "lib/rack/handler", "lib/rack/handler/hookout.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/paulj/hookout/}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Hookout Reverse HTTP Connector}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
