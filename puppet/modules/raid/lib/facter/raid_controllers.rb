Facter.add("raid_controllers") do
  ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
  setcode do

    raid_controllers = []

    if FileTest.exists?("/proc/mdstat")
      txt = File.read("/proc/mdstat")
      raid_controllers.push('software') if txt =~ /^md/i
    end

    cmd = 'lspci | grep RAID | sed -r "s/^.*RAID[[:space:]]+bus[[:space:]]+controller[[:space:]]*:[[:space:]]*(.*)$/\1/i"'
    lspci = Facter::Util::Resolution.exec(cmd)
    raid_controllers += lspci.strip.split("\n") if not lspci.nil?

    raid_controllers

  end
end


