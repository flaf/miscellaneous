Puppet::Bindings.newbindings('pxeserver::default') do

  bind {
    name         'pxeserver'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


