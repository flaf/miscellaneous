# Copyright: 2014 Francois Lafont <francois.lafont@ac-versailles.fr>

module Puppet::Parser::Functions
  newfunction(:generate_password, :type => :rvalue, :doc => <<-EOS
Usage
-----
  1. In a yaml file (in hieradata):
        password: '__pwd__{<syntax explained below>}'
  2. Either
        $password = hiera('password')                         # in the manifest
        <%= scope.function_generate_password([@password]) %>  # in the template
     or
        $password = generate_password(hiera('password')) # in the manifest
        <%= @password %>                                 # in the template

Possible syntax in a yaml file
------------------------------
    key: '__pwd__{}'
    key: '__pwd__{ "pwd" => "master_password", "salt" => ["$fqdn"], "nice" => false, "max_length" => 0, "case" => "" }'
    key: '__pwd__{ "pwd" => "other_password", "salt" => ["$datacenter"], "nice" => true, "case" => "lower" }'
    key: '__pwd__{ "salt" => ["$datacenter", "snmp"], "case" => "upper" }'

Each key and value must be surrounded by single or double quotes
even $fqdn, $datacenter, etc. variables.
The only exception to this rules are:
  - the value of "max_length" which is an interger;
  - the value of "nice" which is an boolean (false or true).

Parameters in yaml file
-----------------------
    "pwd"
        gives the key name of a password in hiera
        Default value: "master_password"

    "salt"
        an array of strings which gives the salt.
        Default value: ["$fqdn"]

    "nice"
        if equal to true, the password is nice, ie ~ /[a-zA-Z0-9]/.
        Default value: false

    "max_length"
        truncates the password to N characters if the length
        of the password is greater than N.
        Default value: 0 (ie no truncation)

    "case"
        Force the case of the password. Possible value are "lower",
        "upper" or "" (empty string).
        Default value: "" (do not change the password)
EOS
  ) do |args|

    # Need to "hiera" puppet function.
    Puppet::Parser::Functions.function('hiera')
    require 'digest/md5'

    authorized_args = ['pwd', 'salt', 'max_length', 'nice', 'case']

    args[0].strip.gsub(/^__pwd__[[:blank:]]*(\{.*\})$/){
      # Get arguments and values in a hash.
      args_hash = eval($1)

      args_hash.each_key { |key|
        if not authorized_args.include?(key)
          raise Puppet::ParseError, "generate_password error, #{key} isn't an authorized argument."
        end
      }

      # Set default values.
      if not args_hash.include?('pwd')
        args_hash['pwd'] = 'master_password'
      end
      if not args_hash.include?('salt')
        args_hash['salt'] = [ lookupvar('fqdn') ]
      end
      if not args_hash.include?('max_length')
        args_hash['max_length'] = 0
      end
      if not args_hash.include?('nice')
        args_hash['nice'] = false
      end
      if not args_hash.include?('case')
        args_hash['case'] = ''
      end

      # Get the "source" password with hiera.
      source_pwd = function_hiera([args_hash['pwd']])

      # The password will be generated from "clear" variable
      # which is the concatenation of the pwd and the salt.
      clear = ''
      ([source_pwd] + args_hash['salt']).each { |arg|
        # If a salt begins with '$', it's a fact or a variable.
        # BUT.... in Ruby 1.8, arg[0] returns the ASCII code of the character.
        # In Ruby 1.9 and later, arg[0] returns the character (the expected behavior).
        # In Ruby 1.8, we must use arg[0,1] to have the first character.
        # In Ruby 1.9, the arg[0,1] syntax gives the first character too.
        if arg[0,1] == '$'
            arg = lookupvar(arg[1..-1])
        end
        clear += arg
      }

      # Creating password. This depends on the "nice" parameter.
      if args_hash['nice']
        password = Digest::MD5.hexdigest("#{clear}")
      else
        pass = []
        chars_list = ("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a + ["!","@","&","*","-","_","=","+",":","<",">",".",",","?","~"]
        n = Digest::MD5.hexdigest("#{clear}").hex
        while n > 0
          pass << chars_list[n.divmod(chars_list.size)[1]]
          n = n.divmod(chars_list.size)[0]
        end
        password = pass.join
      end

      # Formatting.
      l = args_hash['max_length']
      c = args_hash['case']
      if l > 0 and password.length > l
        password = password[0..l-1]
      end
      if c != ''
        if c == 'lower'
          password = password.downcase
        end
        if c == 'upper'
          password = password.upcase
        end
      end

      password

    }

  end
end

