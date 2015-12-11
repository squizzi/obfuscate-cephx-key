# Obfuscate cephx keys from a sosreport
This script extracts an sosreport and obfuscates the cephx key visible
in plain text inside each of the qemu process lists that are ran as part
of the 'process' plugin for sosreport as well as the cephx key visible in
`/var/log/libvirt/qemu/*.log`

It then recreates the sosreport with the name `cephx-cleaned-<sosreport>`

This script will be obsolete when an errata for [BZ #1245647](https://bugzilla.redhat.com/show_bug.cgi?id=1245647)
is released which addresses the qemu vulnerability
