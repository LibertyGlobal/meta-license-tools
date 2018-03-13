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


ARCHIVER_OUTDIR = "${WORKDIR}/deploy-sources/${TARGET_SYS}/${PF}/"
IMAGE_NAME = "${MACHINE_ARCH}-${TCLIBC}-${BUILDNAME}"

python do_fossology () {

    outdir = d.getVar("ARCHIVER_OUTDIR")
    bn = d.getVar('IMAGE_NAME')
    tarname='%s-patched.tar.gz' % d.getVar('PF')
    import subprocess
    try:
        subprocess.check_output("""fossup -n %s -f %s/%s -d %s""" 
                                % (bn, outdir, tarname, bn),
                                shell=True,
                                stderr=subprocess.STDOUT)
        return ""
    except subprocess.CalledProcessError as ex:
        return ""
}

addtask do_fossology after do_deploy_archives

do_populate_sysroot[sstate-interceptfuncs] += "do_fossology "

EXPORT_FUNCTIONS do_fossology

