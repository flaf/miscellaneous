Puppet::Bindings.newbindings('puppetforge::default') do

  bind {
    name         'puppetforge'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


