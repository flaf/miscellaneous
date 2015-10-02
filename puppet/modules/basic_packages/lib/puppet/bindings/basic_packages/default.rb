Puppet::Bindings.newbindings('basic_packages::default') do

  bind {
    name         'basic_packages'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


