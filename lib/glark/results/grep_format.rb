#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/results/format'

# -------------------------------------------------------
# Grep output format
# -------------------------------------------------------

# This matches grep, mostly. It is for running within emacs, thus,
# it does not support context or highlighting.
class GrepOutputFormat < OutputFormat
  # prints the line, and adjusts for the fact that in our world, lines are
  # 0-indexed, whereas they are displayed as if 1-indexed.
  def print_line lnum, ch = nil
    info "lnum: #{lnum}"
    ln = get_line_to_print lnum
    info "ln: #{ln}"
    next unless ln

    print_file_name
    if show_line_numbers
      @out.printf "%d: ".on_red, lnum + 1
    end
    
    @out.print ln
  end

  def print_file_name
    if @show_file_name
      @out.print displayed_name, ":"
    end
  end


  def mark_as_match startline, endline
    super 

    # even with multi-line matches (--and expressions), we'll display
    # only the first matching line, not the range between the matches.
    endline = startline
    st = [0, startline - @before].max
    @stati.set_match startline - @before, startline, endline, endline + @after
  end
end
