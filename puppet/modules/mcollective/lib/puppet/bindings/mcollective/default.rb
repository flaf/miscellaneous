Puppet::Bindings.newbindings('mcollective::default') do

  bind {
    name         'mcollective'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


