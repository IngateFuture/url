Gem::Specification.new do |gem|
  gem.name = 'url'
  gem.version = '0.0.1'
  gem.date = '2016-09-30'
  gem.summary = 'URL'
  gem.description = 'A simple ruby url parsing library'
  gem.authors = ['https://github.com/morr', 'https://github.com/Sfolt']
  gem.email = 'takandar@gmail.com'
  gem.files = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.require_paths = ['lib']
  gem.license = 'MIT'
  # gem.homepage    = 'http://rubygems.org/gems/url'

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_dependency 'rack'
  gem.add_dependency 'simpleidn'

  gem.add_development_dependency 'byebug'
  gem.add_development_dependency 'pry-byebug'
  gem.add_development_dependency 'pry-stack_explorer'

  gem.add_development_dependency 'rb-inotify'
  gem.add_development_dependency 'rb-fsevent'
  gem.add_development_dependency 'rb-fchange'
  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'guard-bundler'
  gem.add_development_dependency 'guard-rubocop'
end
