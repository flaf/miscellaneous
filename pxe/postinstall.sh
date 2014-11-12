#!/bin/sh

set -x
exec >/root/postinstall.log 2>&1

codename="$1"
info="$2"

# Set default locale.
update-locale LANG="en_US.UTF-8"

# Set keyboard configuration.
# https://wiki.debian.org/Keyboard
cat >/etc/default/keyboard <<EOF
### Set by postinstall.sh ###

# KEYBOARD CONFIGURATION FILE
# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="fr"
XKBVARIANT="latin9"
XKBOPTIONS=""
BACKSPACE="guess"

EOF

service keyboard-setup restart


# Disable IPv6.
sed -i -r 's/^GRUB_CMDLINE_LINUX=.*$/GRUB_CMDLINE_LINUX="ipv6.disable=1"/' \
          /etc/default/grub
update-grub

# Install classic packages.
apt-get update
apt-get dist-upgrade --yes
apt-get install --yes vim bash-completion less gawk \
                      lsb-release openssl ca-certificates

# On Trusty, tree is not in main and restricted but in
# universe which is maybe not in the source.list.
n=$(apt-cache search --names-only '^tree$' | wc -l)
if [ "$n" != 0 ]
then
    apt-get install --yes tree
fi


# Set the .vimrc profile.
echo 'syntax on
"set number
set tabstop=4
set shiftwidth=4
set expandtab
"set autoindent
set laststatus=2
set listchars=nbsp:¤,tab:>-,trail:¤,trail:·
set list
set ignorecase
set smartcase
set showcmd
' > /root/.vimrc

# Set the .bashrc profile.
echo '

PS1="${debian_chroot:+($debian_chroot)}\[\e[01;32m\]\u@\h \[\e[01;34m\]\A \[\e[01;37m\]\w\[\e[00m\]\n# "
export EDITOR=vim
alias vim="vim -p"
alias ll="ls -al"
alias upgrade="apt-get update && apt-get dist-upgrade"
HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL="ignoredups:ignorespace"
' >> /root/.bashrc

if [ "$codename" = "wheezy" ]
then
    # Don't clear tty1 after reboot.
    sed -r -i 's|^(1.*/sbin/getty)(.*)$|\1 --noclear\2|' /etc/inittab
fi

if [ "$codename" = "trusty" ] || [ "$codename" = "jessie" ]
then
    # Allow ssh connection with root who has a password.
    sed -i -r 's/^(PermitRootLogin without-password.*)$/#\1/' /etc/ssh/sshd_config
    apt-get purge --yes mlocate
fi

# Specific to the RAID software.
if [ "$info" = "raidsoft" ]
then
    gawk '!/^[[:space:]]*(#|$)/ { if ($2 == "/") {gsub($4,"noatime,"$4)} else if ($2 == "/boot") {gsub($4,"noatime")} }; { print }' /etc/fstab > /tmp/fstab.new
    cat /tmp/fstab.new > /etc/fstab
    lvremove --force /dev/vg1/dummylv1
fi


