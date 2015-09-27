$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_powergrid/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails_powergrid"
  s.version     = RailsPowergrid::VERSION
  s.authors     = ["Yacine Petitprez"]
  s.email       = ["yacine@redtonic.net"]
  s.homepage    = "https://github.com/anykeyh/rails_powergrid"
  s.summary     = "Summary coming soon."
  s.description = "Description coming soon"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4"
  s.add_dependency "react-rails", "~> 1"
  s.add_dependency "coffee-rails", "~> 4"
  s.add_dependency "sprockets-coffee-react", "~> 2"
  s.add_dependency "sass-rails", "~> 5"
  s.add_dependency "compass-rails", [">= 2", "< 3"]
  s.add_dependency "font-awesome-rails", "~> 4"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "better_errors", ">= 2.1"
  s.add_development_dependency "binding_of_caller", ">= 0.7"
  s.add_development_dependency "faker"
  s.add_development_dependency "rubyXL", ">= 0.7"
end
