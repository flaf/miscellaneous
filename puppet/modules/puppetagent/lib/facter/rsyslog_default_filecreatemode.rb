Facter.add("rsyslog_default_filecreatemode") do
  setcode do

    rsyslog_default_filecreatemode = ''

    if FileTest.exists?("/etc/rsyslog.conf")
      regex = /^[[:blank:]]*\$FileCreateMode[[:blank:]]+([0-7]+)[[:blank:]]*$/
      lines = File.readlines("/etc/rsyslog.conf").select { |line| line =~ regex }
      if lines.size == 1
        rsyslog_default_filecreatemode = lines[0].match(regex).captures[0]
      end
    end

    rsyslog_default_filecreatemode

  end
end


