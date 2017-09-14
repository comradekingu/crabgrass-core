class String
  ##
  ## NOTE: you will want to translit non-ascii slugs to ascii.
  ## resist this impulse. nameized strings must remain utf8.
  ##
  ## NOTE2: iconv is total evil. however this seems really cool:
  ## http://github.com/svenfuchs/stringex/tree/master
  ##

  def nameize
    str = dup
    str.gsub!(/&(\w{2,6}?|#[0-9A-Fa-f]{2,6});/, '') # remove html entitities
    str.gsub!(/[^[[:word:]]\+]+/, ' ') # all non-word chars to spaces
    str.strip!            # ohh la la
    str.downcase!         # upper case characters in urls are confusing
    str.gsub!(/\ +/, '-') # spaces to dashes, preferred separator char everywhere
    str[0..49]
  end

  def denameize
    tr('-', ' ')
  end

  # returns false if any char is detected that is not allowed in
  # 'nameized' strings
  def nameized?
    self == nameize
  end

  def shell_escape
    if empty?
      "''"
    elsif self =~ /\A[0-9A-Za-z+_-]+\z/
      self
    else
      result = ''
      scan(/('+)|[^']+/) do
        result << if Regexp.last_match(1)
                    %q(\') * Regexp.last_match(1).length
                  else
                    %('#{$&}')
                  end
      end
      result
    end
  end

  #   str.index_split(pattern) => anArray
  #
  # Split the string for each match of the regular expression _pattern_.
  # Unlike String#split, this method does not remove the _pattern_ from the input string.
  # #index_split slices the string on the starting index of each _pattern_ match.
  #
  # Returns +str+ if the pattern does not match
  # NOTE: There were discussions to make something similar to this part of ruby core
  # check back when Ruby 2.0 is around
  def index_split(pattern)
    indexes = [0]
    last_index = 0

    # find every location where pattern matches
    while index = self.index(pattern, last_index + 1)
      indexes << index
      last_index = index
    end

    # find substrings
    substrings = []

    indexes.each_with_index do |str_index, i|
      start_offset = str_index

      end_offset = indexes[i + 1]
      end_offset ||= length

      substrings << slice(start_offset...end_offset)
    end

    substrings
  end

  # returns true if the string is an integer
  def is_integer?
    self =~ /^-?\d+$/
  end
end
