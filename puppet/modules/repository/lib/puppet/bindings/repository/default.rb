Puppet::Bindings.newbindings('repository::default') do

  bind {
    name         'repository'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


