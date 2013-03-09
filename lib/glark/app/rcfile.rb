#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pathname'

module Glark
  class RCFile
    COMMENT_RE = Regexp.new '\s*#.*'
    NAME_VALUE_RE = Regexp.new '\s*[=:]\s*'
    
    def initialize file
      @values = Array.new

      pn = file.kind_of?(Pathname) ? file : Pathname.new(file)
      
      return unless pn.exist?

      pn.each_line do |line|
        read_line line
      end
    end

    def read_line line
      line.sub! COMMENT_RE, ''
      line.chomp!
      return if line.empty?
      
      name, value = line.split NAME_VALUE_RE
      return unless name && value

      add name, value
    end

    def names
      @values.collect { |x| x[0] }
    end

    def values name
      ary = @values.assoc name
      ary && ary[1 .. -1]
    end

    def add name, value
      if ary = @values.assoc(name)
        ary << value
      else
        @values << [ name, value ]
      end
    end
  end
end
