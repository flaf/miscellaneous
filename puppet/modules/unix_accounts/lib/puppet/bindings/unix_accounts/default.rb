Puppet::Bindings.newbindings('unix_accounts::default') do

  bind {
    name         'unix_accounts'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


