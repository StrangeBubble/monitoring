#!/bin/bash
# -*- encoding: utf-8; py-indent-offset: 4 -*-
# vim: :set ts=8 et sw=4 sts=4

if [[ "`lsb_release -i|awk '{print $NF}'`" != "RedHatEnterpriseServer" ]]; then
    printf "Red Hat is only supported\n"
    exit 0
fi

VERSION=`lsb_release -r|awk '{print $NF}'`
MAJOR=${VERSION%.*}
MINOR=${VERSION#*.}

# RH6 only
if [[ $MAJOR -eq 6 ]]; then
    /sbin/service rsyslog stop
    /sbin/service auditd stop
fi

# RH7 only
if [[ $MAJOR -eq 7 ]]; then
    /bin/systemctl stop rsyslog.service
    /sbin/service auditd stop
    /bin/systemctl stop tuned.service
fi

# Logrotate and logs
logrotate -f /etc/logrotate.conf
cd /var/log/
rm -f *-2* *gz *old
rm -f apt/*
rm -f anaconda* anaconda/*
rm -f audit/audit.log audit/*
rm -f tuned/*
rm -f tallylog
rm -f rhsm/rhsmcertd.log-*
rm -f rhsm/rhsm.log-*
rm -f sa/*
rm -f *.{1,2}
rm -f upstart/*gz
rm -f lynis*
rm -f vmware-tools-upgrader.log vmware-imc/toolsDeployPkg.log
find . -type f | while read f; do > $f; done
find . -type f -ls

# clean /tmp
rm -fr /tmp/*
rm -fr /var/tmp/*

# remove history, etc.
cd ~root
rm -fr .Xauthority .viminfo tina.txt .pki install.log.syslog install.log anaconda-ks.cfg .InstallAnywhere/ .ssh
cd /home
rm -f */{.bash_history}

rm -f ~root/.bash_history
unset HISTFILE
history -c

exit 0