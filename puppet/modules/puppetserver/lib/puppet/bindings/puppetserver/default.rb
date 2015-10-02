Puppet::Bindings.newbindings('puppetserver::default') do

  bind {
    name         'puppetserver'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


