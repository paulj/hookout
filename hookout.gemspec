# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hookout"
  s.version = "0.1.1"
  s.authors = ["Paul Jones"]
  
  s.required_rubygems_version = ">= 0"
  s.default_executable = %q{hookout}
  s.description = %q{Hookout allows you to expose your web hook applications to the web via Reverse HTTP.}
  s.email = %q{pauljones23@gmail.com}
  s.executables = ["hookout"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = Dir.glob("{bin,lib}/**/*") + %w(Rakefile README.rdoc VERSION.yml)
  s.has_rdoc = true
  s.homepage = %q{http://github.com/paulj/hookout/}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary = %q{Hookout Reverse HTTP Connector}

  if s.respond_to? :specification_version then
    s.specification_version = 2
  else
  end
end
