Puppet::Bindings.newbindings('puppetagent::default') do

  bind {
    name         'puppetagent'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


