require_relative 'lib/laboratory/version'

Gem::Specification.new do |spec|
  spec.name = 'laboratory'
  spec.version = Laboratory::VERSION
  spec.authors = ['Niall Paterson']
  spec.email = ['niall@butternutbox.com']

  spec.summary = 'Laboratory: An A/B Testing and Feature Flag system for Ruby'
  spec.description = 'An A/B Testing and Feature Flag system for Ruby'
  spec.homepage = 'https://github.com/butternutbox/laboratory'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/butternutbox/laboratory'
  spec.metadata['changelog_uri'] = 'https://github.com/butternutbox/laboratory/releases'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'redis', '>= 2.1'
  spec.add_dependency 'sinatra', '>= 1.2.6'

  spec.add_development_dependency 'fakeredis', '~> 0.8'
  spec.add_development_dependency 'rack-test', '~> 1.1'
  spec.add_development_dependency 'rspec', '~> 3.8'
end
