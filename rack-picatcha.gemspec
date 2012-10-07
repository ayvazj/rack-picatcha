Gem::Specification.new do |s|
  s.name = %q{rack-picatcha}
  s.version = "0.1.0"
  s.required_rubygems_version = ">=1.3.6"
  s.authors = ["James Ayvaz"]
  s.date = %q{2012-10-04}
  s.description = %q{Rack middleware verification using Picatcha API.}
  s.email = %q{james.ayvaz@gmail.com}
  s.extra_rdoc_files = ["LICENSE", "README.md"]
  s.files = %w{.gitignore LICENSE README.md Rakefile rack-picatcha.gemspec} + Dir.glob("{lib,test}/**/*")
  s.homepage = %q{http://github.com/ayvazj/rack-picatcha}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Rack middleware for Picatcha}
  s.test_files = Dir.glob("test/**/*")
  s.add_runtime_dependency "json", ">= 0"
  s.add_development_dependency "rake",      "~> 0.9.2"
  s.add_development_dependency "riot",      "~> 0.12.3"
  s.add_development_dependency "rack-test", "~> 0.5.7"
  s.add_development_dependency "fakeweb",   "~> 1.3.0"
  s.add_development_dependency "rr",        "~> 1.0.2"
end
