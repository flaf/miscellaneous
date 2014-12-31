Facter.add("exported_hosts_entries") do
  setcode do

    hosts_entries = {}
    files_array = Dir.glob("/etc/hosts.puppet.d/*.conf")

    files_array.each do |f|
      fo = open(f)
      hosts_entries[f] = fo.read.split(' ')
      fo.close
    end

    hosts_entries

  end
end


