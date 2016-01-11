Puppet::Bindings.newbindings('snmp::default') do

  bind {
    name         'snmp'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


