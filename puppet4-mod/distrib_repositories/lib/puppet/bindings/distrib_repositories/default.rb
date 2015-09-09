Puppet::Bindings.newbindings('distrib_repositories::default') do

  bind {
    name         'distrib_repositories'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


