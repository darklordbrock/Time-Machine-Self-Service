#!/bin/bash
##############
# This Script will allow a user to select the drive they would like to use for encrypted time mechine. 
# It will then reformat the partition if it is needed, and/or repartition the drive to GUID if needed.
# The user does not need to be an admin or have access to the Time Machine Preference Panel. 
#
# This was writen by
# Kyle Brockman
# While working for Univeristy Information Technology Servives
# at the Univeristy of Wisconsin Milwaukee
##############

#CocoaDialog Variables 
CD="/Applications/Utilities/CocoaDialog.app/Contents/MacOS/CocoaDialog"
CDI="/Applications/Utilities/CocoaDialog.app/Contents/Resources"

TMD="NotADisk"

while [ $TMD = "NotADisk" ];do
	
	TMD=`$CD fileselect --select-only-directories --float --with-directory /Volumes --text "Select the Backup Drive for Time Machine"`
	
	echo $TMD
	TMDselected=`echo $TMD`
	TMD1=`echo $TMD | awk '{ print $1 }'`
	
	if [ "$TMD1" == "" ] ; then
		echo "User clicked Cancel"
		exit 1
	fi
	echo $TMDRECORD "in while loop"
	mount | grep "$TMDselected" | grep local
	if [ $? != "0" ]; then
		$CD ok-msgbox --no-cancel --icon hazard --float --text "Your selection is not a usable drive for Time Machine." --informative-text "Please select again"
		TMD="NotADisk"
	fi
	
done

echo "TMDselected" $TMDselected
echo "User Selected " $TMDselected " as their Time Machine Drive"

#
TMDRECORD=`diskutil info "$TMDselected" | grep "Partition Type:" | awk '{print $3}'`
TMDFORMAT=`diskutil info "$TMDselected" | grep "File System Personality:" | awk '{print $4 $5}'`
DISK=`diskutil info "$TMDselected" | grep "Part of Whole:" | awk '{print $4}'`
COREDISK=`diskutil corestorage info $DISK | grep "Conversion Status:" | awk '{print $3}'`

#
echo "######Time Machine Drive Selected Partition Type: " $TMDRECORD 

echo "######Time Machine Drive Selected File System Personality: " $TMDFORMAT

echo "######Time Machine Drive Selected Part of Disk: " $DISK

#
if [ "$COREDISK" == "Complete" ]; then
	echo "Disk is already encrypted"
	
	echo "tmutil setdestination"
	tmutil setdestination "$TMDselected"

	echo "tmutil enable for automatic backups"
	tmutil enable

	echo "tmutil enable local snapshots"
	tmutil enablelocal
	
	exit 0
else
	echo "Disk is not already encrypted"
fi

#
if [ "$TMDRECORD" != "Apple_HFS" ] ; then
	
		#ask the users are they really sure
		FIRST=`$CD yesno-msgbox --no-cancel --string-output --no-newline --title "Drive Re-format" --text "The Selected Drive needs to be re-formatted." --informative-text "The drive you have selected needs to be re-formatted to be used with Time Machine. Do you want to re-format it?"`

		if [ "$FIRST" == "Yes" ]; then
			echo "Uesr clicked yes first time"
		else
			echo "User clicked no first time"
			exit 1
		fi

		#do you want me to format X
	
		SECOND=`$CD yesno-msgbox --no-cancel --string-output --no-newline --title "Data Loss" --text "All Data on Drive will be lost" --informative-text "All data on this drive will be lost when it is RE-FORMATTED. Are you sure you want to continue?"`

		if [ "$SECOND" == "Yes" ]; then
			echo "Uesr clicked yes second time"
		else
			echo "User clicked no second time"
			exit 1
		fi

		#are you really sure
	
		THIRD=`$CD yesno-msgbox --no-cancel --string-output --no-newline --title "Confirmation" --text "Are you sure?" --informative-text "Are you sure that you want to RE-FORMAT the disk? ALL DATA on this drive will be ERASED after your click yes."`

		if [ "$THIRD" == "Yes" ]; then
			echo "Uesr clicked yes third time"
		else
			echo "User clicked no third time"
			exit 1
		fi

		TMDselectedJUSTname=`echo $TMDselected | cut -b 10-`
		echo "######diskutil eraseDisk JHFS+" $TMDselectedJUSTname $DISK
		diskutil eraseDisk JHFS+ "$TMDselectedJUSTname" $DISK
		echo "drive was formated Journaled HFS+ and repartitioned to GUID"
		
else
	
	if [ "$TMDFORMAT" != "JournaledHFS+" ] ; then
		#ask the users are they really sure
		FIRST=`$CD yesno-msgbox --no-cancel --string-output --no-newline --title "Drive Re-format" --text "The Selected Drive needs to be re-formatted." --informative-text "The drive you have selected needs to be re-formatted to be used with Time Machine. Do you want to re-format it?"`

		if [ "$FIRST" == "Yes" ]; then
			echo "Uesr clicked yes first time"
		else
			echo "User clicked no first time"
			exit 1
		fi

		#do you want me to format X
	
		SECOND=`$CD yesno-msgbox --no-cancel --string-output --no-newline --title "Data Loss" --text "All Data on Drive will be lost" --informative-text "All data on this drive will be lost when it is RE-FORMATTED. Are you sure you want to continue?"`

		if [ "$SECOND" == "Yes" ]; then
			echo "Uesr clicked yes second time"
		else
			echo "User clicked no second time"
			exit 1
		fi

		#are you really sure
	
		THIRD=`$CD yesno-msgbox --no-cancel --string-output --no-newline --title "Confirmation" --text "Are you sure?" --informative-text "Are you sure that you want to RE-FORMAT the disk? ALL DATA on this drive will be ERASED after your click yes."`

		if [ "$THIRD" == "Yes" ]; then
			echo "Uesr clicked yes third time"
		else
			echo "User clicked no third time"
			exit 1
		fi
		
		diskutil erase "$TMDselected" JHFS+
		echo "Partition reformated to JHFS+"
		
	else
	
		echo "drive is Journaled HFS+ and GUID partitioned"

	fi
fi

#
PASSONE="1"
PASSTWO="2"

while [ $PASSONE != $PASSTWO ];do


	#Sets the nothing variable 
	NOTHING1="1"
	
	#input from user on password for the drive
	while [ $PASSONE -eq $NOTHING1 ]; do
	
		PASSONE=`$CD secure-standard-inputbox --no‑cancel --float --title "Enter Password" --informative-text "Enter password for Time machine Drive:"`
	
	done
	
	#Sets the nothing2 variable 
	NOTHING2="2"
	
	#verify password from the user for the drive
	while [ $PASSTWO -eq $NOTHING2 ]; do
	
		PASSTWO=`$CD secure-standard-inputbox --no‑cancel --float --title "Verify Password" --informative-text "Re-enter password for Time machine Drive "` 
	
	done
	
	if [ $PASSONE != $PASSTWO ]; then

		PASSONE="1"
		PASSTWO="2"
		
	else
		
		echo "they matched passwords"
	fi
	
done

PASS=`echo $PASSONE | awk '{ print $2 }'`

echo "Users password verified and beginning encryption"

#Convert the drive to encrypted
echo "diskutil command"
diskutil cs convert "$TMDselected" -passphrase $PASS  

#setup time machine to use the drive
echo "tmutil setdestination"
tmutil setdestination "$TMDselected"

echo "tmutil enable for automatic backups"
tmutil enable

echo "tmutil enable local snapshots"
tmutil enablelocal

exit 0