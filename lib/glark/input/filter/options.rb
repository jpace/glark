#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter'
require 'glark/util/option'

module Glark
  class SizeLimitOption < Option
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

  class RegexpOption < Glark::Option
    def set val
      @optee.add field, posneg, cls.new(Regexp.create val)
    end

    def argtype
      :string
    end
  end

  module MatchOption
    def rcfield
      'match-' + field.to_s
    end

    def posneg
      :positive
    end
  end

  module SkipOption
    def tags
      %w{ not skip }.collect { |x| '--' + x + '-' + field.to_s }
    end

    def rcfield
      'skip-' + field.to_s
    end

    def posneg
      :negative
    end
  end

  class ExtOption < RegexpOption
    def cls
      ExtFilter
    end

    def field
      :ext
    end
  end

  class MatchExtOption < ExtOption
    include MatchOption
  end

  class SkipExtOption < ExtOption
    include SkipOption
  end

  class NameOption < RegexpOption
    def cls
      BaseNameFilter
    end

    def field
      :name
    end
  end

  class MatchNameOption < NameOption
    include MatchOption

    def tags
      %w{ --basename --name --with-basename --with-name } + super
    end
  end

  class SkipNameOption < NameOption
    include SkipOption

    def tags
      %w{ --without-basename --without-name } + super
    end
  end

  class DirNameOption < RegexpOption
    def cls
      BaseNameFilter
    end

    def field
      :dirname
    end
  end

  class MatchDirNameOption < DirNameOption
    include MatchOption
  end

  class SkipDirNameOption < DirNameOption
    include SkipOption
  end

  class PathOption < RegexpOption
    def cls
      FullNameFilter
    end

    def field
      :path
    end
  end

  class MatchPathOption < PathOption
    include MatchOption

    def tags
      %w{ --fullname --path --with-fullname --with-path } + super
    end
  end

  class SkipPathOption < PathOption
    include SkipOption

    def tags
      %w{ --without-fullname --without-path } + super
    end
  end


  class DirPathOption < RegexpOption
    def cls
      FullNameFilter
    end

    def field
      :dirpath
    end
  end

  class MatchDirPathOption < DirPathOption
    include MatchOption
  end

  class SkipDirPathOption < DirPathOption
    include SkipOption
  end
end
