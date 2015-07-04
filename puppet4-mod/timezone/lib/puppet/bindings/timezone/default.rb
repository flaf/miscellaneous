Puppet::Bindings.newbindings('timezone::default') do

  bind {
    name         'timezone'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


