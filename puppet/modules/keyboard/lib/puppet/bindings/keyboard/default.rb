Puppet::Bindings.newbindings('keyboard::default') do

  bind {
    name         'keyboard'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


