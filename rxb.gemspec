lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "Rxb/version"

Gem::Specification.new do |spec|
  spec.name          = "rxb"
  spec.version       = Rxb::VERSION
  spec.authors       = ["Mars"]
  spec.email         = ["zoro.fmt@gmail.com"]
  spec.summary       = "Ruby + Xat + Bot = Rxb"
  spec.homepage      = "https://github.com/xety/rxb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"
  spec.add_dependency "bundler"
  spec.add_dependency "nori"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "2.14.1"
end
