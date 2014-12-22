module Puppet::Parser::Functions
  newfunction(:get_exported_hosts_entries, :type => :rvalue, :doc => <<-EOS
This function returns the value of the fact "exported_hosts_entries".
Normally, this fact is a hash. But if the node has a version
of facter < 2, or if the puppet agent is set with "stringify_facts = false"
in the puppet.conf (which is the default with Puppet 3), Puppet
retrieves a flattened string, not a hash. This function convert
the string to a (real) hash if necessary.
    EOS
  ) do |args|

    # Retrieve the custom fact "exported_hosts_entries".
    exported_hosts_entries = lookupvar('exported_hosts_entries')

    if exported_hosts_entries.is_a?(String)
      exported_hosts_entries = eval(exported_hosts_entries)
    end

    exported_hosts_entries

  end
end


