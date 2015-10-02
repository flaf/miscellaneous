Puppet::Functions.create_function(:'homemade::is_clean_arrayofstr') do

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


