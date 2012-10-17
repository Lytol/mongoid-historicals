require File.expand_path("../lib/mongoid/historicals/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name    = 'mongoid-historicals'
  gem.version = Mongoid::Historicals::VERSION
  gem.date    = Date.today.to_s

  gem.summary = "Record historical values any attributes in mongoid documents"
  gem.description = gem.summary

  gem.authors  = ['Brian Smith']
  gem.email    = 'bsmith@swig505.com'
  gem.homepage = 'http://github.com/Lytol/mongoid-historicals'

  gem.add_dependency('mongoid')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('minitest', [">= 2.6.2"])

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', '{bin,lib,test}/**/*', 'README*', 'LICENSE*']
end
