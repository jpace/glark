require 'rubygems'
require 'fileutils'
require 'rake/testtask'
require 'rubygems/package_task'

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
  sh "ronn -r --pipe README.md > man/glark.1"
end

spec = Gem::Specification.new do |s| 
  s.name               = "glark"
  s.version            = "1.10.2"
  s.author             = "Jeff Pace"
  s.email              = "jeugenepace@gmail.com"

  s.homepage           = "http://www.incava.org/projects/glark"
  s.platform           = Gem::Platform::RUBY
  s.summary            = "Extended searching of text files."
  s.description        = <<-EODESC
Glark searches files for regular expressions, extending grep by matching complex
expressions ("and", "or", and "xor"), extracting and searching within compressed
files, and excluding .svn and .git subdirectories by default. Different projects
can have their own Glark configuration.
EODESC
  s.files              = FileList["{lib,man}/**/*"].to_a + FileList["bin/glark"].to_a
  s.require_path       = "lib"
  s.test_files         = FileList["{test}/**/*.rb"].to_a
  s.has_rdoc           = false
  s.bindir             = 'bin'
  s.executables        = %w{ glark }
  s.default_executable = 'glark'
  
  s.add_dependency("riel", ">= 1.1.16")
  s.add_dependency("rainbow", ">= 1.1.4")
end
 
Gem::PackageTask.new(spec) do |pkg| 
  pkg.need_zip = true 
  pkg.need_tar_gz = true 
end 
