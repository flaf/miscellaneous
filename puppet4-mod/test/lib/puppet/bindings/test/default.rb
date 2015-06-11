Puppet::Bindings.newbindings('test::default') do
  bind {
    name         'test'                # name of the module this is placed in
    to           'function'            # name of the data provider
    in_multibind 'puppet::module_data' # boiler-plate
  }
end


