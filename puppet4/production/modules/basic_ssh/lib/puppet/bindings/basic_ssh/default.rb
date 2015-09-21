Puppet::Bindings.newbindings('basic_ssh::default') do

  bind {
    name         'basic_ssh'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


