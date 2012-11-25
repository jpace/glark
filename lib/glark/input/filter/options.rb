#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter'
require 'glark/util/option'

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
    @optee.add field, posneg, SizeLimitFilter.new(val.to_i)
  end

  def rcfield
    'size-limit'
  end
end

class Glark::RegexpOption < Glark::Option
  def set val
    @optee.add field, posneg, cls.new(Regexp.create val)
  end

  def argtype
    :string
  end
end

module Glark::MatchOption
  def rcfield
    'match-' + field.to_s
  end

  def posneg
    :positive
  end
end

module Glark::SkipOption
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
  include Glark::MatchOption
end

class Glark::SkipExtOption < Glark::ExtOption
  include Glark::SkipOption
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
  include Glark::MatchOption

  def tags
    %w{ --basename --name --with-basename --with-name --match-name }
  end
end

class Glark::SkipNameOption < Glark::NameOption
  include Glark::SkipOption

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
end

class Glark::MatchDirNameOption < Glark::DirNameOption
  include Glark::MatchOption
end

class Glark::SkipDirNameOption < Glark::DirNameOption
  include Glark::SkipOption
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
  include Glark::MatchOption

  def tags
    %w{ --fullname --path --with-fullname --with-path --match-path }
  end
end

class Glark::SkipPathOption < Glark::PathOption
  include Glark::SkipOption

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
  include Glark::MatchOption
end

class Glark::SkipDirPathOption < Glark::DirPathOption
  include Glark::SkipOption
end
