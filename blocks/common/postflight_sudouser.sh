#!/bin/bash

#mkdir -p /test/{1,2}
#lsof > /test/1/dump_lsof
#free -m > /test/1/dump_free
#pstree > /test/1/dump_pstree
#df -a > /test/1/dump_df
#ls /dev/fd/** > /test/1/dump_dev_fd

# sudo
# ------------------------------------------------------------------------
_installpkg sudo bash-completion # bash-completion to allow completion even when enter sudo command
[ ! -e /etc/sudoers.orig ] && cp /etc/sudoers /etc/sudoers.orig
[ -e /etc/sudoers.temp ] && rm /etc/sudoers.temp

#MATCH="%wheel.ALL=(ALL).ALL"
#sed -i "s/^#\s*\(${MATCH}\)/\1/" /tmp/sudoers.temp

cat > /etc/sudoers.temp << EOF
Cmnd_Alias SYSUTILS = /bin/nice, /bin/kill, /usr/bin/nice, /usr/bin/ionice, /usr/bin/top, /usr/bin/kill, /usr/bin/killall, /usr/bin/ps, /usr/bin/pkill, /usr/bin/pacman, /usr/sbin/lsof, /bin/nice, /bin/ps, /usr/bin/top, /usr/local/bin/nano, /bin/netstat, /usr/bin/locate, /usr/bin/find, /usr/bin/rsync, /usr/bin/powertop, /usr/sbin/powertop, /usr/bin/dispatch
Cmnd_Alias EDITORS = /usr/bin/vim, /usr/bin/nano, /usr/bin/cat, /usr/bin/vi
Cmnd_Alias NETWORKING = /usr/bin/wpa_supplicant, /usr/bin/wpa_cli, /usr/bin/wpa_passphrase, /usr/bin/iw, /usr/bin/netcfg, /usr/bin/wifi-menu, /usr/bin/wifi
Cmnd_Alias AUDIO = /usr/bin/amixer, /usr/bin/pamixer

# a little redundant
root      ALL=(ALL) ALL
%sudo     ALL=(ALL) ALL
%wheel    ALL=(ALL) ALL, NOPASSWD: NETWORKING, NOPASSWD: SYSUTILS, NOPASSWD: EDITORS
%audio    ALL=(ALL) ALL, NOPASSWD: AUDIO
 
Defaults !requiretty, !tty_tickets, !umask
Defaults visiblepw, path_info, insults, lecture=always
Defaults loglinelen = 0, logfile =/var/log/sudo.log, log_year, log_host, syslog=auth
Defaults mailto=acewin@gmail.com, mail_badpass, mail_no_user, mail_no_perms
Defaults passwd_tries = 8, passwd_timeout = 1
Defaults env_reset, always_set_home, set_home, set_logname
Defaults !env_editor, editor="/usr/bin/vim:/usr/bin/vi:/usr/bin/nano"
Defaults timestamp_timeout=360
Defaults passprompt="Sudo invoked by [%u] on [%H] - Cmd run as %U - Password for user %p:"
Defaults setenv

# allow sudo to start x
Defaults env_keep += "HOME"
EOF

# check and copy /etc/sudoers
visudo -qcsf /etc/sudoers.temp && cat /etc/sudoers.temp > /etc/sudoers && rm /etc/sudoers.temp

# make sure we have the right permissions and ownership
chown -c root:root /etc/sudoers
chmod -c 0440 /etc/sudoers

# add user
# ------------------------------------------------------------------------
echo -e "\nNew non-root user password (username:${USERNAME})\n"
groupadd sudo
useradd -m -g users -G audio,lp,optical,storage,video,games,power,scanner,network,sudo,wheel -s ${USERSHELL} ${USERNAME}

#_double_check_until_match
#echo $_DOUBLE_CHECK_RESULT | passwd ${USERNAME} --stdin
#passwd ${USERNAME} --stdin
_try_until_success "passwd ${USERNAME}" 5 || echo -e "\nERROR: password unchanged for ${USERNAME}\n"
