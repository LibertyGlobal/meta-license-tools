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

#    workdir=d.getVar("WORKDIR", True)
    march=d.getVar("MACHINE_ARCH", True)
    tclibc=d.getVar("TCLIBC", True)
    buildname=d.getVar("BUILDNAME", True)
    DEPLOY_DIR_SRC = "%s/%s/%s/" % (d.getVar("DEPLOY_DIR_SRC", True), d.getVar("HOST_SYS", True), d.getVar('PF', True))
    IMAGE_NAME = "%s-%s-%s" % (march, tclibc, buildname)
    platform="%s" % d.getVar("MACHINE", True).split("-")[0]

    tarname='%s-patched.tar.gz' % d.getVar('PF', True)

    if d.getVar('VM_SPRINT_NUMBER', True):
       sprintnumber = "SR%s" % d.getVar('VM_SPRINT_NUMBER', True).lstrip("0")
    else:
       sprintnumber = tarname

    foss_upload_dirname = "%s-%s" %(sprintnumber, platform)

    import subprocess

    try:
        subprocess.check_output("""fossup -n %s -f %s%s -d %s"""
                                % (foss_upload_dirname,DEPLOY_DIR_SRC, tarname, sprintnumber),
                                shell=True,
                                stderr=subprocess.STDOUT)
        return ""
    except subprocess.CalledProcessError as ex:
        bb.warn("""Was not able to run fossup -n %s -f %s%s -d %s"""
                   % (foss_upload_dirname, DEPLOY_DIR_SRC, tarname, sprintnumber))
        return ""
}


addtask do_fossology after do_deploy_archives before do_compile
