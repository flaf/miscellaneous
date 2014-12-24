module Puppet::Parser::Functions
  newfunction(:str2hash, :type => :rvalue, :doc => <<-EOS
This function takes one argument which must be a non empty
string and converts it (if possible) to a hash.

Example:

  $str   = '{"a" => 1, "b" => 2 }'
  $hash  = str2hash($str)

    EOS
  ) do |args|

    unless(args.size == 1)
      raise(Puppet::ParseError, 'str2hash(): wrong number ' +
            "of arguments given (#{args.size} instead of 1)")
    end

    str = args[0].strip

    unless str.is_a?(String) and not str.empty?()
      raise(Puppet::ParseError, 'str2hash(): the argument must be a ' +
            'non empty string')
    end

    message = "str2hash(): impossible to convert the string `#{str}` " +
              "to a hash"

    begin
      hash = eval(str)
    rescue
      raise(Puppet::ParseError, message)
    end

    unless hash.is_a?(Hash)
      raise(Puppet::ParseError, message)
    end

    # Return the hash.
    hash

  end
end


