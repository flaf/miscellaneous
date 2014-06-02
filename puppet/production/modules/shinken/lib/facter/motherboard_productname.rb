Facter.add("motherboard_productname") do
  ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
  setcode do

    cmd = 'dmidecode -q -s baseboard-product-name'
    motherboard_productname = Facter::Util::Resolution.exec(cmd)
    if motherboard_productname.nil?
      motherboard_productname = ''
    end

    motherboard_productname

  end
end


