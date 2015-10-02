# TODO: this function should not exist because the exactly
#       same function already exists in the "homemade" module.
#       But currently, despite the fact that "homemade" is
#       well defined as dependency of the "network" in the
#       "metadata.json", functions of "homemade" module are
#       unreachable in a custom-ruby function of "network"
#       module.
#
#       It's probably a bug and when it will be solved, we
#       can remove this function and use directly the
#       functions of the "homemade" module.
#
#       Search PUP-5209 in the code of the "network" function
#       to remove the call of this function.
#
#         https://tickets.puppetlabs.com/browse/PUP-5209
#
Puppet::Functions.create_function(:'network::is_clean_arrayofstr') do

  dispatch :is_clean_arrayofstr do
    required_param  'Data', :any
  end

  def is_clean_arrayofstr(any)

    unless any.is_a?(Array) and not any.empty?
      return false
    end

    any.each do |e|
      unless e.is_a?(String) and not e.empty?
        return false
      end
    end

    return true

  end

end


