Puppet::Bindings.newbindings('puppet_forge::default') do

  bind {
    name         'puppet_forge'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


