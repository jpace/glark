$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Glark
  PACKAGE = 'glark'
  VERSION = '1.10.0'
end

require 'glark/app/app'
