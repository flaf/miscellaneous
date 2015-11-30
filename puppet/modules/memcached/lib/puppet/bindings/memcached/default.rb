Puppet::Bindings.newbindings('memcached::default') do

  bind {
    name         'memcached'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


