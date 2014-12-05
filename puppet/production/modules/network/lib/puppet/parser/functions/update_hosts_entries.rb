#TODO: docstring outdated
module Puppet::Parser::Functions
  newfunction(:update_hosts_entries, :type => :rvalue, :doc => <<-EOS
Checks if the argument is:

* An hash (can be empty).
* Each value of this hash is an array of 2 elements
  at least and each element is a non empty string.
* Each value has this form:

  [ '<ip address>', '<domain_name1>', '<domain_name2>', ... ]

If one (at least) of these conditions are not respected, the
function raises an error.
    EOS
  ) do |args|

    Puppet::Parser::Functions.function('is_ip_address')
    Puppet::Parser::Functions.function('is_domain_name')

    num_args = 1
    unless(args.size == num_args)
      raise(Puppet::ParseError, 'update_hosts_entries(): wrong number ' +
            "of arguments given (#{args.size} instead of #{num_args})")
    end

    # The goal is to fill hosts_hash.
    hosts_entries  = args[0]
    hosts_hash = {}
    current_addr = ''

    unless hosts_entries.is_a?(Hash)
      raise(Puppet::ParseError, 'update_hosts_entries(): the ' +
            '`hosts_entries` parameter must be a hash')
    end

    hosts_entries.each do |name, entry|
      unless entry.is_a?(Array) and entry.length > 1
        raise(Puppet::ParseError, 'update_hosts_entries(): in the ' +
              "`hosts_entries` parameter, the `#{name}` entry is not " +
              'an array of 2 elements at least')
      end

      entry.each_with_index do |value, index|

        unless value.is_a?(String) and not value.empty?()
          raise(Puppet::ParseError, 'update_hosts_entries(): in the ' +
                "`hosts_entries` parameter, the `#{name}` entry contains an " +
                'array where one element is not a non empty string')
        end

        # Update entry if a value is a variable as @my_var.
        value = value.strip()
        if value =~ /^@[a-z0-9_]+$/
          value = lookupvar(value.gsub('@', ''))
          unless value.is_a?(String) and not value.empty?()
            raise(Puppet::ParseError, 'update_hosts_entries(): in the ' +
                  '`hosts_entries` parameter, there is a problem of ' +
                  "variable substitution in the `#{name}` entry")
          end
        end

        if index == 0
          unless function_is_ip_address([value])
            raise(Puppet::ParseError, 'update_hosts_entries(): in the ' +
                  "`hosts_entries` parameter, the `#{name}` entry has its " +
                  'first element which is not a IP address')
          end
          current_addr = value
          if not hosts_hash.has_key?(current_addr)
            hosts_hash[current_addr] = Array.new
          end
        else
          unless function_is_domain_name([value])
            raise(Puppet::ParseError, 'update_hosts_entries(): in the ' +
                  "`hosts_entries` parameter, the `#{name}` entry has one " +
                  'element which is not a domain name')
          end
          add = true
          hosts_hash.each do |addr, hostnames|
            if hostnames.include?(value)
              if addr == current_addr
                # "value" already exists with the same address.
                # We do nothing.
                add = false
              else
                # "value" already exists with a different address.
                raise(Puppet::ParseError, 'update_hosts_entries(): the ' +
                  "hostname `#{value}` duplicated in hosts entries.")
              end
            end
          end
          if add
            hosts_hash[current_addr].push(value)
          end
        end

      end

    end

    hosts_hash

  end
end


