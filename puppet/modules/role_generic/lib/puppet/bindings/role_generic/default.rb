Puppet::Bindings.newbindings('role_generic::default') do

  bind {
    name         'role_generic'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


