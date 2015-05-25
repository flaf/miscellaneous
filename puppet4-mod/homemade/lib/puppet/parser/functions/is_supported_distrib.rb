module Puppet::Parser::Functions
  newfunction(:is_supported_distrib, :doc => <<-EOS
Example of usage:

  class foo {
    is_supported_distrib(['truty', 'jessie'], $title)
    # The rest of the class.
    ...
  }

The function will raise an errror if the distribution of
the current node is not present in the array of the first
argument.
    EOS
  ) do |args|

    num_args      = 2
    function_name = 'is_supported_distrib'

    unless(args.size == num_args)
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): wrong number of arguments,
          |#{args.size} argument(s) given instead of #{num_args}.
          EOS
      raise(Puppet::ParseError, msg)
    end

    # The argument must be an non empty array of non empty strings.
    supp_distribs   = args[0]
    class_name      = args[1]
    current_distrib = lookupvar('lsbdistcodename')

    unless(supp_distribs.is_a?(Array) and not supp_distribs.empty?)
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the first argument must be a non empty
          |array of non empty strings.
          EOS
      raise(Puppet::ParseError, msg)
    end

    unless(class_name.is_a?(String) and not class_name.empty?)
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the second argument must be a non empty
          |string.
          EOS
      raise(Puppet::ParseError, msg)
    end

    supp_distribs.each do |distrib|
      unless(distrib.is_a?(String) and not distrib.empty?)
        msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |#{function_name}(): the first argument must be a non empty
            |array of non empty strings.
            EOS
        raise(Puppet::ParseError, msg)
      end
    end

    unless(supp_distribs.include?(current_distrib))
      supp_distribs_str = supp_distribs.join(', ')
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |Sorry, the class #{class_name} has never been tested on
          |#{current_distrib}. Supported distribution(s): #{supp_distribs_str}.
          EOS
      raise(Puppet::ParseError, msg)
    end

  end
end


