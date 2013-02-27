#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

module Glark
  module IO
    # Lines of input. Handles non-default ("\n") record separator.
    class Lines
      def initialize fname
        @fname = fname
        @count = nil
      end
      
      # Returns the given line for this file. For this method, a line ends with a
      # CR, as opposed to the "lines" method, which ends with $/.
      def get_line lnum
        get_lines[lnum]
      end

      # this reads the entire file and returns the number of lines
      def count
        unless @count
          @count = ::IO::readlines(@fname).size
        end
        @count
      end
    end

    class LinesCR < Lines
      def initialize fname, io
        super fname
        @lines = Array.new
        @io = io
      end

      # Returns the lines for this file, separated by end of line sequences.
      def get_lines
        return @lines
      end

      def each_line &blk
        while (line = @io.gets) && line.length > 0
          @lines << line
          blk.call line
        end
        @io.close
      end

      def get_region rnum
        # easy case: range is the range number, unless it is out of range.
        return rnum < @lines.length ? (rnum .. rnum) : nil
      end
    end

    class LinesNonCR < Lines
      # cross-platform end of line:   DOS  UNIX  MAC
      ANY_END_OF_LINE = Regexp.new '(?:\r\n|\n|\r)'
      
      def initialize fname, io
        super fname
        @extracted = nil
        @regions = nil
        @lines = ::IO::readlines fname
      end

      def each_line &blk
        @lines.each do |line|
          blk.call line
        end
      end
      
      # Returns the lines for this file, separated by end of line sequences.
      def get_lines
        @extracted ||= create_extracted
      end
      
      # returns the region/range that is represented by the region number
      def get_region rnum
        @regions ||= create_regions
        @regions[rnum]
      end

      private
      def create_extracted
        # This is much easier. Just resplit the whole thing at end of line
        # sequences.
        
        eoline = "\n"           # should be OS-dependent
        reallines = @lines.join("").split ANY_END_OF_LINE

        # "\n" after all but the last line
        @extracted = (0 ... (reallines.length - 1)).collect { |lnum| reallines[lnum] + eoline }
        @extracted << reallines[-1]

        @extracted
      end

      def create_regions
        @regions = []           # keys = region number; values = range of lines

        lstart = 0
        @lines.each do |line|
          lend = lstart
          line.scan(ANY_END_OF_LINE).each do |cr|
            lend += 1
          end

          @regions << ::Range.new(lstart, lend - 1)

          lstart = lend
        end
        @regions
      end
    end
  end
end
