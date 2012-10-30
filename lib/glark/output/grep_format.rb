#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/format'
require 'glark/output/matching_format'

# -------------------------------------------------------
# Grep output format
# -------------------------------------------------------

# This matches grep, mostly. It is for running within emacs, thus,
# it does not support context or highlighting.
class GrepOutputFormat < MatchingOutputFormat
  # prints the line, and adjusts for the fact that in our world, lines are
  # 0-indexed, whereas they are displayed as if 1-indexed.
  def print_line lnum, ch = nil
    info "lnum: #{lnum}"
    ln = get_line_to_print lnum
    info "ln: #{ln}"
    next unless ln

    print_file_name
    if @show_line_numbers
      @out.printf "%d: ", lnum + 1
    end
    
    @out.print ln
  end

  def print_file_name
    if @show_file_name
      @out.print displayed_name, ":"
    end
  end

  def add_match startline, endline
    super 
    # even with multi-line matches (--and expressions), we'll display
    # only the first matching line, not the range between the matches.
    set_status startline, startline
  end
end
