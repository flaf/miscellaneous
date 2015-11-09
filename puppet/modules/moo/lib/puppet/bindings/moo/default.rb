Puppet::Bindings.newbindings('moo::default') do

  bind {
    name         'moo'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


