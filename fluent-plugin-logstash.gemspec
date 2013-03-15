# -*- encoding: utf-8 -*-
require 'rake'

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-logstash"
  gem.version       = "0.1.0"
  gem.summary       = %q{Fluentd plugin for formatting log record as a logstash event}
  gem.description   = gem.summary
  gem.authors       = ["Marica Odagaki"]

  gem.files         = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'test/*', 'test/**/*'].to_a
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "fluentd"
  gem.add_runtime_dependency "fluentd"
end
