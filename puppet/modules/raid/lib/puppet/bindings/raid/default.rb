Puppet::Bindings.newbindings('raid::default') do

  bind {
    name         'raid'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


