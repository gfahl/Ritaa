lib = File.expand_path("../lib/", __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
require "ritaa/version"

Gem::Specification.new do |s|
  s.name        = "ritaa"
  s.version     = Ritaa::VERSION
  s.summary     = "Tool for creating images from ascii diagrams"
  s.description = "Lovely Ritaa, diagramming aid, where would I be without you?"
  s.homepage    = "https://github.com/gfahl/Ritaa"
  s.authors     = ["Gustav Fahl"]
  s.email       = "gfahl67@yahoo.se"
  s.license     = 'MIT'
  s.executables = ["ritaa"]
  s.files       = Dir["README.md", "bin/*", "lib/**/*.rb"]
end
