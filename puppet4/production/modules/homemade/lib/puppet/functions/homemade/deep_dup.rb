Puppet::Functions.create_function(:'homemade::deep_dup') do

  dispatch :deep_dup do
    required_param 'Data', :obj
  end

  def deep_dup(obj)

    case obj
      when Hash
        obj.each_with_object({}) do |(k,v),h|
          h[deep_dup(k)] = deep_dup(v)
        end
      when Array
        obj.map do |v|
          deep_dup(v)
        end
      else
        # Must be a string, an integer or a float.
        unless obj.is_a?(String) or obj.is_a?(Integer) or obj.is_a?(Float)
          msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |deep_dup(): the function can work well only with hashes,
            |arrays, strings, integers or floats.
            EOS
          raise(Puppet::ParseError, msg)
        end
        obj.dup
    end

  end

end


