Puppet::Bindings.newbindings('mcomiddleware::default') do

  bind {
    name         'mcomiddleware'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


