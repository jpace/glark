#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

class Glark::AppSpec
  attr_reader :local_config_files
  
  attr_reader :input_spec
  attr_reader :match_spec
  attr_reader :output_spec
  
  def initialize input_spec, match_spec, output_spec
    @input_spec = input_spec
    @match_spec = match_spec
    @output_spec = output_spec
    @local_config_files = false      # use local .glarkrc files    
  end
end
