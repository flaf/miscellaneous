module Puppet::Parser::Functions
  newfunction(:get_exported_hosts_entries, :type => :rvalue, :doc => <<-EOS
    TODO
    EOS
  ) do |args|

    exported_hosts_entries = lookupvar('exported_hosts_entries')

    if exported_hosts_entries.is_a?(String)
      exported_hosts_entries = eval(exported_hosts_entries)
    end

    exported_hosts_entries

  end
end


