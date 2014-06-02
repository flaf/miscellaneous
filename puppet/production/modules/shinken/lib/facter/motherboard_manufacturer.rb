Facter.add("motherboard_manufacturer") do
  ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
  setcode do

    cmd = 'dmidecode -q -s baseboard-manufacturer'
    motherboard_manufacturer = Facter::Util::Resolution.exec(cmd)
    if motherboard_manufacturer.nil?
      motherboard_manufacturer = ''
    end

    motherboard_manufacturer

  end
end


