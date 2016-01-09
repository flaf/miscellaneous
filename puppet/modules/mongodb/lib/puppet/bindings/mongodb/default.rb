Puppet::Bindings.newbindings('mongodb::default') do

  bind {
    name         'mongodb'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


