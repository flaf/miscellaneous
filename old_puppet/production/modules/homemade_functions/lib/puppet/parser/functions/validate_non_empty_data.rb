module Puppet::Parser::Functions
  newfunction(:validate_non_empty_data, :doc => <<-EOS
This function takes at least one argument. You can provide as
many arguments as you want. The function raises an error if
one of the arguments is empty or undefined (true or false are
considered non empty).
    EOS
  ) do |args|

    unless(args.size > 0)
      raise(Puppet::ParseError, 'validate_non_empty_data(): needs to ' +
            "at least one argument")
    end

    args.each_with_index do |value, i|
      if value == true or value == false
        # true/false are ok.
        return
      end
      if value == nil or value.empty?()
        raise(Puppet::ParseError, 'validate_non_empty_data(): the ' +
              "argument at index #{i.to_s()} is undefined or empty" )
      end
    end

  end
end


