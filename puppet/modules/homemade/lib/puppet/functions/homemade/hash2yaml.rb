Puppet::Functions.create_function(:'homemade::hash2yaml') do

  dispatch :hash2yaml do
    required_param 'Hash[String[1], Data, 1]', :a_hash
  end

  def hash2yaml(a_hash)
    begin
      # We remove the header to just have the content.
      a_hash.to_yaml.sub(/^---\n/, '')
    rescue Exception
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |hash2yaml(): the hash `#{a_hash}` can't be converted
        |to a yaml string.
        EOS
      raise(Puppet::ParseError, msg)
    end
  end

end


