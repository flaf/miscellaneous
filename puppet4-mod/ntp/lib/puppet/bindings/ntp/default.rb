Puppet::Bindings.newbindings('ntp::default') do

  bind {
    name         'ntp'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


