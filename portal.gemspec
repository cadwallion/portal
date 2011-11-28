# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','portal_version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'portal'
  s.version = Portal::VERSION
  s.author = 'Andrew Nordman'
  s.email = 'cadwallion@gmail.com'
  s.homepage = 'http://your.website.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'script for managing SSH configurations'
# Add your other files here if you make them
  s.files = %w(
bin/portal
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','portal.rdoc']
  s.rdoc_options << '--title' << 'portal' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'portal'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('rspec')
end
