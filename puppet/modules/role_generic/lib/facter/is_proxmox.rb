Facter.add("is_proxmox") do
  ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
  setcode do

    # With system(), if the command doesn't exist, the
    # return value is nil (if the command exits it's
    # true/false in function of the exit code). But nil is
    # not a possible return value for a facter (because in
    # this case the facter is not defined). So the return
    # value here must be true or false.
    #
    # We redirect stdout and stderr to /dev/null. Without
    # this, on a Proxmox server, the output of the command
    # is printed at each puppet run.
    if system('pveversion >/dev/null 2>&1')
      true
    else
      false
    end

  end
end


