module Puppet::Parser::Functions
  newfunction(:ljust, :type => :rvalue, :doc => <<-EOS
Examples of usage

  $v = ljust('hello', 10, ' ') # will return 'hello     '
  $v = ljust('hello', 4, ' ')  # will return 'hello'

This function is just a wrapper of the `ljust()` ruby
method. `ljust($str, $column, $padstr)` is just equivalent
to `str.ljust(column, padstr)` in ruby code.
    EOS
  ) do |args|

    num_args      = 3
    function_name = 'ljust'

    unless(args.size == num_args)
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): wrong number of arguments,
          |#{args.size} argument(s) given instead of #{num_args}.
          EOS
      raise(Puppet::ParseError, msg)
    end

    str    = args[0]
    column = args[1]
    padstr = args[2]

    unless (str.is_a?(String) and not str.empty?)
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the first argument must be a non empty
          |string.
          EOS
      raise(Puppet::ParseError, msg)
    end

    unless (column.is_a?(Integer) and column > 0)
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the second argument must be a
          |strictly positive integer.
          EOS
      raise(Puppet::ParseError, msg)
    end

    unless(padstr.is_a?(String) and not padstr.empty?)
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the third argument must be a non empty
          |string.
          EOS
      raise(Puppet::ParseError, msg)
    end

    str.ljust(column, padstr)

  end
end


