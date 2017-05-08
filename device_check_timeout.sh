#!/bin/bash
# -*- encoding: utf-8; py-indent-offset: 4 -*-
# vim: :set ts=8 et sw=4 sts=4

hostname=`hostname`

find /sys/class/scsi_generic/*/device/timeout -exec grep -H . '{}' \; | tr ':' ' ' |\
    while read dev timeout; do
        if [[ $timeout -ge 180 ]]; then
            echo "  $hostname ; INFO ; device ; $dev ; timeout ; $timeout"
        else
            echo "  $hostname ; ERROR ; device ; $dev ; timeout ; $timeout"
        fi
    done

exit 0
