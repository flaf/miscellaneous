module Puppet::Parser::Functions
  newfunction(:eval_ruby_code, :doc => <<-EOS
WARNING: this function is a workaround to compensate
         for the lack of features to manipulate arrays
         and hashes in manifests. If possible, it's
         better to use functions in Puppetlabs-stdlib.

This function allows to execute Ruby code. The first
argument is mandatory and is the code to execute.
It's possible to apply supplementary arguments (it's
optional) which will be reachable with the variables
$arg1, $arg2, etc. (they are global variables so you
must use $).

Examples:

  $hash_foo = { key1 => 'value1',
                key2 => 'value2',
                key3 => 'value3', }

  eval_ruby_code('
      hash_foo = $arg1
      hash_foo.each do |key, value|
        hash_foo[key] += " " + "xxx"
      end', $hash_foo)

  # And now the hash is updated.
    EOS
  ) do |args|

    unless(args.size > 0)
      raise(Puppet::ParseError, ':eval_ruby_code(): needs to ' +
            "at least one argument")
    end

    args.each_with_index do |value, i|
      i_str = i.to_s()
      eval("$arg#{i_str} = args[#{i_str}]")
    end

    eval(args[0])

  end
end


