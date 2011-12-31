require 'rubygems'
require 'fileutils'
require './lib/glark'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'rbconfig'

task :default => :test

Rake::TestTask.new("test") do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = true
  t.verbose = true
end

$spec = Gem::Specification.new do |s| 
  s.name = "glark"
  s.version = "1.9.1"
  s.author = "Jeff Pace"
  s.email = "jpace@incava.org"
  s.homepage = "http://www.incava.org/projects/glark"
  s.platform = Gem::Platform::RUBY
  s.summary = "Extended searching of text files."
  s.files = FileList["{bin,doc,lib}/**/*"].to_a.delete_if { |f| f.include?('.svn') }
  s.require_path = "lib"
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = false
  s.extra_rdoc_files = ["README"]
  s.add_dependency("riel", ">= 1.0.0")
  s.bindir = 'bin'
  # s.bindir = Config::CONFIG['bindir']
  s.executables = %w{ glark }
  s.default_executable = 'glark'
end
 
Rake::GemPackageTask.new($spec) do |pkg| 
  pkg.need_zip = true 
  pkg.need_tar_gz = true 
end 

task :man do
  IO.popen("pod2man doc/glark.pod > doc/glark.man")
end
