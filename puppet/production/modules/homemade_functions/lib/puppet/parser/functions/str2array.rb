module Puppet::Parser::Functions
  newfunction(:str2array, :type => :rvalue, :doc => <<-EOS
This function takes one argument which must be a non empty
string and converts it (if possible) to an array.

Example:

  $str   = '[1, 2, "foo"]'
  $array = str2array($str)

    EOS
  ) do |args|

    unless(args.size == 1)
      raise(Puppet::ParseError, 'str2array(): wrong number ' +
            "of arguments given (#{args.size} instead of 1)")
    end

    str = args[0].strip

    unless str.is_a?(String) and not str.empty?()
      raise(Puppet::ParseError, 'str2array(): the argument must be a ' +
            'non empty string')
    end

    message = "str2array(): impossible to convert the string `#{str}` " +
              "to an array"

    begin
      array = eval(str)
    rescue Exception => exc
      raise(Puppet::ParseError, message)
    end

    unless array.is_a?(Array)
      raise(Puppet::ParseError, message)
    end

    # Return the array.
    array

  end
end


