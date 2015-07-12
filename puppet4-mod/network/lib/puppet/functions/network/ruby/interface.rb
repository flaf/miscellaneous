require 'ipaddr'

class Interface

  def initialize(conf)

    @conf           = conf
    @mandatory_keys = [
                       'name',
                       'method',
                      ]
    @allowed_keys   = {
                       'name'         => String,
                       'method'       => String,
                       'options'      => Hash,
                       'network-name' => String,
                       'comment'      => String,
                       'macaddress'   => String,
                      }

    # Check if the mandatory keys are presents.
    @mandatory_keys.each do |key|
      unless @conf.has_key?(key)
        msg_no_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |the interface `#{conf.to_s}` is not valid because it
          |has no `#{key}` key.
          EOS
        raise(Exception, msg_no_key)
      end
    end

  end

end

class Network

  def initialize(conf)
    @conf         = conf
    @name         = conf['name']
    @cidr_address = conf['cidr-address']
    @vlan_id      = conf['vlan-id']
  end

end


