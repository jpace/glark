#!/usr/bin/ruby -w
# -*- ruby -*-

require "rbconfig"
require "ftools"

include Config

prefix  = ENV['prefix'] || '/usr'
version = CONFIG["MAJOR"] + "." + CONFIG["MINOR"]
libdest = prefix + CONFIG["sitedir"].sub(Regexp.new(/^\/usr/), "") + File::SEPARATOR + version + File::SEPARATOR + "glark"
bindir  = prefix + "/bin"
mandir  = prefix + "/share/man/man1"

libfiles = %w{ apphelp env glark log opt regexp texthighlight }

# puts "libdest: #{libdest}"

if ARGV[0] == "uninstall"
  libfiles.each do |libfile|
    File.safe_unlink(libdest + File::SEPARATOR + libfile + ".rb")
  end
  Dir.rmdir(libdest)
  File.safe_unlink(bindir + File::SEPARATOR + "bin/glark")
  File.safe_unlink(mandir + File::SEPARATOR + "glark.1")
else
  File.makedirs(libdest)
  File.makedirs(bindir)
  File.makedirs(mandir)

  libfiles.each do |libfile|
    puts "File.install(\"lib/glark/#{libfile}.rb\", #{libdest})"
    File.install("lib/glark/" + libfile + ".rb", libdest)
  end

  puts "File.install(\"bin/glark\", #{bindir})"
  File.install("bin/glark", bindir)

  puts "File.install(\"glark.1\", #{mandir})"
  File.install("glark.1", mandir)
end
