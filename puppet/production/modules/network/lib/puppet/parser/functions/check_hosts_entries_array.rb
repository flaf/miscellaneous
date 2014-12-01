module Puppet::Parser::Functions
  newfunction(:check_hosts_entries_array, :doc => <<-EOS
Checks if the argument is:

* An empty array [].
* An array where each element is an array of at least 
  2 non empty strings of this form:

  [ '<ip address>', '<domain_name1>', '<domain_name2>', ... ]

If one (at least) of these conditions are not respected, the
function raises an error.
    EOS
  ) do |args|

    Puppet::Parser::Functions.function('is_ip_address')
    Puppet::Parser::Functions.function('is_domain_name')

    num_args = 1
    unless(args.size == num_args)
      raise(Puppet::ParseError, 'check_hosts_entries_array(): wrong number ' +
            "of arguments given (#{args.size} instead of #{num_args})")
    end

    array  = args[0]

    unless array.is_a?(Array)
      raise(Puppet::ParseError, 'check_hosts_entries_array(): the ' +
            '`hosts_entries` parameter must be an array')
    end

    array.each do |entry|
      unless entry.is_a?(Array) and entry.length > 1
        raise(Puppet::ParseError, 'check_hosts_entries_array(): the ' +
              '`hosts_entries` parameter must be an array where each ' +
              'element is an array of 2 strings at least')
      end

      c = 0
      entry.each do |val|

        unless val.is_a?(String)
          raise(Puppet::ParseError, 'check_hosts_entries_array(): the ' +
                '`hosts_entries` parameter contains an array where one ' +
                'element is not a string')
        end

        if c == 0
          unless function_is_ip_address([val])
            raise(Puppet::ParseError, 'check_hosts_entries_array(): the ' +
                  '`hosts_entries` parameter contains an array where the ' +
                  'first element is not a IP address')
          end
          c += 1
        else
          unless function_is_domain_name([val])
            raise(Puppet::ParseError, 'check_hosts_entries_array(): the ' +
                  '`hosts_entries` parameter contains an array where an ' +
                  'element is not a domain name')
          end
        end

      end

    end

  end
end


