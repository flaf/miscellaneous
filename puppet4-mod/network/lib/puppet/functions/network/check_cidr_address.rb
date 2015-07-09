Puppet::Functions.create_function(:'network::check_cidr_address') do

  dispatch :check_cidr_address do
    required_param 'String[1]', :cidr_address_str
  end

  def check_cidr_address(cidr_address_str)

    require 'ipaddr'
    function_name = 'check_cidr_address'

    msg_cidr_not_valid = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
      |#{function_name}(): the `#{cidr_address_str}` string
      |is not a valid CIDR address (which must match at least
      |this regexp `^[^/]+/\d+$`).
      EOS

    if not cidr_address_str =~ Regexp.new('^[^/]+/\d+$')
      raise(Puppet::ParseError, msg_cidr_not_valid)
    end

    ip_address_str = cidr_address_str.split('/')[0]

    begin
      ip_address      = IPAddr.new(ip_address_str)
      # With the CIDR string, the address is automatically masked.
      network_address = IPAddr.new(cidr_address_str)
    rescue ArgumentError
      raise(Puppet::ParseError, msg_cidr_not_valid)
    end

    true

  end

end


