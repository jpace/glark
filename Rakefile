require 'rubygems'
require 'fileutils'
require './lib/glark'
require 'rake/testtask'
require 'rubygems/package_task'
require 'rbconfig'

task :default => :test

Rake::TestTask.new('test') do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = true
  t.verbose = true
end

desc "generate man page"
task :generate_manpage do 
  sh "ronn -r --pipe README.md > doc/glark.1"
end

spec = Gem::Specification.new do |s| 
  s.name               = "glark"
  s.version            = "1.9.1"
  s.author             = "Jeff Pace"
  s.email              = "jeugenepace@gmail.com"
  s.homepage           = "http://www.incava.org/projects/glark"
  s.platform           = Gem::Platform::RUBY
  s.summary            = "Extended searching of text files."
  s.files              = FileList["{bin,doc,lib}/**/*"].to_a
  s.require_path       = "lib"
  s.test_files         = FileList["{test}/**/*.rb"].to_a
  s.has_rdoc           = false
  # s.extra_rdoc_files   = [""]
  s.add_dependency("riel", ">= 1.1.10")
  s.bindir             = 'bin'
  # s.bindir = Config::CONFIG['bindir']
  s.executables        = %w{ glark }
  s.default_executable = 'glark'
end
 
Gem::PackageTask.new(spec) do |pkg| 
  pkg.need_zip = true 
  pkg.need_tar_gz = true 
end 
