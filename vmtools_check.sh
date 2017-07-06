#!/bin/bash
# -*- encoding: utf-8; py-indent-offset: 4 -*-
# vim: :set ts=8 et sw=4 sts=4

hostname=`hostname`

if ps uafx|grep [v]mtools; then
    echo "  $hostname ; INFO ; vmtools ; daemon is up"
else
    echo "  $hostname ; ERROR ; vmtools ; daemon is down"
fi

exit 0