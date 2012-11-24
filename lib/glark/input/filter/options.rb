#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter'

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
    info "field: #{field}".cyan
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

class Glark::DirNameOption < Glark::RegexpOption
  def cls
    BaseNameFilter
  end

  def field
    :dirname
  end

  def rcfield
    :dirname
  end
end

class Glark::MatchDirNameOption < Glark::DirNameOption
  include Glark::MatchRegexpOption
end

class Glark::NotDirNameOption < Glark::DirNameOption
  include Glark::NotRegexpOption
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


class Glark::DirPathOption < Glark::RegexpOption
  def cls
    FullNameFilter
  end

  def field
    :dirpath
  end
end

class Glark::MatchDirPathOption < Glark::DirPathOption
  include Glark::MatchRegexpOption

  def rcfield
    'match-dirpath'
  end
end

class Glark::NotDirPathOption < Glark::DirPathOption
  include Glark::NotRegexpOption

  def rcfield
    'not-dirpath'
  end
end
