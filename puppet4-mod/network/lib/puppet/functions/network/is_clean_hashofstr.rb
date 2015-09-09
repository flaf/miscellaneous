# TODO: see comment in the network::is_clean_arrayofstr function.
#       PUP-5209
#
Puppet::Functions.create_function(:'network::is_clean_hashofstr') do

  dispatch :is_clean_hashofstr do
    required_param  'Data', :any
  end

  def is_clean_hashofstr(any)

    unless any.is_a?(Hash) and not any.empty?
      return false
    end

    any.each do |k, v|
      unless k.is_a?(String) and not k.empty?
        return false
      end
      unless v.is_a?(String) and not v.empty?
        return false
      end
    end

    return true

  end

end


