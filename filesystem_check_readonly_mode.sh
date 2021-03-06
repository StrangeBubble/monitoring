#!/bin/bash
# -*- encoding: utf-8; py-indent-offset: 4 -*-
# vim: :set ts=8 et sw=4 sts=4

excludefs="-x smbfs -x tmpfs -x cifs -x iso9660 -x udf -x nfsv4 -x nfs -x mvfs -x zfs"
listeMount=`df -PTlk $excludefs | sed -e 1d | awk '{print $7}'`
hostname=`hostname`

for m in $listeMount; do
    space_free=$(df -hP $m | tail -1 | sed 's/ \+/ /g' | cut -d" " -f 5)
    if  [[ "${space_free%\%}" -eq '100' ]]; then
        exit 1
    fi

    tmpFile=`mktemp -p "$m" 2>&1`
    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "  $hostname : ERROR : $tmpFile"
        test -f "$tmpFile" && rm -f "$tmpFile"
    else
        echo "  $hostname : INFO : filesystem $m not in read only mode"
        rm -f "$tmpFile"
    fi
done

exit 0
