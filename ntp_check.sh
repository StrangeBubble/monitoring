#!/bin/bash
# -*- encoding: utf-8; py-indent-offset: 4 -*-
# vim: :set ts=8 et sw=4 sts=4

hostname=`hostname`

if ps uafx|grep [n]tpd; then
    echo "  $hostname ; INFO ; ntp ; daemon is up"
else
    echo "  $hostname ; ERROR ; ntp ; daemon is down"
fi

if ntpq -np 2>&1|grep -q "No association ID's returned"; then
    echo "  $hostname ; INFO ; ntp ; No association ID's returned"
fi

exit 0