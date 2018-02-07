#
# Sends source to Fossology instance
#
# coding=utf-8
#
# Copyright (C) 2016-2018 Togán Labs Ltd.
#
# Author: Eilís Ní Fhlannagáin <pidge@toganlabs.com>
#
# Licensed under the MIT license, see COPYING.MIT for details
#
# Usage: add INHERIT += "fossology" and all the bits needed for archiver.bbclass
# to your conf file


do_fossology[vardepsexclude] = "BUILDNAME WORKDIR PF MACHINE_ARCH TCLIBC ARCHIVER_OUTDIR IMAGE_NAME"

python do_fossology () {
    # The target bits are broken for this branch. Exclude native and cross
    if "-native" in d.getVar('PF', True):
        return
    if "-cross" in d.getVar('PF', True):
        return

    workdir=d.getVar("WORKDIR", True)
    march=d.getVar("MACHINE_ARCH", True)
    tclibc=d.getVar("TCLIBC", True)
    buildname=d.getVar("BUILDNAME", True)
    ARCHIVER_OUTDIR = "%s/deploy/sources/" % workdir
    IMAGE_NAME = "%s-%s-%s" % (march, tclibc, buildname)


    outdir = d.getVar("ARCHIVER_OUTDIR", True)
    bn = d.getVar('IMAGE_NAME', True)
    tarname='%s-patched.tar.gz' % d.getVar('PF', True)
    import subprocess
    try:
        subprocess.check_output("""fossup -n %s -f %s/%s -d %s""" 
                                % (bn, outdir, tarname, tarname),
                                shell=True,
                                stderr=subprocess.STDOUT)
        return ""
    except subprocess.CalledProcessError as ex:
        return ""
}


addtask do_fossology after do_deploy_archives before do_compile
