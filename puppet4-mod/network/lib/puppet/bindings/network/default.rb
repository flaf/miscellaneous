Puppet::Bindings.newbindings('network::default') do

  bind {
    name         'network'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


