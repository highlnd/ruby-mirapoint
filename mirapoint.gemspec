# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mirapoint/version"

Gem::Specification.new do |s|
  s.name        = "mirapoint"
  s.version     = Mirapoint::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mike Kennedy"]
  s.email       = ["mkennedy76@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Gem that provides an API to the Admin service on Mirapoint systems.}
  s.description = %q{This gem assists with connecting to the admind protocol on Mirapoint systems.}

  s.rubyforge_project = "mirapoint"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
