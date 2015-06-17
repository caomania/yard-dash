# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "yard-dash/version"

Gem::Specification.new do |s|
  s.name        = 'yard-dash'
  s.version     = YardDashVersion::NUMBER
  s.author      = "Fred Appelman"
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.license     = "(c) MIT"
  s.homepage    = "http://fred.appelman.net"
  s.description = "Yard-dash generates a docset for Dash"
  s.summary     = "Generate beside the standard HTML documentation
  a docset to be used by Dash from the standard yard inline
  documentation.
  "
  s.email       = "fred@appelman.net"
  s.files       = Dir['lib/**/*.rb'] + ['README.md']
  s.has_rdoc    = false
end
