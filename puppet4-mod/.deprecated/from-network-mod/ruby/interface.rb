require 'ipaddr'

class Interface

  # Warning, after creation, the state of an Interface object shouldn't
  # be modified. The implementation of this class doesn't support the
  # change of the state of an object.
  attr_reader :conf
  attr_reader :name
  attr_reader :method
  attr_reader :has_address_option
  attr_reader :has_cidr_address
  attr_reader :ip_address
  attr_reader :ip_netmask
  attr_reader :ip_network
  attr_reader :ip_broadcast

  def initialize(conf)

    @mandatory_keys     = [ 'name',
                            'method',
                            'family',
                          ]
    @allowed_keys       = { @mandatory_keys[0] => String,
                            @mandatory_keys[1] => String,
                            @mandatory_keys[2] => String,
                            'options'          => Hash,
                            'network-name'     => String,
                            'comment'          => String,
                            'macaddress'       => String,
                          }
    @conf               = conf
    @has_address_option = false # will be updated (or not) below.
    @has_cidr_address   = false # will be updated (or not) below.

    # Instance variables defined below:
    #
    #   - @ip_address
    #   - @ip_network_address
    #   - @name

    # Check if the mandatory keys are presents.
    @mandatory_keys.each do |key|
      unless @conf.has_key?(key)
        msg_no_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |The interface `#{@conf.to_s}` is not valid because it
          |has no `#{key}` key.
          EOS
        raise(Exception, msg_no_key)
      end
    end

    # Some basic checkings...
    @conf.each do |key_name, key_value|

      # Check if each key of @conf is an allowed key.
      unless @allowed_keys.include?(key_name)
        msg_key_not_allowed = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |The interface `#{@conf.to_s}` is not valid because the
          |key `#{key_name}` is not an allowed key.
          |Allowed keys are: #{@allowed_keys.keys.join(', ')}.
          EOS
        raise(Exception, msg_key_not_allowed)
      end

      # Check if each key of @conf has the correct type.
      unless key_value.is_a?(@allowed_keys[key_name])
        msg_wrong_type = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |The interface `#{@conf.to_s}` is not valid
          |because the type of the key `#{key_name}` is wrong. The
          |type is `#{key_value.class.to_s}` but must be
          |`#{@allowed_keys[key_name].to_s}`.
          EOS
        raise(Exception, msg_wrong_type)
      end

      # Check if each key has no empty value.
      if key_value.respond_to?(:empty?)
        if key_value.empty?
          msg_empty_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |The interface `#{@conf.to_s}` not valid because
            |the value of the key `#{key_name}` is empty.
            EOS
          raise(Exception, msg_empty_key)
        end
      end

      if key_name == 'options'

        # Check if @conf['options'] is a hash of strings for
        # the keys and the values.
        @conf['options'].each do |k, v|

          unless k.is_a?(String) and v.is_a?(String) and \
                 (not k.empty?) and (not v.empty?)
            msg_options_error = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
              |The interface `#{@conf.to_s}` is not valid because
              |the hash `options` must be a hash of non empty strings
              |for the keys and the values.
              EOS
            raise(Exception, msg_options_error)
          end

          if k == 'address'
            @has_address_option = true
          end

        end

      end # End of the handle of the specific 'options' key.

    end # End of the loop on the keys of @conf and the basic checkings.


    # Check the address and define the:
    #
    #   - @ip_address
    #   - @ip_network_address
    #
    # variable instances.
    if @has_address_option

      address_str = @conf['options']['address']
      if address_str =~ Regexp.new('/[0-9]+$')

        # This is a CIDR address.
        @has_cidr_address     = true
        ip_address_str        = address_str.split('/')[0]
        begin
          @ip_address         = IPAddr.new(ip_address_str)
          @ip_network_address = IPAddr.new(address_str)
        rescue ArgumentError
          msg_bad_address = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |The interface `#{@conf.to_s}` is not valid because
            |the `address` option doesn't contain a valid CIDR
            |address.
            EOS
          raise(Exception, msg_bad_address)
        end

      else

        # This is an IP address but not a CIDR address.
        # The `netmask` option must exist.
        unless @conf['options'].has_key?('netmask')
          msg_no_netmask = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |The interface `#{@conf.to_s}` is not valid because
            |there is an `address` option as an IP address (not
            |as a CIDR address) but there is no `netmask` option.
            EOS
          raise(Exception, msg_no_netmask)
        end

        netmask = @conf['options']['netmask']
        begin
          @ip_address         = IPAddr.new(address_str)
          @ip_network_address = IPAddr.new(address_str + '/' + netmask)
        rescue ArgumentError
          msg_bad_address = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |The interface `#{@conf.to_s}` is not valid because
            |the `address` and/or the `netmask` options doesn't
            |contain a valid address.
            EOS
          raise(Exception, msg_bad_address)
        end

      end

    else

      # The instance variables will always exist but will be equal
      # to nil if not defined.
      @ip_address         = nil
      @ip_network_address = nil

    end # End of the handle if the interface has an `address` option.

    # Now, we are sure that the interface has the `name`
    # and `method` keys.
    @name   = @conf['name']
    @method = @conf['method']

  end


  def is_matching_network(network)

    # false by default and we want to update this value
    # to true only when it's matching.
    result = false

    if @conf.has_key?('network-name')

      if @conf['network-name'] == network.get_name
        if not @ip_network_address.nil?
          # The interface has an IP address.
          # We have to check that the address matches with the
          # network address.
          unless @ip_network_address.eql?(network.get_ip_address)
            msg_pb_address = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
              |The interface `#{@conf.to_s}` should match with the
              |`#{network.get_name}` network but the address
              |doesn't match with the CIDR address of the network.
              EOS
            raise(Exception, msg_pb_address)
          end
        end
        result = true
      end

    else

      # No 'network-name' key. We have to check the IP address.
      if @ip_network_address.nil?
        msg_no_addr = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |The interface `#{@conf.to_s}` has no `address` options and
          |no `network-name` key, so it's impossible to test
          |if this interface matches with a given network.
          EOS
        raise(Exception, msg_no_addr)
      else
        if @ip_network_address.eql?(network.get_ip_address)
          result = true
        end
      end

    end

    return result

  end


  def get_matching_network(networks)

    matching_networks = []

    networks.each do |network|
      if self.is_matching_network(network)
        matching_networks.push(network)
      end
    end

    n = matching_networks.length

    if n > 1
      names          = networks.map { |net| net.get_name }.join(', ')
      matching_names = matching_networks.map { |net| net.get_name }.join(', ')
      msg_too_net    = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |The interface `#{@conf.to_s}` has several matching
        |networks. Among #{names}, these networks are
        |matching with the interface: #{matching_names}.
        EOS
      raise(Exception, msg_too_net)
    elsif n == 0
      names      = networks.map { |net| net.get_name }.join(', ')
      msg_no_net = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |The interface `#{@conf.to_s}` has no matching
        |network. Among #{names}, no network is matching
        |with the interface.
        EOS
      raise(Exception, msg_no_net)
    else
      # There is only one matching network.
      return matching_networks[0]
    end

  end


  # TODO
  def fill_conf(networks)

    specific_options = [
                        'address',
                        'netmask',
                        'broadcast',
                       ]

    network = self.get_matching_network(networks)
    new_conf = {}

    @conf.each do |key, value|
      if value == '<default>'
        unless network.get_conf.has_key?(key)
          msg_no_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |In the interface `#{@conf.to_s}`, impossible to fill
            |the key `#{key}` because it doesn't exist in the matching
            |network `#{network.get_name}`.
            EOS
          raise(Exception, msg_no_key)
        end
        new_conf[key] = network.get_conf[key]
      elsif value.is_a?(String)
        new_conf[key] = value
      elsif value.is_?(Hash)
        # Normally, it's the key `options` and the keys and values are strings.
        new_conf[key] = {}
        
      else

      end
    end

    return new_conf

  end


end



class Address_family

  attr_reader :type
  attr_reader :method
  attr_reader :options

  def initialize(type, method, options)
  end

end



class Network

  def initialize(conf)

    @mandatory_keys = {
                       'name'         => String,
                       'cidr-address' => String,
                       'vlan-id'      => Integer,
                      }
    @conf           = conf

    # Check if each mandatory key is present with the correct type.
    @mandatory_keys.each do |key_name, key_type|
      unless @conf.has_key?(key_name) and @conf[key_name].is_a?(key_type)
        msg_mandatory_keys = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |The network `#{@conf.to_s}` is not valid. The key
        |`#{key_name}` must exist and its value must have the
        |`#{key_type.to_s}` type.
        EOS
        raise(Exception, msg_mandatory_keys)
      end
    end

    # Check if each value is not empty.
    @conf.each do |k, v|
      if @conf[k].respond_to?(:empty?)
        if @conf[k].empty?
          msg_empty_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |The network `#{@conf.to_s}` is not valid
          |because the value of the key `#{k}` is empty.
          EOS
          raise(Exception, msg_empty_key)
        end
      end
    end

    @name         = @conf['name']
    @cidr_address = @conf['cidr-address']
    @vlan_id      = @conf['vlan-id']

    msg_bad_address = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
      |The network `#{@conf.to_s}` is not valid because
      |the `cidr-address` key doesn't contain a valid CIDR
      |address.
      EOS

    unless @cidr_address =~ Regexp.new('/[0-9]+$')
      raise(Exception, msg_bad_address)
    end

    begin
      @ip_address = IPAddr.new(@cidr_address)
    rescue ArgumentError
      raise(Exception, msg_bad_address)
    end

  end

  def get_conf
    @conf
  end

  def get_name
    @name
  end

  def get_cidr_address
    @cidr_address
  end

  def get_vlan_id
    @vlan_id
  end

  def get_ip_address
    @ip_address
  end

end


