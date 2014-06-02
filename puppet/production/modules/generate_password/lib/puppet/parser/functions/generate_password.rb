# Here is a copy of the docstring but without the \"
# to be more readable directly in the source code.
#
#  Usage
#  -----
#    * In a yaml file (in hieradata):
#          password: '__pwd__{<syntax explained below>}'
#    * In a manifest:
#          password = hiera('password')
#       or password = generate_password(hiera('password'))
#    * In a template:
#          <%= scope.function_generate_password([@password]) %>
#       or <%= @password %>
#
#  Possible syntax in a yaml file
#  ------------------------------
#      key: '__pwd__{}'
#      key: '__pwd__{ "pwd" => "master_password", "salt" => ["$fqdn"], "nice" => false, "max_length" => 0, "case" => "" }'
#      key: '__pwd__{ "pwd" => "other_password", "salt" => ["$datacenter"], "nice" => true, "case" => "lower" }'
#      key: '__pwd__{ "salt" => ["$datacenter", "snmp"], "case" => "upper" }'
#
#  Each key and value must be surrounded by single or double quote
#  even $fqdn, $datacenter, etc. variables.
#  The only exception to this rules are:
#    - the value of "max_length" which is an interger;
#    - the value of "nice" which is an boolean (false or true).
#
#  Parameters in yaml file
#  -----------------------
#      "pwd"
#          gives the key name of a password in extdata
#          Default value: "master_password"
#
#      "salt"
#          an array of strings which gives the salt.
#          Default value: ["$fqdn"]
#
#      "nice"
#          if equal to true, the password is nice, ie ~ /[a-zA-Z0-9]/.
#          Default value: false
#
#      "max_length"
#          truncates the password to N characters if the length
#          of the password is greater than N.
#          Default value: 0 (ie no truncation)
#
#      "case"
#          Force the case of the password. Possible value are "lower",
#          "upper" or "" (empty string).
#          Default value: "" (do not change the password)


module Puppet::Parser::Functions
  newfunction(:generate_password, :type => :rvalue, :doc => "
  Usage
  -----
    * In a yaml file (in hieradata):
          password: '__pwd__{<syntax explained below>}'
    * In a manifest:
          password = hiera('password')
       or password = generate_password(hiera('password'))
    * In a template:
          <%= scope.function_generate_password([@password]) %>
       or <%= @password %>

  Possible syntax in a yaml file
  ------------------------------
      key: '__pwd__{}'
      key: '__pwd__{ \"pwd\" => \"master_password\", \"salt\" => [\"$fqdn\"], \"nice\" => false, \"max_length\" => 0, \"case\" => \"\" }'
      key: '__pwd__{ \"pwd\" => \"other_password\", \"salt\" => [\"$datacenter\"], \"nice\" => true, \"case\" => \"lower\" }'
      key: '__pwd__{ \"salt\" => [\"$datacenter\", \"snmp\"], \"case\" => \"upper\" }'

  Each key and value must be surrounded by single or double quote
  even $fqdn, $datacenter, etc. variables.
  The only exception to this rules are:
    - the value of \"max_length\" which is an interger;
    - the value of \"nice\" which is an boolean (false or true).

  Parameters in yaml file
  -----------------------
      \"pwd\"
          gives the key name of a password in extdata
          Default value: \"master_password\"

      \"salt\"
          an array of strings which gives the salt.
          Default value: [\"$fqdn\"]

      \"nice\"
          if equal to true, the password is nice, ie ~ /[a-zA-Z0-9]/.
          Default value: false

      \"max_length\"
          truncates the password to N characters if the length
          of the password is greater than N.
          Default value: 0 (ie no truncation)

      \"case\"
          Force the case of the password. Possible value are \"lower\",
          \"upper\" or \"\" (empty string).
          Default value: \"\" (do not change the password)
  ") do |args|

    # Need to extlookup puppet function.
    Puppet::Parser::Functions.function('extlookup')
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

      # Get the "source" password with extlookup.
      source_pwd = function_extlookup([args_hash['pwd']])

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
        CHARS = ("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a + ["!","@","&","*","-","_","=","+",":","<",">",".",",","?","~"]
        n = Digest::MD5.hexdigest("#{clear}").hex
        while n > 0
          pass << CHARS[n.divmod(CHARS.size)[1]]
          n = n.divmod(CHARS.size)[0]
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


