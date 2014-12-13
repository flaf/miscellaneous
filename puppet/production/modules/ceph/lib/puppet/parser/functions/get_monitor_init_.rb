module Puppet::Parser::Functions
  newfunction(:get_monitor_init_, :type => :rvalue, :doc => <<-EOS
This is a private function used by the module.
The function takes one argument which is the monitors hash.
This function returns the name of the inital monitor.
  EOS
  ) do |args|

    #Puppet::Parser::Functions.function('check_ifaces_hash')

    num_args = 1
    unless(args.size == num_args)
      raise(Puppet::ParseError, 'get_monitor_init_(): wrong number of ' +
            "arguments given (#{args.size} instead of #{num_args})")
    end

    monitors = args[0]

    unless(monitors.is_a?(Hash))
      raise(Puppet::ParseError, 'get_monitor_init_(): the argument must ' +
            'be a hash')
    end

    # Number of initial monitor found.
    c = 0

    monitor_init = ''
    monitors.each do |mon, params|
      unless(params.is_a?(Hash))
        raise(Puppet::ParseError, 'get_monitor_init_(): parameters of ' +
              'each monitor must be a hash')
      end
      if params.has_key?('initial') and params['initial'] == true
        monitor_init = mon
        c += 1
      end
    end

    if c == 0
      raise(Puppet::ParseError, 'get_monitor_init_(): initial ' +
            'monitor not found')
    elsif c > 1
      raise(Puppet::ParseError, 'get_monitor_init_(): several initial ' +
            'monitors found. Initial monitor must be unique')
    end

    monitor_init

  end
end


