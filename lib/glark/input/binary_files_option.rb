#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for input.

require 'rubygems'
require 'riel/log'

class BinaryFilesOption
  include Loggable

  VALID_TYPES = [ 'text', 'without-match', 'skip', 'binary', 'list', 'decompress', 'expand' ]

  attr_reader :process_as

  def initialize
    @process_as = 'skip'
  end

  def add_as_option optdata
    re = Regexp.new '^[\'\"]?(' + VALID_TYPES.join('|') + ')[\'\"]?$'
    optdata << binary_files_option = {
      :tags => %w{ --binary-files },
      :arg  => [ :required, :regexp, re ],
      :set  => Proc.new { |md| @process_as = md[1] },
      :rc   => %w{ binary-files },
    }
  end
end
