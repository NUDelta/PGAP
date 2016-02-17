#!/bin/bash
# original source from http://www.thecave.com/2014/09/16/using-xcodebuild-to-export-a-ipa-from-an-archive/

xcodebuild clean -project pgagAudio -configuration Release -alltargets
xcodebuild archive -project pgagAudio.xcodeproj -scheme pgagAudio -archivePath pgagAudio.xcarchive
xcodebuild -exportArchive -archivePath pgagAudio.xcarchive -exportPath pgagAudio -exportFormat ipa -exportProvisioningProfile "Delta"
