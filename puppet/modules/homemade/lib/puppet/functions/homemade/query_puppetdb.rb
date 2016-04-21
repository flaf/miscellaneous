Puppet::Functions.create_function(:'homemade::query_puppetdb') do

  dispatch :query_puppetdb do
    required_param 'String[1]', :query
  end

  def query_puppetdb(query)

    require 'puppet/util/puppetdb'
    Puppet::Util::Puppetdb.query_puppetdb(query)

#    require 'net/http'
#    require 'json'
#    require 'openssl'
#
#    cert      = File.read('/etc/puppetlabs/puppet/ssl/certs/puppet.athome.priv.pem')
#    privkey   = File.read('/etc/puppetlabs/puppet/ssl/private_keys/puppet.athome.priv.pem')
#    ca_file   = '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
#    params    = { :query => query }
#    uri       = URI('https://puppet.athome.priv:8081/pdb/query/v4')
#    uri.query = URI.encode_www_form(params)
#
#    # And ssl_version?
#    Net::HTTP.start(
#      uri.host, uri.port,
#      :use_ssl     => uri.scheme == 'https',
#      :cert        => OpenSSL::X509::Certificate.new(cert),
#      :key         => OpenSSL::PKey.read(privkey),
#      :ca_file     => ca_file,
#      :verify_mode => OpenSSL::SSL::VERIFY_PEER,
#    ) do |http|
#      request  = Net::HTTP::Get.new(uri)
#      response = http.request request
#
#      JSON.parse(response.body)
#    end
#
#    # The same ssl version but without the ".start" bloc.
#    #http = Net::HTTP.new(uri.host, uri.port)
#    #http.use_ssl     = true
#    #http.cert        = OpenSSL::X509::Certificate.new(cert)
#    #http.key         = OpenSSL::PKey.read(privkey)
#    #http.ca_file     = ca_file
#    #http.verify_mode = OpenSSL::SSL::VERIFY_PEER
#    ##http.ssl_version = :TLSv1
#    #request  = Net::HTTP::Get.new(uri)
#    #response = http.request request
#    #JSON.parse(response.body)
#
#
#    # The (full complete) no SSL version.
#    #
#    #uri       = URI('http://localhost:8080/pdb/query/v4')
#    #params    = { :query => query }
#    #uri.query = URI.encode_www_form(params)
#    #res       = Net::HTTP.get_response(uri)
#    #JSON.parse(res.body)

  end

end



