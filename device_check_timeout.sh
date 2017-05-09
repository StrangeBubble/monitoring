#!/bin/bash
# -*- encoding: utf-8; py-indent-offset: 4 -*-
# vim: :set ts=8 et sw=4 sts=4

hostname=`hostname`

find /sys/block/*/device/timeout -exec grep -H . '{}' \; | tr ':' ' ' |\
    while read dev timeout; do
        if [[ $timeout -ge 60 ]]; then
            echo "  $hostname ; INFO ; device $dev ; timeout = $timeout"
        else
            echo "  $hostname ; ERROR ; device $dev ; timeout = $timeout"
        fi
    done

exit 0
