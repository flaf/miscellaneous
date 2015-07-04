Puppet::Bindings.newbindings('locale::default') do

  bind {
    name         'locale'
    to           'function'
    in_multibind 'puppet::module_data'
  }

end


