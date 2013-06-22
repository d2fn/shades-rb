Gem::Specification.new do |s|
  s.name = 'shades'
  s.version = '0.1'

  s.summary = "Get a new perspective on your data. In-memory data cubing of event data for Ruby."
  s.description = <<-EOF
    Shades computes data cubes for you from events composed of dimensions and measures.
  EOF

  s.files = `git ls-files`.split("\n")
  s.require_path = 'lib'

  s.add_development_dependency 'rake-compiler'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rdoc'

  s.has_rdoc = true
  s.rdoc_options += ['--title', 'shades', '--line-numbers', '--inline-source', '--main', 'README.md']
  s.extra_rdoc_files += ['README.md', 'COPYING', 'CHANGELOG', *Dir['lib/**/*.rb']]

  s.extensions = 'ext/mri/extconf.rb'

  s.authors = ["Dietrich Featherston"]
  s.email = "d@d2fn.com"
  s.homepage = "http://shades.rubyforge.org"
  s.rubyforge_project = "shades"
  s.license = "MIT"
end
