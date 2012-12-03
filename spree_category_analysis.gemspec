# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_category_analysis'
  s.version     = '1.2.0'
  s.summary     = 'Spree category analysis'
  s.description = 'Spree category analysis'
  s.required_ruby_version = '>= 1.8.7'

  s.author    = 'ThoughtWorks'
  s.email     = 'you@example.com'
  s.homepage  = 'https://github.com/dvguruprasad/spree_analytics'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 1.2.0'

  s.add_development_dependency 'factory_girl', '~> 2.6.4'
  s.add_development_dependency 'rspec-rails',  '~> 2.9'
  s.add_development_dependency 'mysql2'
end

