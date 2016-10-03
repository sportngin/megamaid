# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','megamaid','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'megamaid'
  s.version = Megamaid::VERSION
  s.author = 'Matt Krieger'
  s.email = 'platform-ops@sportsengine.com'
  s.homepage = 'https://www.sportsengine.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A suite of tools for cleaning up the mess you made of your AWS environment.'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','megamaid.rdoc']
  s.rdoc_options << '--title' << 'megamaid' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'megamaid'

  s.add_dependency 'aws-sdk', '~> 2.0.0'
  s.add_dependency 'httparty', '~> 0.11.0'
  s.add_dependency 'hashie', '~> 3.4.0'
  s.add_dependency 'highline'


  s.add_development_dependency('rake')


  s.add_runtime_dependency('gli','2.14.0')
end
