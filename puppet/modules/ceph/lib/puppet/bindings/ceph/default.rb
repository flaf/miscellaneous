Puppet::Bindings.newbindings('ceph::default') do

  bind {
    name         'ceph'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


