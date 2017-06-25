Facter.add("etckeeper_ssh_pubkey") do
  setcode do

    ssh_pubkey = ''

    if FileTest.exists?('/root/.ssh/etckeeper_id_rsa.pub')
      ssh_pubkey = File.read('/root/.ssh/etckeeper_id_rsa.pub').chomp
    end

    ssh_pubkey

  end
end


