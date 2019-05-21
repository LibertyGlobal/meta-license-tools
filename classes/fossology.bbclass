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

IMAGE_NAME = "${MACHINE_ARCH}-${TCLIBC}"

python do_fossology () {
    # The target bits are broken for this branch. Exclude native and cross
    if "-native" in d.getVar('PF', True):
        return
    if "-cross" in d.getVar('PF', True):
        return
    bn = d.getVar('IMAGE_NAME')
    ARCHIVER_OUTDIR = "${WORKDIR}/deploy-sources/${TARGET_SYS}/${PF}/"
    outdir = d.getVar("ARCHIVER_OUTDIR")
    tarname='%s-patched.tar.gz' % d.getVar('PF')

    # import fossdriver objects                                                 
    from fossdriver.config import FossConfig                                    
    from fossdriver.server import FossServer                                    
    from fossdriver.tasks import (CreateFolder, Upload, Scanners, Copyright)    
    #other objects/libs, check if required                                      
    from os.path import expanduser                                              
                                                                                
    config = FossConfig()                                                       
    home = expanduser("~")                                                      
    configPath = home + "/.fossdriverrc"                                        
    config.configure(configPath)                                                
    server = FossServer(config)                                                 
    server.Login()                                                              
    config = FossConfig()                                                       
    home = expanduser("~")                                                      
    configPath = home + "/.fossdriverrc"                                        
    config.configure(configPath)                                                
    server = FossServer(config)                                                 
    server.Login() 

    if d.getVar('VM_SPRINT_NUMBER', True):
       sprintnumber = "SR%s" % d.getVar('VM_SPRINT_NUMBER', True).lstrip("0")
    else:
       sprintnumber = bn
    #Create Folder: need existing parent directory, using Fossology default      
    try:
        CreateFolder(server, bn, "Software Repository").run()
    except:
        return 0 
            
    # Upload 
    try:                                                                    
        Upload(server, outdir+tarname, sprintnumber).run()                            
    except:
        bb.warn("Unable to upload file to server")
        return 0                                                                             
    # scanners
    try:                                                                   
        Scanners(server, outdir+tarname, sprintnumber).run()
    except:
        bb.warn("Unable to run scanners")                          
    # Reuse: Need to patch fossdriver to address reuser bug
}

addtask do_fossology after do_deploy_archives before do_compile
