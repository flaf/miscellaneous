module Puppet::Parser::Functions
  newfunction(:str2erb, :type => :rvalue, :doc => <<-EOS
This function replaces in a string each substring like
"@xxxx" by "<%= @xxxx %>" (see the code to have the exact
regexp). This function can take 2 arguments. The first
argument is the string to handle. This argument is mandatory
and the string mustn't be empty. The second argument is
optional and must be a boolean. If true, the function checks
each variable and raises an error if one of them is not
mapped to a non empty string. If false, the function makes
no check. The default value of this second parameter is true
(ie it checks variables).

Example:

  $erb_str = str2erb("@datacenter-tagfoo")
  $tag     = inline_template($erb_str)

    EOS
  ) do |args|

    unless(args.size == 1 or args.size == 2)
      raise(Puppet::ParseError, 'str2erb(): wrong number ' +
            "of arguments given (#{args.size} instead of 1 or 2)")
    end

    str = args[0]

    unless str.is_a?(String) and not str.empty?()
      raise(Puppet::ParseError, 'str2erb(): the first argument must be a ' +
            'non empty string')
    end

    # By default, the function checks the variables.
    check_vars = true
    if args.size == 2
      check_vars = args[1]
      unless(check_vars.is_a?(TrueClass) or check_vars.is_a?(FalseClass))
        raise(Puppet::ParseError, 'str2erb(): the optional second argument ' +
              '(check_vars) must be a boolean')
      end
    end

    # Regex of a variable name (for instance @var2_foo).
    # The captured group \1 will be the name without the @ character.
    regex = /@([a-zA-Z_][0-9a-zA-Z_]*)/

    if check_vars
      str.gsub(regex) do |var|
        var_expanded = lookupvar(var.gsub('@', ''))
        unless var_expanded.is_a?(String) and not var_expanded.empty?()
          raise(Puppet::ParseError, 'str2erb(): in the string argument ' +
                "`#{str}`, the variable `#{var}` must be a non empty " +
                'string after substitution')
        end
      end
    end

    erb = str.gsub(regex, '<%= @\1 %>')

    # Return the erb string.
    erb

  end
end


