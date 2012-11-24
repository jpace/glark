#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/criteria'
require 'glark/input/filter/filter'
require 'glark/util/optutil'

module Glark; end

class Glark::Option
  include Loggable
  
  def initialize criteria
    @criteria = criteria
  end

  def tags
    [ '--' + rcfield ]
  end  
  
  def match_rc name, values
    if name == rcfield
      info "name: #{name}".blue
      values.each do |val|
        set val
      end
      true
    end
  end

  def add_to_option_data optdata
    optdata << {
      :tags => tags,
      :arg  => [ argtype ],
      :set  => Proc.new { |pat| set pat }
    }
  end
end

class Glark::SizeLimitOption < Glark::Option
  def argtype
    :integer
  end

  def posneg
    :negative
  end

  def field
    :size
  end

  def set val
    @criteria.add field, posneg, SizeLimitFilter.new(val.to_i)
  end

  def rcfield
    'size-limit'
  end
end

class Glark::RegexpOption < Glark::Option
  def set val
    @criteria.add field, posneg, cls.new(Regexp.create val)
  end

  def argtype
    :string
  end
end

module Glark::MatchRegexpOption
  def rcfield
    'match-' + field.to_s
  end

  def posneg
    :positive
  end
end

module Glark::NotRegexpOption
  def rcfield
    'not-' + field.to_s
  end

  def posneg
    :negative
  end
end

class Glark::ExtOption < Glark::RegexpOption
  def cls
    ExtFilter
  end

  def field
    :ext
  end
end

class Glark::MatchExtOption < Glark::ExtOption
  include Glark::MatchRegexpOption
end

class Glark::NotExtOption < Glark::ExtOption
  include Glark::NotRegexpOption
end

class Glark::NameOption < Glark::RegexpOption
  def cls
    BaseNameFilter
  end

  def field
    :name
  end
end

class Glark::MatchNameOption < Glark::NameOption
  include Glark::MatchRegexpOption

  def tags
    %w{ --basename --name --with-basename --with-name --match-name }
  end
end

class Glark::NotNameOption < Glark::NameOption
  include Glark::NotRegexpOption

  def tags
    %w{ --without-basename --without-name --not-name }
  end
end

class Glark::PathOption < Glark::RegexpOption
  def cls
    FullNameFilter
  end

  def field
    :path
  end
end

class Glark::MatchPathOption < Glark::PathOption
  include Glark::MatchRegexpOption

  def tags
    %w{ --fullname --path --with-fullname --with-path --match-path }
  end
end

class Glark::NotPathOption < Glark::PathOption
  include Glark::NotRegexpOption

  def tags
    %w{ --without-fullname --without-path --not-path }
  end
end

class Glark::FileCriteria < Glark::Criteria
  include Glark::OptionUtil
  
  def initialize 
    super

    @szlimit_opt = Glark::SizeLimitOption.new self

    @match_name_opt = Glark::MatchNameOption.new self
    @not_name_opt = Glark::NotNameOption.new self

    @match_path_opt = Glark::MatchPathOption.new self
    @not_path_opt = Glark::NotPathOption.new self

    @match_ext_opt = Glark::MatchExtOption.new self
    @not_ext_opt = Glark::NotExtOption.new self
  end

  def all_options
    [
     @szlimit_opt,
     @match_name_opt,
     @not_name_opt,
     @match_ext_opt,
     @not_ext_opt,
     @match_path_opt,
     @not_path_opt,
    ]
  end

  def add_as_options optdata
    all_options.each do |opt|
      opt.add_to_option_data optdata
    end
  end

  def config_fields
    maxsize = (filter = find_by_class(:size, :negative, SizeLimitFilter)) && filter.max_size
    fields = {
      "size-limit" => maxsize
    }
  end

  def update_fields rcfields
    # process_rcfields rcfields, [ @pathname_opt ]

    rcfields.each do |name, values|
      info "name: #{name}".cyan
      all_options.each do |opt|
        opt.match_rc name, values
      end
    end
  end
end
