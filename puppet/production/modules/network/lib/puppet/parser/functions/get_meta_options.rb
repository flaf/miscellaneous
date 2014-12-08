module Puppet::Parser::Functions
  newfunction(:get_meta_options, :type => :rvalue, :doc => <<-EOS
Returns the array of meta options, ie the options which
will be not used as stanza in the `interfaces` file but
as comment for each interface.
    EOS
  ) do |args|

    meta_options = [
                    'macaddress',
                    'network_name',
                    'vlan_name',
                    'vlan_id',
                    'cidr_address',
                    'comment',
                   ]
    meta_options

  end
end


