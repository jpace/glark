#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/lines'
require 'glark/output/glark_format'

# -------------------------------------------------------
# Glark output format
# -------------------------------------------------------

class GlarkLines < Lines
  include Glark::Format

  def initialize file, opts
    super
    @has_context = opts.after != 0 || opts.before != 0    
  end

  def write_matching from, to
    show_file_header
    super
  end

  def write_nonmatching from, to
    show_file_header
    super
  end

  def add_match startline, endline
    super
    set_status startline, endline
  end
end
